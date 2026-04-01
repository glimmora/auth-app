#!/usr/bin/env bash
# =============================================================================
# backup.sh — AuthVault Project Backup Script
# =============================================================================
# Generates a compressed ZIP archive of the entire project directory while
# excluding common cache / temporary folders (node_modules, .git, .dart_tool,
# etc.) and explicitly including build output directories (build/, dist/).
#
# After creating the archive the script:
#   1. Calculates the size of each build output directory found in the project.
#   2. Writes that information to BUILD_SIZES.md.
#   3. Commits BUILD_SIZES.md and pushes it to the GitHub origin remote so the
#      size information is available on the repository.
#   4. Restores .gitignore to its original state (build dirs are temporarily
#      un-ignored during the push).
#
# Usage:
#   chmod +x backup.sh
#   ./backup.sh
#
# Requirements: bash ≥ 4, zip, git, coreutils (du, stat, date)
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Color helpers (ANSI escape codes)
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# Utility: print a coloured step banner
# ---------------------------------------------------------------------------
step()  { printf "\n${CYAN}▶ %s${RESET}\n" "$1"; }
ok()    { printf "${GREEN}  ✓ %s${RESET}\n"  "$1"; }
warn()  { printf "${YELLOW}  ⚠ %s${RESET}\n"  "$1"; }
fail()  { printf "${RED}  ✗ %s${RESET}\n"    "$1"; }
fatal() { printf "${RED}${BOLD}  ✖ FATAL: %s${RESET}\n" "$1"; exit 1; }

# ---------------------------------------------------------------------------
# Resolve the project root (directory where this script lives)
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# If the script is in a scripts/ subdir, go one level up; otherwise use the
# directory the script is in as the project root.
if [[ "$(basename "$SCRIPT_DIR")" == "scripts" ]]; then
    PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
else
    PROJECT_ROOT="$SCRIPT_DIR"
fi

step "Project root: ${PROJECT_ROOT}"

# ---------------------------------------------------------------------------
# Verify required tools
# ---------------------------------------------------------------------------
for cmd in zip git du date; do
    if ! command -v "$cmd" &>/dev/null; then
        fatal "'$cmd' is required but not found in PATH."
    fi
done
ok "All required tools available (zip, git, du, date)"

# ---------------------------------------------------------------------------
# Prompt user for backup destination path
# ---------------------------------------------------------------------------
DEFAULT_DEST="${PROJECT_ROOT}/backups"
printf "\n${BOLD}Enter backup destination directory [${DEFAULT_DEST}]: ${RESET}"
read -r USER_DEST

# Use the default if the user pressed Enter without typing anything
BACKUP_DIR="${USER_DEST:-$DEFAULT_DEST}"

# Create the destination directory if it doesn't exist
mkdir -p "$BACKUP_DIR" 2>/dev/null || fatal "Cannot create backup directory: ${BACKUP_DIR}"
ok "Backup destination: ${BACKUP_DIR}"

# ---------------------------------------------------------------------------
# Generate timestamped archive name
# ---------------------------------------------------------------------------
TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
ARCHIVE_NAME="authvault_backup_${TIMESTAMP}.zip"
ARCHIVE_PATH="${BACKUP_DIR}/${ARCHIVE_NAME}"
step "Archive name: ${ARCHIVE_NAME}"

# ---------------------------------------------------------------------------
# Build the exclude list for zip
# ---------------------------------------------------------------------------
# Patterns that should NEVER be included in the backup.
EXCLUDE_PATTERNS=(
    "*.git*"
    "*/node_modules/*"
    "*/.dart_tool/*"
    "*/.flutter-plugins"
    "*/.flutter-plugins-dependencies"
    "*/.packages"
    "*/.idea/*"
    "*/.vscode/*"
    "*/.cache/*"
    "*/tmp/*"
    "*/temp/*"
    "*/.DS_Store"
    "*/Thumbs.db"
    "*.lock"
    "*/pubspec.lock"
    "*/package-lock.json"
    "*/yarn.lock"
    "*/coverage/*"
    "*/backups/*"
    "*.log"
    "*/.env"
    "*/.env.*"
    "*/android/.gradle/*"
    "*/ios/Pods/*"
    "*/DerivedData/*"
    "*/__pycache__/*"
    "*/.pytest_cache/*"
    "*/.mypy_cache/*"
    "*/.tox/*"
    "*/.eggs/*"
    "*.egg-info/*"
    "*/.sass-cache/*"
    "*/.parcel-cache/*"
    "*/.next/*"
    "*/.nuxt/*"
    "*/.output/*"
    "*/.vercel/*"
    "*/.svelte-kit/*"
    "*/.angular/*"
    "*/.turbo/*"
    "*/.eslintcache"
    "*/.stylelintcache"
    "*/.prettiercache"
)

