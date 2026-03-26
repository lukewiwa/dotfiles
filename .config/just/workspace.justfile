# Dotfiles repo .justfile

# Set git user identity for this repo (stored in .git/config, not committed)
git-identity:
    #!/usr/bin/env bash
    read -p "Name: " name
    read -p "Email: " email
    git config user.name "$name"
    git config user.email "$email"
