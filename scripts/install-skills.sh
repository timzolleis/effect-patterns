#!/bin/bash
set -e

SKILLS_TARGET="$HOME/.claude/skills"
DEFAULT_SOURCE="github:timzolleis/effect-patterns"
DEFAULT_REF="main"

# Parse arguments
SOURCE="${1:-$DEFAULT_SOURCE}"
REF="${2:-$DEFAULT_REF}"

# Create temp dir for cloning
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Fetch skills source
echo "Fetching skills from $SOURCE (ref: $REF)..."
if [[ "$SOURCE" == github:* ]]; then
  REPO="${SOURCE#github:}"
  git clone --depth 1 --branch "$REF" "https://github.com/$REPO.git" "$TEMP_DIR" 2>/dev/null
elif [[ "$SOURCE" == /* ]]; then
  # Local path - just copy
  cp -r "$SOURCE"/* "$TEMP_DIR/"
else
  git clone --depth 1 --branch "$REF" "$SOURCE" "$TEMP_DIR" 2>/dev/null
fi

SKILLS_SOURCE="$TEMP_DIR/skills"

# Ensure target directory exists
mkdir -p "$SKILLS_TARGET"

echo "Installing skills to $SKILLS_TARGET..."

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