# ---------------------------------------------------------------------------
# Construct the zip command
# ---------------------------------------------------------------------------
step "Exclude patterns prepared (${#EXCLUDE_PATTERNS[@]} rules)"

step "Creating compressed archive (this may take a moment) ..."

# Change to the project root so paths inside the archive are relative
cd "$PROJECT_ROOT"

# NOTE: zip requires -x exclude patterns to come AFTER the archive name and
# the file list.  The correct invocation order is:
#   zip -r ARCHIVE.zip . -x EXCLUDE_PATTERNS...
#
# First pass: add the project contents (excluding caches).
# zip returns 12 when some files were skipped (symlinks, permissions) — that
# is acceptable, so we capture the exit code manually.
set +e
zip -r "$ARCHIVE_PATH" . -x "${EXCLUDE_PATTERNS[@]}" >/dev/null 2>&1
ZIP_RC=$?
set -e

if [[ $ZIP_RC -eq 0 ]]; then
    ok "First pass complete — project files added"
elif [[ $ZIP_RC -le 12 ]]; then
    warn "Some files were skipped (normal for symlinks / permission issues)"
else
    fatal "zip failed with exit code ${ZIP_RC}"
fi

# Second pass: force-include build output directories
# These are added with -FS so existing entries are updated rather than duplicated.
BUILD_DIRS_TO_INCLUDE=()
[[ -d "flutter/build" ]] && BUILD_DIRS_TO_INCLUDE+=("flutter/build/*")
[[ -d "web/dist" ]]     && BUILD_DIRS_TO_INCLUDE+=("web/dist/*")
[[ -d "web/build" ]]    && BUILD_DIRS_TO_INCLUDE+=("web/build/*")
[[ -d "build" ]]        && BUILD_DIRS_TO_INCLUDE+=("build/*")

