#!/bin/bash
# Run from FormDataReadDocumentIntelligence folder:  ./push-to-github.sh  or  bash push-to-github.sh
# If GitHub CLI is not logged in, you will be prompted: run   gh auth login

set -e
cd "$(dirname "$0")"

if [ ! -d .git ]; then
  git init
  git add -A
  git commit -m "Initial commit: FormDataReadDocumentIntelligence - train-model and test-model with Azure Document Intelligence"
fi

# Ensure we have at least one commit (e.g. if .git existed but was empty)
if ! git rev-parse --verify HEAD &>/dev/null; then
  git add -A
  git commit -m "Initial commit: FormDataReadDocumentIntelligence - train-model and test-model with Azure Document Intelligence"
fi

# Rename branch to main (Git may have created master)
git branch -M main 2>/dev/null || true

# Prompt for GitHub login if not authenticated
if ! gh auth status &>/dev/null; then
  echo "GitHub CLI is not logged in. Running: gh auth login"
  gh auth login
fi

# Create repo on GitHub and push (if repo already exists, just push)
if ! gh repo create FormDataReadDocumentIntelligence --public --source=. --remote=origin --push --description "Azure Document Intelligence - custom form train & test (C#)" 2>/dev/null; then
  echo "Repo may already exist. Pushing..."
  git remote add origin "https://github.com/$(gh api user -q .login)/FormDataReadDocumentIntelligence.git" 2>/dev/null || true
  # Push main, or current branch if main doesn't exist (e.g. master)
  git push -u origin main 2>/dev/null || git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
fi

echo "Done. Repo: https://github.com/$(gh api user -q .login)/FormDataReadDocumentIntelligence"
