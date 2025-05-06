#!/bin/bash

# =================== CONFIGURATION ====================
LOG_FILE="deploy.log"
SLACK_WEBHOOK_URL=""  # Optional: paste your Slack webhook URL here
# ======================================================

echo "🚀 Starting deployment process..." | tee -a "$LOG_FILE"

# Prompt for commit message
read -p "Enter your commit message: " COMMIT_MESSAGE

# Prompt for tag name (optional)
read -p "Enter tag name (e.g., v1.2.3) or press Enter to skip: " VERSION

# Prompt whether to delete existing tag if it exists
read -p "Delete existing tag if found? (y/n): " DELETE_TAG

# Prompt whether to merge dev into main
read -p "Do you want to merge 'dev' into 'main'? (y/n): " MERGE_DEV

# Prompt whether to add all files or specific files
read -p "Do you want to add all files (git add .)? (y/n): " ADD_ALL
if [ "$ADD_ALL" == "y" ]; then
    echo "Adding all files to staging..." | tee -a "$LOG_FILE"
    git add .
else
    read -p "Enter specific files to add (space-separated): " FILES
    git add $FILES
fi

# Step 1: Checkout dev and commit
echo "📦 Switching to 'dev' branch..." | tee -a "$LOG_FILE"
git checkout dev || { echo "❌ Failed to checkout 'dev'" | tee -a "$LOG_FILE"; exit 1; }

# Check for changes before commit
if git diff --cached --quiet; then
    echo "⚠️ No staged changes to commit." | tee -a "$LOG_FILE"
else
    echo "📌 Committing with message: $COMMIT_MESSAGE" | tee -a "$LOG_FILE"
    git commit -m "$COMMIT_MESSAGE" | tee -a "$LOG_FILE"

    echo "📤 Pushing 'dev' to remote..." | tee -a "$LOG_FILE"
    git push origin dev | tee -a "$LOG_FILE"
fi

# Step 2: Merge to main if requested
if [ "$MERGE_DEV" == "y" ]; then
    echo "🔀 Merging 'dev' into 'main'..." | tee -a "$LOG_FILE"
    git checkout main || { echo "❌ Failed to checkout 'main'" | tee -a "$LOG_FILE"; exit 1; }
    git pull origin main | tee -a "$LOG_FILE"
    git merge dev || { echo "❌ Merge failed" | tee -a "$LOG_FILE"; exit 1; }
    git push origin main | tee -a "$LOG_FILE"
fi

# Step 3: Tag creation (optional)
if [ ! -z "$VERSION" ]; then
    if git rev-parse "$VERSION" >/dev/null 2>&1; then
        if [ "$DELETE_TAG" == "y" ]; then
            echo "⚠️ Deleting existing tag $VERSION..." | tee -a "$LOG_FILE"
            git tag -d "$VERSION" | tee -a "$LOG_FILE"
            git push origin ":refs/tags/$VERSION" | tee -a "$LOG_FILE"
        else
            echo "⚠️ Tag $VERSION already exists. Skipping creation." | tee -a "$LOG_FILE"
            exit 0
        fi
    fi

    echo "🏷️ Creating new tag $VERSION" | tee -a "$LOG_FILE"
    git tag -a "$VERSION" -m "Release: $VERSION" | tee -a "$LOG_FILE"
    git push origin "$VERSION" | tee -a "$LOG_FILE"

    # Optional: Slack Notification
    if [ ! -z "$SLACK_WEBHOOK_URL" ]; then
        echo "📩 Sending Slack notification..." | tee -a "$LOG_FILE"
        curl -X POST -H 'Content-type: application/json' --data "{
            \\"text\\": \\":rocket: New production release: *$VERSION* pushed to GitHub.\\"
        }" $SLACK_WEBHOOK_URL
    fi
fi

echo "✅ Deployment process completed." | tee -a "$LOG_FILE"

