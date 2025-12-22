
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Set global gitignore
GIG="$HOME/.config/git/ignore"
if [ ! -f "$GIG" ]; then
  mkdir -p "$(dirname "$GIG")"
  cat "$SCRIPT_DIR/.gitignore_global" > "$GIG"
fi

# Install Brewfile if brew is installed
if command -v brew &> /dev/null; then
  echo "Installing packages from Brewfile..."
  brew bundle install --file="$SCRIPT_DIR/Brewfile"
fi
