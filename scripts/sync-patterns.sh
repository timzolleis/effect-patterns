#!/bin/bash
set -e

CONFIG="patterns.config.json"
PATTERNS_DIR="patterns"

# Check for jq
if ! command -v jq &> /dev/null; then
  echo "Error: jq is required but not installed."
  echo "Install with: brew install jq"
  exit 1
fi

# Check for config file
if [ ! -f "$CONFIG" ]; then
  echo "Error: $CONFIG not found."
  echo "Copy patterns.config.example.json from effect-patterns repo and customize."
  exit 1
fi

# Detect package manager from lock files
detect_package_manager() {
  if [ -f "bun.lock" ] || [ -f "bun.lockb" ]; then
    echo "bun"
  elif [ -f "pnpm-lock.yaml" ]; then
    echo "pnpm"
  elif [ -f "yarn.lock" ]; then
    echo "yarn"
  elif [ -f "package-lock.json" ]; then
    echo "npm"
  else
    # Default to npm if no lock file found
    echo "npm"
  fi
}

PKG_MANAGER=$(detect_package_manager)
echo "Detected package manager: $PKG_MANAGER"

# Read config
SOURCE=$(jq -r '.source' "$CONFIG")
REF=$(jq -r '.ref // "main"' "$CONFIG")

# Create temp dir
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

# Clone patterns repo
echo "Fetching patterns from $SOURCE (ref: $REF)..."
if [[ "$SOURCE" == github:* ]]; then
  REPO="${SOURCE#github:}"
  git clone --depth 1 --branch "$REF" "https://github.com/$REPO.git" "$TEMP_DIR" 2>/dev/null
elif [[ "$SOURCE" == /* ]]; then
  # Local path - just copy
  cp -r "$SOURCE"/* "$TEMP_DIR/"
else
  git clone --depth 1 --branch "$REF" "$SOURCE" "$TEMP_DIR" 2>/dev/null
fi

# Ensure patterns directory exists
mkdir -p "$PATTERNS_DIR"

# Extract variables as JSON for handlebars
VARIABLES=$(jq '.variables' "$CONFIG")

# Check if handlebars is available locally or globally
check_handlebars() {
  if [ -d "node_modules/handlebars" ]; then
    return 0
  fi
  if node -e "require('handlebars')" 2>/dev/null; then
    return 0
  fi
  return 1
}

# Install handlebars to temp directory if not available
if ! check_handlebars; then
  echo "Installing handlebars (temporary)..."
  npm install --prefix "$TEMP_DIR" handlebars --silent 2>/dev/null
  export NODE_PATH="$TEMP_DIR/node_modules"
fi

# Function to process a template
process_template() {
  local input_file="$1"
  local output_file="$2"

  # Create a temp file with the variables
  local vars_file=$(mktemp)
  echo "$VARIABLES" > "$vars_file"

  # Use node to process handlebars
  node -e "
    const fs = require('fs');
    const Handlebars = require('handlebars');

    const template = fs.readFileSync('$input_file', 'utf8');
    const variables = JSON.parse(fs.readFileSync('$vars_file', 'utf8'));

    const compiled = Handlebars.compile(template);
    const result = compiled(variables);

    fs.writeFileSync('$output_file', result);
  " || {
    echo "Warning: Failed to process $input_file, copying without template substitution"
    cp "$input_file" "$output_file"
  }

  rm -f "$vars_file"
}

# Process base patterns
echo "Processing patterns..."
pattern_count=0
for file in "$TEMP_DIR"/patterns/*.hbs; do
  [ -f "$file" ] || continue
  name=$(basename "$file" .hbs)

  # CLAUDE.md goes to repo root, not patterns directory
  if [ "$name" = "CLAUDE.md" ]; then
    echo "  - $name (-> repo root)"
    process_template "$file" "$name"
  else
    echo "  - $name"
    process_template "$file" "$PATTERNS_DIR/$name"
  fi
  ((pattern_count++))
done

# Process variants
echo "Processing variants..."
variant_count=0
for variant_type in $(jq -r '.variants | keys[]' "$CONFIG" 2>/dev/null || echo ""); do
  variant_value=$(jq -r ".variants.$variant_type" "$CONFIG")

  # Convert camelCase to kebab-case for directory lookup
  variant_dir=$(echo "$variant_type" | sed 's/\([A-Z]\)/-\L\1/g' | sed 's/^-//')
  variant_file="$TEMP_DIR/variants/$variant_dir/$variant_value.md.hbs"

  if [ -f "$variant_file" ]; then
    name="${variant_dir}-pattern.md"
    echo "  - $name (variant: $variant_value)"
    process_template "$variant_file" "$PATTERNS_DIR/$name"
    ((variant_count++))
  fi
done

echo ""
echo "Done! Synced $pattern_count patterns and $variant_count variants to $PATTERNS_DIR/"
