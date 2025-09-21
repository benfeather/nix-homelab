{
  pkgs,
  ...
}:
let
  nix-rebuild = pkgs.writeShellScriptBin "nix-rebuild" ''
        #!/bin/bash

    # Check if running as root, if not re-run with sudo
    if [ "$EUID" -ne 0 ]; then
        echo "NixOS rebuild requires root privileges. Re-running with sudo..."
        exec sudo "$0" "$@"
    fi

    FLAKE_PATH="/mnt/unraid/homelab#nixos"

    echo "=== NixOS Rebuild ==="
    echo ""
    echo "Flake: $FLAKE_PATH"
    echo ""

    # Extract flake directory by removing everything after #
    FLAKE_DIR=$(echo "$FLAKE_PATH" | sed 's/#.*$//')

    # Check if flake path exists
    if [ ! -d "$FLAKE_DIR" ]; then
        echo "Error: Flake directory '$FLAKE_DIR' does not exist!"
        echo "Please ensure the path '$FLAKE_PATH' is correct and accessible."
        exit 1
    fi

    # Check if flake.nix exists
    if [ ! -f "$FLAKE_DIR/flake.nix" ]; then
        echo "Error: flake.nix not found in '$FLAKE_DIR'!"
        exit 1
    fi

    echo "1. Validating flake configuration..."
    if ! nix flake check "$FLAKE_PATH" 2>/dev/null; then
        echo "   Warning: Flake check failed, but continuing with rebuild..."
    else
        echo "   ✓ Flake configuration is valid"
    fi

    echo ""
    echo "2. Starting NixOS rebuild..."
    echo "   This may take several minutes..."

    if nixos-rebuild switch --flake "$FLAKE_PATH"; then
        echo ""
        echo "   ✓ NixOS rebuild completed successfully!"
        echo ""
        echo "System has been updated. You may need to restart some services"
        echo "or reboot for all changes to take effect."
    else
        echo ""
        echo "   ✗ NixOS rebuild failed!"
        echo ""
        echo "Check the error messages above for details."
        echo "Common issues:"
        echo "  - Syntax errors in configuration files"
        echo "  - Missing or invalid flake inputs"
        echo "  - Network connectivity issues"
        exit 1
    fi
  '';
in
{
  environment.systemPackages = [
    nix-rebuild
  ];
}
