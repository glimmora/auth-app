#!/usr/bin/env bash
# =============================================================================
# AuthVault Web — Production Build Script
# Usage: ./build_web.sh [staging|production]
# Outputs: auth-app/dist/web/
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WEB_DIR="$ROOT/web"
DIST_DIR="$ROOT/dist/web"
ENV="${1:-production}"
ENV_FILE="$ROOT/scripts/env/.env.web"

if [[ -f "$ENV_FILE" ]]; then
  set -a; source "$ENV_FILE"; set +a
fi

cd "$WEB_DIR"

echo ">>> Installing dependencies..."
npm ci --frozen-lockfile

echo ">>> Type checking..."
npx tsc --noEmit

echo ">>> Linting..."
npx eslint 'src/**/*.{ts,tsx}' --max-warnings 0

echo ">>> Running unit tests..."
npx vitest run

echo ">>> Building for $ENV..."
if [[ "$ENV" == "production" ]]; then
  VITE_APP_ENV=production npx vite build --outDir "$DIST_DIR"
else
  VITE_APP_ENV=staging npx vite build --mode staging --outDir "$DIST_DIR"
fi

echo ">>> Build stats:"
du -sh "$DIST_DIR"
find "$DIST_DIR" -name "*.js" | head -10

echo "✅ Web build complete: $DIST_DIR"
