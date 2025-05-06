#!/bin/bash

# =================== CONFIGURATION ====================
LOG_DIR="/mnt/docker-volume/flask-redis-app-logs"
LOG_FILE="$LOG_DIR/deploy.log"
SLACK_WEBHOOK_URL=""  # Optional: paste your Slack webhook URL here
# ======================================================

# Ensure logs directory exists
mkdir -p "$LOG_DIR"
rm -f "$LOG_FILE"

echo "🚀 Starting deployment process..." | tee "$LOG_FILE"

# Backup the script if it has local changes
if git status --porcelain | grep -q "deploy_version.sh"; then
    echo "⚠️ Local changes in deploy_version.sh detected. Backing up temporarily..." | tee -a "$LOG_FILE"
    cp deploy_version.sh deploy_version.bak
    git add deploy_version.bak
fi

# =================== USER INPUT ====================
read -p "Enter your commit message: " COMMIT_MESSAGE
read -p "Do you want to add all files (git add .)? (y/n): " ADD_ALL
read -p "Do you want to merge 'dev' into 'main'? (y/n): " MERGE_DEV
read -p "Enter tag name (e.g., v1.2.3) or press Enter to skip: " VERSION
read -p "Delete existing tag if found? (y/n): " DELETE_TAG
read -p "Do you want to rollback from tag? (y/n): " ROLLBACK

# =================== ADD FILES ====================
if [ "$ADD_ALL" == "y" ]; then
    echo "📥 Adding all files to staging..." | tee -a "$LOG_FILE"
    git add .
else
    read -p "Enter specific files to add (space-separated): " FILES
    git add $FILES
fi

# =================== DEV COMMIT ====================
echo "📦 Switching to 'dev' branch..." | tee -a "$LOG_FILE"
git restore --staged "$LOG_FILE" 2>/dev/null
git checkout dev || { echo "❌ Failed to checkout 'dev'" | tee -a "$LOG_FILE"; exit 1; }

if git diff --cached --quiet; then
    echo "⚠️ No staged changes to commit." | tee -a "$LOG_FILE"
else
    echo "📌 Committing with message: $COMMIT_MESSAGE" | tee -a "$LOG_FILE"
    git commit -m "$COMMIT_MESSAGE" | tee -a "$LOG_FILE"
    echo "📤 Pushing 'dev' to remote..." | tee -a "$LOG_FILE"
    git push origin dev | tee -a "$LOG_FILE"
fi

# =================== MERGE TO MAIN ====================
if [ "$MERGE_DEV" == "y" ]; then
    echo "🔀 Merging 'dev' into 'main'..." | tee -a "$LOG_FILE"
    git checkout main || { echo "❌ Failed to checkout 'main'" | tee -a "$LOG_FILE"; exit 1; }
    git pull origin main | tee -a "$LOG_FILE"
    git merge dev || { echo "❌ Merge failed" | tee -a "$LOG_FILE"; exit 1; }
    git push origin main | tee -a "$LOG_FILE"
fi

# =================== TAG CREATION ====================
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

    if [ ! -z "$SLACK_WEBHOOK_URL" ]; then
        echo "📩 Sending Slack notification..." | tee -a "$LOG_FILE"
        curl -X POST -H 'Content-type: application/json' --data "{
            \"text\": \"New production release: *$VERSION* pushed to GitHub.\"
        }" $SLACK_WEBHOOK_URL
    fi
fi

# =================== ROLLBACK ====================
if [ "$ROLLBACK" == "y" ]; then
    read -p "Enter tag to rollback to (e.g., v1.0.0): " ROLLBACK_TAG
    echo "🧯 Rolling back to $ROLLBACK_TAG..." | tee -a "$LOG_FILE"
    git checkout "$ROLLBACK_TAG" || { echo "❌ Tag not found" | tee -a "$LOG_FILE"; exit 1; }
    git checkout -b "rollback-$ROLLBACK_TAG"
    git push origin "rollback-$ROLLBACK_TAG"
fi

echo "✅ Deployment process completed." | tee -a "$LOG_FILE"

