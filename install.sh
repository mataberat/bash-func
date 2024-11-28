#!/bin/bash

# Detect the current shell
CURRENT_SHELL=$(basename "$SHELL")
RC_FILE=""

case "$CURRENT_SHELL" in
"zsh")
    RC_FILE="$HOME/.zshrc"
    ;;
"bash")
    RC_FILE="$HOME/.bashrc"
    ;;
*)
    echo "Detected shell: $CURRENT_SHELL"
    read -r -p "Enter the path to your shell RC file: " RC_FILE
    ;;
esac

# Get the absolute path of the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Add source commands to RC file with grouped redirects
{
    echo ""
    echo "# Kubernetes helper functions"
    echo "[ -f $SCRIPT_DIR/func.sh ] && source $SCRIPT_DIR/func.sh"
    echo "[ -f $SCRIPT_DIR/config.sh ] && source $SCRIPT_DIR/config.sh"
} >>"$RC_FILE"

echo "Installation complete! Helper functions added to $RC_FILE"
echo "Please restart your shell or run: source $RC_FILE"
