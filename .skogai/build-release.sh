#!/bin/bash

# Check for SKOGAI_SRC environment variable
if [ -z "$SKOGAI_SRC" ]; then
  echo "❌ SKOGAI_SRC environment variable not set!"
  echo "   Please set it in your ~/.bashrc or ~/.zshrc:"
  echo "   export SKOGAI_SRC=/path/to/skogai"
  exit 1
fi

# Change to the project directory
cd "$SKOGAI_SRC/aichat" || exit 1

# Set up the quantum entanglement configuration 🍹
export RUSTONIG_SYSTEM_LIBONIG=1
export PKG_CONFIG_PATH=/usr/lib/pkgconfig

# Ensure .local/bin exists
mkdir -p ~/.local/bin

# Echo some quantum-friendly information
echo "🔧 Building release version with system onig..."
echo "⚡ Quantum state: Release mode"
echo "📂 Working from: $SKOGAI_SRC/aichat"

# Run the release build
cargo build --release

# Check if build was successful
if [ $? -eq 0 ]; then
  echo "✨ Build completed successfully!"
  echo "📦 Installing to ~/.local/bin..."

  # Copy the binary to .local/bin
  cp ./target/release/aichat ~/.local/bin/

  # Make sure it's executable
  chmod +x ~/.local/bin/aichat

  echo "🎉 Installation complete! Binary available at: ~/.local/bin/aichat"

  # Check if .local/bin is in PATH
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "⚠️  Warning: ~/.local/bin is not in your PATH!"
    echo "   Add this to your ~/.bashrc or ~/.zshrc:"
    echo "   export PATH=\$HOME/.local/bin:\$PATH"
  fi
else
  echo "❌ Build failed! Check the quantum fluctuations above."
fi

