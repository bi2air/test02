#!/usr/bin/env bash
set -euo pipefail

REPO="/Users/binh.nguyen2/working/postcall/agi-sm-dsci-configs"
BRANCH="pr-346"

FILES=(
  "scripts/en_collin_kompato_affirm/main.yaml"
  "scripts/en_collin_kompato_affirm/golden_cases.yaml"
  "scripts/en_collin_kompato_affirm/PR346_patch_report_AGI-9466.md"
)

DEFAULT_MSG="AGI-9466: refine postcall call-code boundaries, stage cues, and golden test pack"
COMMIT_MSG="${1:-$DEFAULT_MSG}"
PUSH_MODE="${2:-push}"  # push | dry-run

if [[ ! -d "$REPO/.git" ]]; then
  echo "ERROR: Repo not found: $REPO" >&2
  exit 1
fi

current_branch="$(git -C "$REPO" branch --show-current)"
if [[ "$current_branch" != "$BRANCH" ]]; then
  echo "ERROR: Current branch is '$current_branch'. Expected '$BRANCH'." >&2
  echo "Run: git -C "$REPO" checkout $BRANCH" >&2
  exit 1
fi

echo "==> Branch: $current_branch"
echo "==> Staging files"
for f in "${FILES[@]}"; do
  if [[ -f "$REPO/$f" ]]; then
    git -C "$REPO" add "$f"
    echo "  + $f"
  else
    echo "  - missing (skip): $f"
  fi
done

if git -C "$REPO" diff --cached --quiet; then
  echo "No newly staged changes for target files. Skip commit."
else
  echo "==> Staged summary"
  git -C "$REPO" diff --cached --name-status

  echo "==> Commit"
  git -C "$REPO" commit -m "$COMMIT_MSG"
fi

if [[ "$PUSH_MODE" == "dry-run" ]]; then
  echo "==> Push (dry-run)"
  git -C "$REPO" push --dry-run origin "$BRANCH"
else
  echo "==> Push"
  git -C "$REPO" push origin "$BRANCH"
fi

echo "Done."
