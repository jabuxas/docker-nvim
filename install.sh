#!/bin/bash

set -e

IMAGE_NAME="docker-nvim"
ALIAS_NAME="v"

echo "🔧 Building docker-nvim image..."
docker build -t "$IMAGE_NAME" "$(dirname "$0")"

echo "✅ Image built successfully!"

# Generate the alias command
ALIAS_CMD="alias $ALIAS_NAME='docker run --rm -it -v \"\$(pwd)\":/workspace -w /workspace -e TERM=xterm-256color $IMAGE_NAME nvim'"

echo ""
echo "📝 Add this alias to your shell config (. bashrc, .zshrc, etc.):"
echo ""
echo "  $ALIAS_CMD"
echo ""

# Ask user if they want to auto-add to shell config
read -p "Do you want to add this alias to your shell config automatically? [y/N] " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Detect shell
    SHELL_NAME=$(basename "$SHELL")
    
    case "$SHELL_NAME" in
        bash)
            RC_FILE="$HOME/.bashrc"
            ;;
        zsh)
            RC_FILE="$HOME/.zshrc"
            ;;
        fish)
            # Fish uses different alias syntax
            FISH_ALIAS="alias $ALIAS_NAME 'docker run --rm -it -v (pwd):/workspace -w /workspace -e TERM=xterm-256color $IMAGE_NAME nvim'"
            RC_FILE="$HOME/.config/fish/config. fish"
            ALIAS_CMD="$FISH_ALIAS"
            ;;
        *)
            echo "⚠️  Unknown shell:  $SHELL_NAME.  Please add the alias manually."
            exit 0
            ;;
    esac
    
    # Check if alias already exists
    if grep -q "alias $ALIAS_NAME=" "$RC_FILE" 2>/dev/null; then
        echo "⚠️  Alias '$ALIAS_NAME' already exists in $RC_FILE.  Skipping."
    else
        echo "" >> "$RC_FILE"
        echo "# docker-nvim alias" >> "$RC_FILE"
        echo "$ALIAS_CMD" >> "$RC_FILE"
        echo "✅ Alias added to $RC_FILE"
        echo ""
        echo "🔄 Run 'source $RC_FILE' or restart your terminal to use '$ALIAS_NAME'"
    fi
fi

echo ""
echo "🚀 Usage: $ALIAS_NAME [file] [options]"
echo "   Example: $ALIAS_NAME ."
echo "   Example: $ALIAS_NAME myfile.txt"