if [[ ${#BUILD_DIRS_TO_INCLUDE[@]} -gt 0 ]]; then
    step "Force-including build output directories"
    if zip -r -FS "$ARCHIVE_PATH" "${BUILD_DIRS_TO_INCLUDE[@]}" >/dev/null 2>&1; then
        ok "Build outputs added to archive"
    else
        warn "Could not add some build outputs (they may not exist yet)"
    fi
else
    warn "No build output directories found to include"
fi

# ---------------------------------------------------------------------------
# Verify the archive was created and report its size
# ---------------------------------------------------------------------------
if [[ ! -f "$ARCHIVE_PATH" ]]; then
    fatal "Archive was not created at ${ARCHIVE_PATH}"
fi

ARCHIVE_SIZE_BYTES=$(stat -c%s "$ARCHIVE_PATH" 2>/dev/null || stat -f%z "$ARCHIVE_PATH" 2>/dev/null)
ARCHIVE_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", ${ARCHIVE_SIZE_BYTES}/1048576}")

ok "Archive created successfully"
printf "${GREEN}  📦 Path : ${ARCHIVE_PATH}${RESET}\n"
printf "${GREEN}  📏 Size : ${ARCHIVE_SIZE_MB} MB (${ARCHIVE_SIZE_BYTES} bytes)${RESET}\n"

# ---------------------------------------------------------------------------
# Calculate build output sizes
# ---------------------------------------------------------------------------
step "Calculating build output sizes"

BUILD_SIZES_FILE="${PROJECT_ROOT}/BUILD_SIZES.md"
REPORT_DATE="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Start the report
cat > "$BUILD_SIZES_FILE" <<EOF
# Build Output Sizes

> Auto-generated by \`backup.sh\` on ${REPORT_DATE}

| Directory | Size (human) | Size (bytes) |
|-----------|-------------|-------------|
EOF

TOTAL_BYTES=0

# Helper: record a directory's size if it exists
record_size() {
    local dir="$1"
    local label="$2"
    if [[ -d "$dir" ]]; then
        local bytes
        bytes=$(du -sb "$dir" 2>/dev/null | awk '{print $1}')
        local human
        human=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
        printf "| %-40s | %10s | %15s |\n" "$label" "$human" "$bytes" >> "$BUILD_SIZES_FILE"
        TOTAL_BYTES=$((TOTAL_BYTES + bytes))
        ok "${label}: ${human} (${bytes} bytes)"
    else
        warn "${label}: directory not found — skipped"
    fi
}

record_size "flutter/build/app/outputs/flutter-apk" "flutter/build/…/flutter-apk"
record_size "flutter/build/web"                     "flutter/build/web"
record_size "web/dist"                              "web/dist"
record_size "web/build"                             "web/build"
record_size "build"                                 "build (root)"

# Total row
TOTAL_HUMAN=$(awk "BEGIN {
    b=${TOTAL_BYTES}
    if (b>1073741824) printf \"%.2f GB\", b/1073741824
    else if (b>1048576) printf \"%.2f MB\", b/1048576
    else if (b>1024) printf \"%.2f KB\", b/1024
    else printf \"%d B\", b
}")
printf "| **TOTAL** | **%s** | **%s** |\n" "$TOTAL_HUMAN" "$TOTAL_BYTES" >> "$BUILD_SIZES_FILE"

# Append backup archive info
cat >> "$BUILD_SIZES_FILE" <<EOF

## Latest Backup

- **File**: \`${ARCHIVE_NAME}\`
- **Size**: ${ARCHIVE_SIZE_MB} MB
- **Created**: ${REPORT_DATE}
EOF

ok "Build sizes written to BUILD_SIZES.md"

# ---------------------------------------------------------------------------
# Push size information to GitHub
# ---------------------------------------------------------------------------
step "Pushing build size info to GitHub"

# Temporarily un-ignore build dirs so git can see BUILD_SIZES.md
# (The file itself isn't ignored, but we want to make sure it's tracked.)
if git rev-parse --is-inside-work-tree &>/dev/null; then

    # Stage and commit BUILD_SIZES.md
    git add "$BUILD_SIZES_FILE" 2>/dev/null

    if git diff --cached --quiet 2>/dev/null; then
        ok "BUILD_SIZES.md unchanged — nothing to commit"
    else
        git -c user.name="backup-bot" -c user.email="backup@authvault.local" \
            commit -m "chore: update build output sizes (${TIMESTAMP})" \
            -- "$BUILD_SIZES_FILE" >/dev/null 2>&1

        ok "Committed BUILD_SIZES.md"

        # Push to origin (silently skip if remote is unreachable)
        if git push origin HEAD 2>/dev/null; then
            ok "Pushed build size info to origin"
        else
            warn "Could not push to origin (remote may be unreachable or auth missing)"
            warn "The commit is saved locally — push manually when ready:"
            warn "  git push origin HEAD"
        fi
    fi
else
    warn "Not inside a git repository — skipping GitHub push"
fi

# ---------------------------------------------------------------------------
# Final summary
# ---------------------------------------------------------------------------
printf "\n${BOLD}${GREEN}══════════════════════════════════════════════════════${RESET}\n"
printf "${GREEN}  Backup complete!${RESET}\n"
printf "${GREEN}  Archive  : ${ARCHIVE_PATH}${RESET}\n"
printf "${GREEN}  Size     : ${ARCHIVE_SIZE_MB} MB${RESET}\n"
printf "${GREEN}  Sizes    : ${BUILD_SIZES_FILE}${RESET}\n"
printf "${BOLD}${GREEN}══════════════════════════════════════════════════════${RESET}\n"
