{
  pkgs,
  ...
}:
let
  nix-update = pkgs.writeShellScriptBin "nix-update" ''
    FLAKE_PATH="/mnt/unraid/homelab"
    FLAKE_TARGET="$FLAKE_PATH#nixos"

    echo "=== Nix Update ==="
    echo ""
    echo "Flake: $FLAKE_PATH"
    echo ""

    # Check if flake directory exists
    if [ ! -d "$FLAKE_PATH" ]; then
        echo "Error: Flake directory '$FLAKE_PATH' does not exist!"
        exit 1
    fi

    # Check if flake.nix exists
    if [ ! -f "$FLAKE_PATH/flake.nix" ]; then
        echo "Error: flake.nix not found in '$FLAKE_PATH'!"
        exit 1
    fi

    # Change to flake directory
    cd "$FLAKE_PATH" || {
        echo "Error: Cannot change to flake directory '$FLAKE_PATH'"
        exit 1
    }

    echo "1. Updating flake inputs..."
    if nix flake update; then
        echo "   ✓ Flake inputs updated successfully"
    else
        echo "   ✗ Failed to update flake inputs"
        exit 1
    fi

    echo ""
    echo "2. Showing what changed..."
    if [ -f "flake.lock" ]; then
        echo "   Recent lock file changes:"
        git log -1 --oneline flake.lock 2>/dev/null || echo "   (git not available or no previous commits)"
    else
        echo "   No flake.lock file found"
    fi

    echo ""
    echo "3. Starting NixOS rebuild with updated packages..."

    # Check if we need sudo for nixos-rebuild
    if [ "$EUID" -ne 0 ]; then
        echo "   NixOS rebuild requires root privileges..."
        if sudo nixos-rebuild switch --flake "$FLAKE_TARGET"; then
            echo ""
            echo "   ✓ System updated and rebuilt successfully!"
        else
            echo ""
            echo "   ✗ NixOS rebuild failed after updating packages"
            echo ""
            echo "The flake inputs were updated, but the system rebuild failed."
            echo "You can try running 'nix-rebuild' separately to retry the rebuild."
            exit 1
        fi
    else
        if nixos-rebuild switch --flake "$FLAKE_TARGET"; then
            echo ""
            echo "   ✓ System updated and rebuilt successfully!"
        else
            echo ""
            echo "   ✗ NixOS rebuild failed after updating packages"
            exit 1
        fi
    fi

    echo ""
    echo "=== Update Complete ==="
    echo ""
    echo "Summary:"
    echo "  • Flake inputs updated to latest versions"
    echo "  • System rebuilt with new packages"
    echo "  • All changes applied"
    echo ""
    echo "You may want to:"
    echo "  • Restart services that were updated"
    echo "  • Reboot if kernel or core system components were updated"
    echo "  • Check 'nixos-rebuild switch --flake $FLAKE_TARGET --rollback' if issues occur"
  '';
in
{
  environment.systemPackages = [
    nix-update
  ];
}
