#!/bin/bash

# Default installation path
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="script"  # You can change this to whatever you want the script to be called

# Check if the user passed a custom install directory
if [ "$1" ]; then
    INSTALL_DIR="$1"
fi

# Move the script to the installation directory
echo "Moving script.sh to $INSTALL_DIR/$SCRIPT_NAME"
sudo mv script.sh "$INSTALL_DIR/$SCRIPT_NAME"

# Make sure the script is executable
echo "Making the script executable"
sudo chmod +x "$INSTALL_DIR/$SCRIPT_NAME"

# Verify if the directory is in the user's PATH
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "Adding $INSTALL_DIR to your PATH"

    # Check if the user is using bash or zsh and add to the appropriate shell profile
    if [ -n "$BASH_VERSION" ]; then
        echo "export PATH=\$PATH:$INSTALL_DIR" >> ~/.bashrc
        source ~/.bashrc
    elif [ -n "$ZSH_VERSION" ]; then
        echo "export PATH=\$PATH:$INSTALL_DIR" >> ~/.zshrc
        source ~/.zshrc
    fi

    echo "$INSTALL_DIR has been added to your PATH. Please restart your terminal or run 'source ~/.bashrc' or 'source ~/.zshrc' depending on your shell."
else
    echo "$INSTALL_DIR is already in your PATH"
fi

echo "Installation complete! You can now run the script with the command: $SCRIPT_NAME"
