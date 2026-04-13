#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKIP_BREW_INSTALL=0

for arg in "$@"; do
    case "$arg" in
        --skip-brew-install)
            SKIP_BREW_INSTALL=1
            ;;
        -h|--help)
            echo "Usage: $0 [--skip-brew-install]"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg" >&2
            echo "Usage: $0 [--skip-brew-install]" >&2
            exit 1
            ;;
    esac
done

echo "Installing dotfiles..."

if [ "$SKIP_BREW_INSTALL" -eq 1 ]; then
    echo "Skipping Homebrew install (--skip-brew-install)"
else
    echo "Installing Homebrew..."
    SHELL="/bin/zsh" /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi


# Install Homebrew packages
echo "Installing packages from Brewfile..."
brew bundle --file="${SCRIPT_DIR}/Brewfile"


# Link config files
echo "Linking config files..."
link_file() {
    local src="${SCRIPT_DIR}/${1}" dest="${HOME}/${2:-$1}"
    if [ -f "$src" ]; then
        mkdir -p "$(dirname "$dest")"
        ln -sf "$src" "$dest"
        echo "Linked ${dest} -> ${src}"
    else
        echo "Skipped missing source: ${src}"
    fi
}

link_file ".gitignore_global" ".config/git/ignore"
link_file ".config/lazygit/config.yml" ".config/lazygit/config.yml"
link_file ".config/just/justfile" ".config/just/justfile"
link_file "hammerspoon/init.lua" ".hammerspoon/init.lua"

# Install just completions
if command -v just &> /dev/null; then
    echo "Installing just completions..."
    mkdir -p "${HOME}/.oh-my-zsh/completions"
    just --completions zsh > "${HOME}/.oh-my-zsh/completions/_just"
    cat "${SCRIPT_DIR}/.config/zsh/completions/_wust" > "${HOME}/.oh-my-zsh/completions/_wust"
    echo "Installed zsh completions for just and wust"
else
    echo "Skipping just completions: just not found"
fi

# Configure git
echo "Configuring git..."
DOT_GITCONFIG="${SCRIPT_DIR}/.gitconfig"

if git config --global --get-all include.path | grep -Fxq "${DOT_GITCONFIG}"; then
    echo "Git include already present"
else
    git config --global --add include.path "${DOT_GITCONFIG}"
    echo "Added dotfiles include"
fi


# Configure zsh
echo "Configuring zsh..."
shell_rc="${HOME}/.zshrc"
[ -f "$shell_rc" ] || touch "$shell_rc"
grep -q "# dotfiles-setup" "$shell_rc" && sed -i.bak "/# dotfiles-setup/,/# end dotfiles-setup/d" "$shell_rc"
cat >> "$shell_rc" << 'EOF'

# dotfiles-setup
[ -f "${HOME}/.dotfiles/.config/zsh/dotfiles.zsh" ] && source "${HOME}/.dotfiles/.config/zsh/dotfiles.zsh"
# end dotfiles-setup
EOF

echo "Done!"
