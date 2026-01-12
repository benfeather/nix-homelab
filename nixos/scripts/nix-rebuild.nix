{
  env,
  pkgs,
  ...
}:
let
  nix-rebuild = pkgs.writeShellScriptBin "nix-rebuild" ''
    # Check if running as root, if not re-run with sudo
    if [ "$EUID" -ne 0 ]; then
      echo "This script requires root privileges. Re-running with sudo..."
      exec sudo "$0" "$@"
    fi

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

    {env.root_dir}="/mnt/unraid/homelab#nixos"

    # Enhanced logging functions
    print_header() {
        echo -e "$BOLD$BLUE┌─────────────────────────────────────────────────────────────────────────────┐$NC"
        echo -e "$BOLD$BLUE│                        ❄️  NixOS Rebuild Tool                                │$NC"
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

    print_header

    print_section "🔧 System Rebuild" "Starting NixOS configuration rebuild..."
    log_warning "This operation may take several minutes..."
    log_step "Executing nixos-rebuild switch..."
    echo ""

    # Show a progress indicator
    echo -e "   $BOLD$CYAN🔄 Rebuilding NixOS System...$NC"
    echo -e "   $GRAY   Please wait while the system is being rebuilt$NC"
    echo ""

    if nixos-rebuild switch --flake "${env.root_dir}"; then
      echo ""
      log_success "NixOS rebuild completed successfully! 🎉"

      print_section "ℹ️  Post-Rebuild Information" "Important notes about the system update..."
      log_info "System configuration has been updated and applied"
      log_warning "Some services may need to be restarted to use new versions"
      log_warning "A reboot may be required for kernel or systemd changes"

      echo ""
      print_separator
      echo -e "  $BOLD$GREEN🎉 System Rebuild Completed Successfully! 🎉$NC"
      print_separator
      echo -e "  $CYAN❄️  NixOS:$NC $WHITE""System is now running the latest configuration""$NC"
      echo -e "  $CYAN🔗 Flake:$NC $WHITE${env.root_dir}$NC"
      echo ""

    else
      echo ""
      log_error "NixOS rebuild failed!"

      print_section "🚨 Troubleshooting" "Common issues and solutions..."
      echo -e "   $YELLOW   Common causes of rebuild failures:$NC"
      echo -e "   $GRAY   • Syntax errors in configuration files (.nix files)$NC"
      echo -e "   $GRAY   • Missing or invalid flake inputs in flake.nix$NC"
      echo -e "   $GRAY   • Network connectivity issues (downloading packages)$NC"
      echo -e "   $GRAY   • Insufficient disk space for new packages$NC"
      echo -e "   $GRAY   • Conflicting package versions or dependencies$NC"
      echo ""
      log_warning "Check the error messages above for specific details"

      echo ""
      print_separator
      echo -e "  $BOLD$RED❌ System Rebuild Failed$NC"
      print_separator
      echo -e "  $CYAN🔍 Next Steps:$NC $WHITE""Review error messages and fix configuration issues""$NC"
      echo ""
      exit 1
    fi
  '';
in
{
  environment.systemPackages = [
    nix-rebuild
  ];
}
