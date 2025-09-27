{
  pkgs,
  ...
}:
let
  nix-update = pkgs.writeShellScriptBin "nix-update" ''
    # Color definitions
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
    GRAY='\033[0;90m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color

    FLAKE_PATH="/mnt/unraid/homelab"
    FLAKE_TARGET="$FLAKE_PATH#nixos"

    # Enhanced logging functions
    print_header() {
        echo -e "$BOLD$BLUE┌─────────────────────────────────────────────────────────────────────────────┐$NC"
        echo -e "$BOLD$BLUE│                        🔄 Nix Flake Update Tool                             │$NC"
        echo -e "$BOLD$BLUE└─────────────────────────────────────────────────────────────────────────────┘$NC"
        echo ""
    }

    print_section() {
        echo ""
        echo -e "$BOLD$PURPLE▶  $1$NC"
        echo -e "$GRAY   $2$NC"
    }

    log_info() {
        echo -e "$CYAN   ℹ  $NC$WHITE$1$NC"
    }

    log_success() {
        echo -e "$GREEN   ✓  $NC$WHITE$1$NC"
    }

    log_warning() {
        echo -e "$YELLOW   ⚠  $NC$WHITE$1$NC"
    }

    log_error() {
        echo -e "$RED   ✗  $NC$WHITE$1$NC"
    }

    log_step() {
        echo -e "$BLUE   →  $NC$WHITE$1$NC"
    }

    print_separator() {
        echo -e "$GRAY─────────────────────────────────────────────────────────────────────────────$NC"
    }

    print_config_summary() {
        echo ""
        print_separator
        echo -e "  $BOLD$WHITE🔄 Update Configuration$NC"
        print_separator
        echo -e "  $CYAN📁 Flake Path:$NC   $WHITE$FLAKE_PATH$NC"
        echo -e "  $CYAN🎯 Flake Target:$NC $WHITE$FLAKE_TARGET$NC"
        echo -e "  $CYAN⚙️  Operations:$NC   $WHITE""Update inputs → Rebuild system""$NC"
        print_separator
        echo ""
    }

    print_header
    print_config_summary

    print_section "🔍 Validation" "Checking flake configuration and paths..."

    log_step "Validating flake directory..."
    # Check if flake directory exists
    if [ ! -d "$FLAKE_PATH" ]; then
        log_error "Flake directory '$FLAKE_PATH' does not exist!"
        exit 1
    fi
    log_success "Flake directory exists and is accessible"

    log_step "Checking for flake.nix file..."
    # Check if flake.nix exists
    if [ ! -f "$FLAKE_PATH/flake.nix" ]; then
        log_error "flake.nix not found in '$FLAKE_PATH'!"
        exit 1
    fi
    log_success "flake.nix found and ready"

    log_step "Changing to flake directory..."
    # Change to flake directory
    cd "$FLAKE_PATH" || {
        log_error "Cannot change to flake directory '$FLAKE_PATH'"
        exit 1
    }
    log_success "Working directory set to flake path"

    print_section "📦 Updating Flake Inputs" "Fetching latest versions of all flake inputs..."
    log_step "Running nix flake update..."
    echo ""

    echo -e "   $BOLD$CYAN🔄 Updating Flake Inputs...$NC"
    echo -e "   $GRAY   This may take a moment to fetch latest versions$NC"
    echo ""

    if nix flake update; then
        echo ""
        log_success "Flake inputs updated successfully!"
    else
        echo ""
        log_error "Failed to update flake inputs"
        exit 1
    fi

    print_section "🔧 System Rebuild" "Rebuilding NixOS with updated packages..."
    log_warning "This operation may take several minutes..."

    # Check if we need sudo for nixos-rebuild
    if [ "$EUID" -ne 0 ]; then
        log_step "NixOS rebuild requires root privileges..."
        echo ""
        echo -e "   $BOLD$CYAN🔄 Rebuilding NixOS System...$NC"
        echo -e "   $GRAY   Please wait while the system is being rebuilt$NC"
        echo ""

        if sudo nixos-rebuild switch --flake "$FLAKE_TARGET"; then
            echo ""
            log_success "System updated and rebuilt successfully! 🎉"
        else
            echo ""
            log_error "NixOS rebuild failed after updating packages"
            echo ""
            log_warning "The flake inputs were updated, but the system rebuild failed"
            log_info "You can try running 'nix-rebuild' separately to retry the rebuild"
            exit 1
        fi
    else
        echo ""
        echo -e "   $BOLD$CYAN🔄 Rebuilding NixOS System...$NC"
        echo -e "   $GRAY   Please wait while the system is being rebuilt$NC"
        echo ""

        if nixos-rebuild switch --flake "$FLAKE_TARGET"; then
            echo ""
            log_success "System updated and rebuilt successfully! 🎉"
        else
            echo ""
            log_error "NixOS rebuild failed after updating packages"
            exit 1
        fi
    fi

    print_section "ℹ️  Post-Update Information" "Important notes about the system update..."
    log_success "Flake inputs updated to latest versions"
    log_success "System rebuilt with new packages"
    log_success "All changes applied successfully"
    echo ""
    log_warning "You may want to consider the following:"
    echo -e "   $GRAY   • Restart services that were updated$NC"
    echo -e "   $GRAY   • Reboot if kernel or core system components were updated$NC"
    echo -e "   $GRAY   • Use rollback if issues occur: nixos-rebuild switch --rollback$NC"

    echo ""
    print_separator
    echo -e "  $BOLD$GREEN🎉 Nix Update Completed Successfully! 🎉$NC"
    print_separator
    echo -e "  $CYAN🔄 Updated:$NC  $WHITE""Flake inputs → System packages""$NC"
    echo -e "  $CYAN🎯 Target:$NC   $WHITE$FLAKE_TARGET$NC"
    echo -e "  $CYAN💡 Rollback:$NC $WHITE""nixos-rebuild switch --rollback (if needed)""$NC"
    echo ""
  '';
in
{
  environment.systemPackages = [
    nix-update
  ];
}
