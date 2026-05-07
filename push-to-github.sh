#!/usr/bin/env bash
# ============================================================
# push-to-github.sh — Carnegie Title
#
# Initializes git in this folder (if needed), points the remote
# at the Carnegie Title repository, commits the current state,
# and force-pushes to main.
#
# Usage:
#   chmod +x push-to-github.sh
#   ./push-to-github.sh "Optional commit message"
# ============================================================

set -euo pipefail

REPO_URL="https://github.com/AaronPilk/Carnegie-Title.git"
BRANCH="main"
COMMIT_MSG="${1:-Update Carnegie Title site}"

cd "$(dirname "$0")"

echo "→ Working directory: $(pwd)"
echo "→ Target remote:     $REPO_URL"
echo "→ Target branch:     $BRANCH"
echo

# 1. Initialize repo if not already a git repo
if [ ! -d ".git" ]; then
  echo "→ Initializing git repository..."
  git init -b "$BRANCH"
else
  echo "→ Git repository already initialized."
  # Make sure we're on the right branch name
  current_branch="$(git symbolic-ref --short HEAD 2>/dev/null || echo '')"
  if [ "$current_branch" != "$BRANCH" ]; then
    echo "→ Renaming current branch '$current_branch' to '$BRANCH'..."
    git branch -M "$BRANCH"
  fi
fi

# 2. Configure remote
if git remote get-url origin >/dev/null 2>&1; then
  current_url="$(git remote get-url origin)"
  if [ "$current_url" != "$REPO_URL" ]; then
    echo "→ Updating origin from $current_url to $REPO_URL"
    git remote set-url origin "$REPO_URL"
  else
    echo "→ Origin already points at $REPO_URL"
  fi
else
  echo "→ Adding origin → $REPO_URL"
  git remote add origin "$REPO_URL"
fi

# 3. Stage and commit
echo "→ Staging changes..."
git add -A

if git diff --cached --quiet; then
  echo "→ No changes to commit. Continuing to push current HEAD."
else
  echo "→ Committing: \"$COMMIT_MSG\""
  git -c user.name="Carnegie Title" -c user.email="orders@carnegie-title.com" commit -m "$COMMIT_MSG"
fi

# 4. Force-push to overwrite remote
echo "→ Force-pushing to $REPO_URL ($BRANCH)..."
git push -u --force origin "$BRANCH"

echo
echo "✓ Push complete."
echo "  Repo: $REPO_URL"
echo "  Live (after Pages enabled): https://www.carnegie-title.com"
