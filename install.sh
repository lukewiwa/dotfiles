
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Link global gitignore
GIG="$HOME/.config/git/ignore"
if [ -f "$SCRIPT_DIR/.gitignore_global" ]; then
  mkdir -p "$(dirname "$GIG")"
  ln -sf "$SCRIPT_DIR/.gitignore_global" "$GIG"
fi

# Install Brewfile if brew is installed
if command -v brew &> /dev/null; then
  echo "Installing packages from Brewfile..."
  brew bundle install --file="$SCRIPT_DIR/Brewfile"
fi
# Link zsh aliases to home directory
if [ -f "$SCRIPT_DIR/.zsh_aliases" ]; then
  echo "Linking .zsh_aliases to ~/.zsh_aliases..."
  ln -sf "$SCRIPT_DIR/.zsh_aliases" "$HOME/.zsh_aliases"
  echo "Add 'source ~/.zsh_aliases' to your ~/.zshrc if not already present"
fi