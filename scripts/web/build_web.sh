#!/usr/bin/env bash
# =============================================================================
# AuthVault Web — Production Build Script
# Usage: ./build_web.sh [staging|production]
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WEB_DIR="$ROOT/web"
OUTPUT_DIR="$WEB_DIR/dist"
ENV="${1:-production}"
ENV_FILE="$ROOT/scripts/env/.env.web"

set -a; source "$ENV_FILE"; set +a

cd "$WEB_DIR"

echo ">>> Installing dependencies..."
npm ci --frozen-lockfile

echo ">>> Type checking..."
npx tsc --noEmit

echo ">>> Linting..."
npx eslint src --max-warnings 0

echo ">>> Running unit tests..."
npx vitest run

echo ">>> Building for $ENV..."
if [[ "$ENV" == "production" ]]; then
  VITE_APP_ENV=production npx vite build
else
  VITE_APP_ENV=staging npx vite build --mode staging
fi

echo ">>> Build stats:"
du -sh "$OUTPUT_DIR"
find "$OUTPUT_DIR" -name "*.js" | head -10

echo "✅ Web build complete: $OUTPUT_DIR"
