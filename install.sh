
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Set global gitignore
GIG="$HOME/.config/git/ignore"
if [ ! -f "$GIG" ]; then
  mkdir -p "$(dirname "$GIG")"
  cat "$SCRIPT_DIR/.gitignore_global" > "$GIG"
fi

