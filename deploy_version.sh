#!/bin/bash

# =================== CONFIGURATION ====================
LOG_DIR="./logs"
LOG_FILE="$LOG_DIR/deploy.log"
TAG_REGEX="^v[0-9]+\.[0-9]+\.[0-9]+$"
# ======================================================

# 🔧 Ensure log directory exists
mkdir -p "$LOG_DIR"
> "$LOG_FILE"  # Clean previous log

log() {
    echo "$1" | tee -a "$LOG_FILE"
}

log "🚀 Starting deployment process..."

# ✏️ Commit message
read -p "Enter your commit message: " COMMIT_MESSAGE

# 📥 Files to add
read -p "Do you want to add all files (git add .)? (y/n): " ADD_ALL
if [ "$ADD_ALL" == "y" ]; then
    git add .
else
    read -p "Enter specific files to add (space-separated): " FILES
    git add $FILES
fi

# 🔀 Merge dev to main
read -p "Do you want to merge 'dev' into 'main'? (y/n): " MERGE_DEV

# 🏷️ Tag
read -p "Enter tag name (e.g., v1.2.3) or press Enter to skip: " VERSION
if [[ $VERSION =~ $TAG_REGEX ]]; then
    read -p "Delete existing tag if found? (y/n): " DELETE_TAG
fi

# 🔙 Rollback
read -p "Do you want to rollback from tag? (y/n): " ROLLBACK
if [ "$ROLLBACK" == "y" ]; then
    read -p "Enter tag to rollback to (e.g., v1.0.0): " ROLLBACK_TAG
    git checkout "$ROLLBACK_TAG" || { log "❌ Failed to checkout $ROLLBACK_TAG"; exit 1; }
    read -p "Do you want to create a new branch from this tag? (y/n): " CREATE_BRANCH
    if [ "$CREATE_BRANCH" == "y" ]; then
        read -p "Enter new branch name: " BRANCH_NAME
        git checkout -b "$BRANCH_NAME"
        log "✅ Rolled back to $ROLLBACK_TAG and created branch $BRANCH_NAME"
    else
        log "✅ Rolled back to tag $ROLLBACK_TAG"
    fi
    exit 0
fi

# 🚧 Begin commit on dev
git checkout dev || { log "❌ Failed to checkout dev"; exit 1; }

if git diff --cached --quiet; then
    log "⚠️ No changes to commit"
else
    git commit -m "$COMMIT_MESSAGE"
    log "📌 Committed: $COMMIT_MESSAGE"
fi

git push origin dev || { log "❌ Failed to push dev"; exit 1; }

# 🔀 Merge to main (with custom message)
if [ "$MERGE_DEV" == "y" ]; then
    git checkout main || { log "❌ Failed to checkout main"; exit 1; }
    git pull origin main

    MERGE_MSG="Merge branch 'dev' to main - $COMMIT_MESSAGE"
    git merge dev -m "$MERGE_MSG" || { log "❌ Merge failed"; exit 1; }
    git push origin main || { log "❌ Push to main failed"; exit 1; }
    log "✅ Merged 'dev' into 'main'"
fi

# 🏷️ Tag creation
if [[ $VERSION =~ $TAG_REGEX ]]; then
    if git rev-parse "$VERSION" >/dev/null 2>&1; then
        if [ "$DELETE_TAG" == "y" ]; then
            git tag -d "$VERSION"
            git push origin ":refs/tags/$VERSION"
            log "⚠️ Deleted existing tag $VERSION"
        else
            log "⚠️ Tag already exists. Skipping."
            exit 0
        fi
    fi

    git tag -a "$VERSION" -m "Release: $VERSION"
    git push origin "$VERSION"
    log "🏷️ Created and pushed tag $VERSION"
fi

log "✅ Deployment process completed."

