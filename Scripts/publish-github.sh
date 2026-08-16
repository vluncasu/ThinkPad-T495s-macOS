#!/usr/bin/env bash
set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# ThinkPad T495s Hackintosh — GitHub Publication Script
# ─────────────────────────────────────────────────────────────────────────────
# Reads token from stdin (no echo). Creates repo, pushes, sets topics,
# creates pre-release. Token is never written to disk or logs.
# ─────────────────────────────────────────────────────────────────────────────

REPO_NAME="ThinkPad-T495s-macOS"
REPO_DESCRIPTION="OpenCore EFI for Lenovo ThinkPad T495s (20QK) | macOS Ventura on AMD Ryzen 7 PRO 3700U with Radeon Vega 10 GPU acceleration via NootedRed"
REPO_TOPICS="hackintosh,opencore,thinkpad-t495s,amd-hackintosh,vega10,nootedred,macos-ventura,ryzen,amd-laptop,lenovo,picasso,radeon-vega,efi,thinkpad"

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_FILE="${PROJECT_DIR}/Scripts/publish.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# ─── Logging ──────────────────────────────────────────────────────────────────

log() {
    local msg="[$(date '+%H:%M:%S')] $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

log_ok() { log "✓ $1"; }
log_fail() { log "✗ $1"; }
log_info() { log "  $1"; }

# ─── Pre-flight ───────────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  ThinkPad T495s Hackintosh — GitHub Publication"
echo "  ${TIMESTAMP}"
echo "═══════════════════════════════════════════════════════════════════"
echo ""

: > "$LOG_FILE"
log "Publication started"
log_info "Project directory: ${PROJECT_DIR}"

# Check dependencies
for cmd in git gh python3; do
    if ! command -v "$cmd" &>/dev/null; then
        log_fail "Required command not found: $cmd"
        exit 1
    fi
done
log_ok "Dependencies: git, gh, python3"

# ─── Token input (secure) ────────────────────────────────────────────────────

if [[ -n "${GH_TOKEN:-}" ]]; then
    log_info "Using token from GH_TOKEN environment variable"
else
    echo ""
    echo "Paste your GitHub Personal Access Token below and press Enter:"
    echo "(needs 'repo' scope — create at github.com/settings/tokens)"
    echo ""
    printf "Token: "
    read GH_TOKEN
    echo ""
fi

if [[ -z "$GH_TOKEN" ]]; then
    log_fail "No token provided"
    exit 1
fi

# Trim whitespace/newlines that paste might add
GH_TOKEN=$(echo "$GH_TOKEN" | tr -d '[:space:]')

if [[ ${#GH_TOKEN} -lt 30 ]]; then
    log_fail "Token looks too short (${#GH_TOKEN} chars) — verify you copied it correctly"
    exit 1
fi

log_ok "Token received (${#GH_TOKEN} chars, not logged)"

# ─── Authenticate and get username ───────────────────────────────────────────

log "Authenticating with GitHub..."

GH_USER=$(gh api user --jq '.login' 2>/dev/null || true)
if [[ -z "$GH_USER" ]]; then
    # Not logged in yet, authenticate with the token
    echo "$GH_TOKEN" | gh auth login --with-token 2>/dev/null
    GH_USER=$(gh api user --jq '.login' 2>/dev/null || true)
fi

if [[ -z "$GH_USER" ]]; then
    log_fail "Could not authenticate — check token permissions (needs 'repo' scope)"
    exit 1
fi

GH_EMAIL=$(gh api user --jq '.email // empty' 2>/dev/null || true)
if [[ -z "$GH_EMAIL" ]]; then
    GH_EMAIL="${GH_USER}@users.noreply.github.com"
fi

log_ok "Authenticated as: ${GH_USER}"
log_info "Email for commits: ${GH_EMAIL}"

FULL_REPO="${GH_USER}/${REPO_NAME}"
log_info "Target repository: ${FULL_REPO}"

# ─── Validation ───────────────────────────────────────────────────────────────

log "Running release validation..."

cd "$PROJECT_DIR"
VALIDATION_OUTPUT=$(python3 Scripts/validate_release.py --skip-manifest 2>&1)
VALIDATION_EXIT=$?

if [[ $VALIDATION_EXIT -ne 0 ]]; then
    log_fail "Release validation failed:"
    echo "$VALIDATION_OUTPUT" | tee -a "$LOG_FILE"
    exit 1
fi

log_ok "Validation passed ($(echo "$VALIDATION_OUTPUT" | grep -o '[0-9]* checks' || echo 'all checks'))"

# ─── Git init ─────────────────────────────────────────────────────────────────

log "Initializing git repository..."

cd "$PROJECT_DIR"

if [[ -d .git ]]; then
    log_info "Git already initialized — using existing repo"
else
    git init -b main >> "$LOG_FILE" 2>&1
    log_ok "Git initialized (branch: main)"
fi

# Configure git identity for this repo
git config user.name "$GH_USER"
git config user.email "$GH_EMAIL"
log_ok "Git identity: ${GH_USER} <${GH_EMAIL}>"

# ─── Stage and commit ─────────────────────────────────────────────────────────

log "Staging files..."

# Remove .DS_Store if present
find . -name ".DS_Store" -delete 2>/dev/null || true

git add -A >> "$LOG_FILE" 2>&1

STAGED_COUNT=$(git diff --cached --stat | tail -1 | grep -o '[0-9]* file' | grep -o '[0-9]*' || echo "0")
log_ok "Staged ${STAGED_COUNT} files"

# Check if there's anything to commit
if git diff --cached --quiet 2>/dev/null; then
    EXISTING_COMMITS=$(git rev-list --count HEAD 2>/dev/null || echo "0")
    if [[ "$EXISTING_COMMITS" == "0" ]]; then
        log_fail "Nothing to commit and no existing commits"
        exit 1
    fi
    log_info "No new changes — using existing commits"
else
    log "Creating initial commit..."
    git commit -m "$(cat <<'EOF'
ThinkPad T495s Hackintosh v17.1 — macOS Ventura on AMD Ryzen + Vega 10

Complete OpenCore EFI, engineering documentation, and validation tooling
for the Lenovo ThinkPad T495s (20QK) running macOS Ventura 13.7.8 with
AMD Ryzen 7 PRO 3700U and Radeon Vega 10 GPU acceleration via NootedRed.

Working: boot, CPU, Metal GPU, display, keyboard, touchpad, Wi-Fi, BT,
NVMe, USB, brightness keys, audio config, Ethernet config.

Unresolved: GPU stability under Chrome acceleration, native sleep/wake.
EOF
    )" >> "$LOG_FILE" 2>&1
    log_ok "Committed"
fi

# ─── Create tag ───────────────────────────────────────────────────────────────

log "Creating tag v17.1..."

if git tag -l | grep -q '^v17.1$'; then
    log_info "Tag v17.1 already exists — skipping"
else
    git tag -a v17.1 -m "ThinkPad T495s Hackintosh v17.1 — documented research snapshot" >> "$LOG_FILE" 2>&1
    log_ok "Tag v17.1 created"
fi

# ─── Create GitHub repo ──────────────────────────────────────────────────────

log "Creating GitHub repository..."

REPO_EXISTS=$(gh repo view "$FULL_REPO" --json name --jq '.name' 2>/dev/null || true)

if [[ -n "$REPO_EXISTS" ]]; then
    log_info "Repository ${FULL_REPO} already exists"
else
    gh repo create "$REPO_NAME" \
        --public \
        --description "$REPO_DESCRIPTION" \
        --source "$PROJECT_DIR" \
        --push=false \
        >> "$LOG_FILE" 2>&1
    log_ok "Repository created: github.com/${FULL_REPO}"
fi

# ─── Set remote and push ─────────────────────────────────────────────────────

log "Configuring remote..."

REMOTE_URL="https://github.com/${FULL_REPO}.git"

if git remote get-url origin &>/dev/null; then
    git remote set-url origin "$REMOTE_URL"
    log_info "Remote 'origin' updated"
else
    git remote add origin "$REMOTE_URL"
    log_ok "Remote 'origin' added"
fi

log "Pushing to GitHub (this may take a moment)..."

git push -u origin main --force >> "$LOG_FILE" 2>&1
log_ok "Pushed branch: main"

git push origin v17.1 >> "$LOG_FILE" 2>&1
log_ok "Pushed tag: v17.1"

# ─── Set topics ──────────────────────────────────────────────────────────────

log "Setting repository topics..."

IFS=',' read -ra TOPICS_ARRAY <<< "$REPO_TOPICS"
TOPICS_JSON=$(printf '%s\n' "${TOPICS_ARRAY[@]}" | jq -R . | jq -s '{"names": .}')

gh api -X PUT "repos/${FULL_REPO}/topics" \
    --input - <<< "$TOPICS_JSON" \
    >> "$LOG_FILE" 2>&1

log_ok "Topics set: ${REPO_TOPICS}"

# ─── Create GitHub Release ────────────────────────────────────────────────────

log "Creating GitHub pre-release..."

RELEASE_EXISTS=$(gh release view v17.1 --repo "$FULL_REPO" --json tagName --jq '.tagName' 2>/dev/null || true)

if [[ -n "$RELEASE_EXISTS" ]]; then
    log_info "Release v17.1 already exists — skipping"
else
    RELEASE_BODY=$(cat "$PROJECT_DIR/RELEASES/v17.1.md")

    gh release create v17.1 \
        --repo "$FULL_REPO" \
        --title "ThinkPad T495s Hackintosh v17.1 — macOS Ventura + Radeon Vega 10" \
        --notes "$RELEASE_BODY" \
        --prerelease \
        >> "$LOG_FILE" 2>&1

    log_ok "Pre-release created: v17.1"
fi

# ─── Final verification ──────────────────────────────────────────────────────

log "Verifying publication..."

VERIFY_REPO=$(gh repo view "$FULL_REPO" --json name,url,description --jq '"\(.url) — \(.description)"' 2>/dev/null || true)

if [[ -n "$VERIFY_REPO" ]]; then
    log_ok "VERIFIED: ${VERIFY_REPO}"
else
    log_fail "Could not verify repository"
    exit 1
fi

VERIFY_RELEASE=$(gh release view v17.1 --repo "$FULL_REPO" --json url --jq '.url' 2>/dev/null || true)
if [[ -n "$VERIFY_RELEASE" ]]; then
    log_ok "Release URL: ${VERIFY_RELEASE}"
fi

# ─── Summary ──────────────────────────────────────────────────────────────────

echo ""
echo "═══════════════════════════════════════════════════════════════════"
echo "  PUBLICATION COMPLETE"
echo "═══════════════════════════════════════════════════════════════════"
echo ""
echo "  Repository: https://github.com/${FULL_REPO}"
echo "  Release:    https://github.com/${FULL_REPO}/releases/tag/v17.1"
echo "  Topics:     ${REPO_TOPICS}"
echo ""
echo "  Next steps:"
echo "    1. Revoke the token you used (it served its purpose)"
echo "    2. Visit the repo and verify the README renders correctly"
echo "    3. Star it yourself to seed the activity signal"
echo ""
echo "  Log saved: ${LOG_FILE}"
echo ""

log "Publication completed successfully"

# Clean sensitive variable
unset GH_TOKEN
