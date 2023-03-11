#!/bin/bash

# Check if Rust is installed
if ! command -v rustc &> /dev/null; then
    echo "Rust not found. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
    # Activate the default toolchain
    source "$HOME/.cargo/env"
else
    echo "Rust already installed. Skipping installation..."
fi

# Determine if the current machine is a server or a client
if hostname | grep -q "wg"; then
    target="server"
else
    target="client"
fi

# Install Innernet
TAG=$(curl --silent "https://api.github.com/repos/tonarino/innernet/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")')
cargo install --git https://github.com/tonarino/innernet --tag $TAG $target

# Start the Innernet daemon if the machine is a server
if [ "$target" = "server" ]; then
    sudo innernet server start
fi

# Check if the installation was successful
if ! command -v innernet &> /dev/null; then
    echo "Innernet installation failed"
    exit 1
fi

echo "Innernet installation complete."
