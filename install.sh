#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles..."

# Detect OS
OS="$(uname -s)"
case "$OS" in
    Darwin*)
        OS_NAME="macOS"
        ;;
    Linux*)
        OS_NAME="Linux"
        ;;
    *)
        OS_NAME="Unknown"
        ;;
esac
echo "Detected OS: $OS_NAME"

# Install mise if not present
if ! command -v mise &> /dev/null; then
    echo "mise not found, installing..."
    echo "Installing mise via official installer..."
    curl https://mise.run | sh

    # Add mise to PATH for current session
    export PATH="${HOME}/.local/bin:${PATH}"

    # Verify installation
    if ! command -v mise &> /dev/null; then
        echo "ERROR: mise installation failed"
        exit 1
    fi
    echo "mise installed successfully"
else
    echo "mise already installed"
fi

# Link global mise config
echo "Linking mise config..."
MISE_CONFIG_DIR="${HOME}/.config/mise"
mkdir -p "$MISE_CONFIG_DIR"
ln -sf "${SCRIPT_DIR}/.config/mise/config.toml" "${MISE_CONFIG_DIR}/config.toml"
echo "  Linked: ${MISE_CONFIG_DIR}/config.toml"
ln -sf "${SCRIPT_DIR}/.config/mise/config.work.toml" "${MISE_CONFIG_DIR}/config.work.toml"
echo "  Linked: ${MISE_CONFIG_DIR}/config.work.toml"
ln -sf "${SCRIPT_DIR}/.config/mise/mise.lock" "${MISE_CONFIG_DIR}/mise.lock"
echo "  Linked: ${MISE_CONFIG_DIR}/mise.lock"
ln -sf "${SCRIPT_DIR}/.config/mise/mise.work.lock" "${MISE_CONFIG_DIR}/mise.work.lock"
echo "  Linked: ${MISE_CONFIG_DIR}/mise.work.lock"

# Set mise env — work tools are enabled unless running inside a dev container
if [ "${REMOTE_CONTAINERS:-}" = "true" ]; then
    echo "Dev container detected, skipping work profile"
else
    echo "Work machine detected, enabling work profile"
    export MISE_ENV="work"
fi

# Install tools from global mise config
echo "Installing tools via mise..."
mise install --yes
# Activate for current shell session
eval "$(mise activate bash)"

# Install just completions
echo "Installing just completions..."
if command -v just &> /dev/null; then
    mkdir -p "${HOME}/.oh-my-zsh/completions"
    just --completions zsh > "${HOME}/.oh-my-zsh/completions/_just"
    echo "  Installed just completions"
    cp "${SCRIPT_DIR}/.config/zsh/completions/_wust" "${HOME}/.oh-my-zsh/completions/_wust"
    echo "  Installed wust completions"
else
    echo "  just not found, skipping completions"
fi

# Symlink dotfiles
echo "Linking dotfiles..."

link_file() {
    local src="${SCRIPT_DIR}/${1}"
    local dest="${HOME}/${2:-$1}"

    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        ln -sf "$src" "$dest"
        echo "  Linked: $dest"
    fi
}

link_file ".gitconfig"
link_file ".gitignore_global" ".config/git/ignore"
link_file ".config/lazygit/config.yml" ".config/lazygit/config.yml"
link_file ".config/just/justfile" ".config/just/justfile"

if [ -n "${CONTAINER_WORKSPACE_FOLDER:-}" ] && [ ! -f "${CONTAINER_WORKSPACE_FOLDER}/.justfile" ]; then
    cp "${SCRIPT_DIR}/.config/just/workspace.justfile" "${CONTAINER_WORKSPACE_FOLDER}/.justfile"
    echo "  Copied workspace.justfile to: ${CONTAINER_WORKSPACE_FOLDER}/.justfile"
fi

# Setup zsh integration
setup_shell() {
    local shell_rc="${HOME}/.zshrc"
    local marker="# dotfiles-setup"

    # Remove existing dotfiles block if present
    if grep -q "$marker" "$shell_rc" 2>/dev/null; then
        sed -i.bak "/$marker/,/^# end dotfiles-setup$/d" "$shell_rc"
    fi

    echo "Configuring zsh..."
    cat >> "$shell_rc" << EOF

# dotfiles-setup
export PATH="\${HOME}/.local/bin:\${PATH}"

# Machine profile — work tools enabled unless inside a dev container
if [ "\${REMOTE_CONTAINERS:-}" != "true" ]; then
    export MISE_ENV="work"
fi

# mise (provides tools, aliases, and environment)
eval "\$(mise activate zsh)"

# wust (global justfile) completions
setopt COMPLETE_ALIASES
compdef _wust wust
# end dotfiles-setup
EOF
    echo "  Updated: $shell_rc"
}

setup_shell

echo "Done! Tools installed:"
mise list
