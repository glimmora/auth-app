#!/usr/bin/env bash
# =============================================================================
# AuthVault Web — Deploy Script
# Supports: Netlify, Vercel, Cloudflare Pages, S3+CloudFront
# Usage: ./deploy_web.sh [netlify|vercel|cf|s3]
# =============================================================================
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WEB_DIR="$ROOT/web"
DIST="$ROOT/dist/web"
TARGET="${1:-netlify}"
ENV_FILE="$ROOT/scripts/env/.env.web"

if [[ -f "$ENV_FILE" ]]; then
  set -a; source "$ENV_FILE"; set +a
fi

[[ -d "$DIST" ]] || { echo "ERROR: Run build_web.sh first"; exit 1; }

case "$TARGET" in
  netlify)
    npx netlify-cli deploy --dir "$DIST" --prod
    ;;
  vercel)
    npx vercel --cwd "$WEB_DIR" --prod
    ;;
  cf)
    npx wrangler pages deploy "$DIST" --project-name authvault
    ;;
  s3)
    aws s3 sync "$DIST" "s3://$S3_BUCKET/" --delete
    aws cloudfront create-invalidation \
      --distribution-id "$CF_DISTRIBUTION_ID" \
      --paths "/*"
    ;;
  *)
    echo "Unknown target: $TARGET (netlify|vercel|cf|s3)"
    exit 1
    ;;
esac

echo "✅ Deployed to $TARGET"
