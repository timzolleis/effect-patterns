#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SKILLS_SOURCE="$REPO_ROOT/skills"
SKILLS_TARGET="$HOME/.claude/skills"

# Ensure target directory exists
mkdir -p "$SKILLS_TARGET"

echo "Installing skills from $SKILLS_SOURCE to $SKILLS_TARGET..."

installed=0
updated=0
unchanged=0

for skill_dir in "$SKILLS_SOURCE"/*/; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  target_dir="$SKILLS_TARGET/$skill_name"

  # Check if skill exists and has changes
  if [ -d "$target_dir" ]; then
    if diff -rq "$skill_dir" "$target_dir" > /dev/null 2>&1; then
      echo "  ✓ $skill_name (unchanged)"
      ((unchanged++))
      continue
    else
      echo "  ↻ $skill_name (updating)"
      ((updated++))
    fi
  else
    echo "  + $skill_name (new)"
    ((installed++))
  fi

  # Copy skill
  rm -rf "$target_dir"
  cp -r "$skill_dir" "$target_dir"
done

echo ""
echo "Done! $installed new, $updated updated, $unchanged unchanged"
