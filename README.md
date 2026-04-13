# Wiwa's dotfiles

macOS-focused dotfiles. Installs Homebrew packages from Brewfile, provides zsh aliases, a global justfile, and Hammerspoon config for window management.

## Install (macOS)

Clone and run the install script:

```bash
git clone https://github.com/lukewiwa/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

The script will:
- Install Homebrew packages from Brewfile (if brew present)
- Symlink zsh aliases and dotfiles
- Install a global justfile to ~/.justfile
- Install Hammerspoon config to ~/.hammerspoon/init.lua (and reload Hammerspoon if running)

## Files of interest

- Brewfile — Homebrew packages and casks (includes hammerspoon)
- .config/zsh/dotfiles.zsh — zsh aliases and helpers
- templates/global.justfile — global justfile installed to ~/.justfile
- hammerspoon/init.lua — Hammerspoon config for window management

## Notes

- Installer is idempotent and will back up existing files before replacing.
- Hammerspoon requires Accessibility permissions; enable it in System Settings -> Privacy & Security -> Accessibility.
