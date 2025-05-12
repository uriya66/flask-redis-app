#!/bin/bash

# Usage: ./rollback.sh v1.0.0
TAG=$1

if [ -z "$TAG" ]; then
  echo "❌ You must provide a version tag (e.g., ./rollback.sh v1.0.0)"
  exit 1
fi

echo "🔁 Rolling back to version: $TAG"

# Stop current containers
docker compose -f docker-compose.yml -f docker-compose.prod.yml down || true

# Deploy previous version
IMAGE_TAG=$TAG docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d

echo "✅ Rollback to $TAG complete!"

