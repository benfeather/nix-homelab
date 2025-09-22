{
  pkgs,
  ...
}:
let
  fix-permissions = pkgs.writeShellScriptBin "fix-permissions" ''
    # Check if running as root, if not re-run with sudo
    if [ "$EUID" -ne 0 ]; then
      echo "This script requires root privileges. Re-running with sudo..."
      echo ""
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

    # Configurable paths and settings
    BASE_PATH="/mnt/unraid/homelab"
    SECRETS_PATH="$BASE_PATH/nixos/secrets"
    BASE_USER="nixos"
    BASE_GROUP="users"
    SECRETS_GROUP="docker"
    DIR_PERMISSIONS="755"
    FILE_PERMISSIONS="644"
    SECRETS_FILE_PERMISSIONS="600"

    # Enhanced logging functions
    print_header() {
        echo -e "$BOLD$BLUE┌─────────────────────────────────────────────────────────────────────────────┐$NC"
        echo -e "$BOLD$BLUE│                       🔐 Permission Management Tool                         │$NC"
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
        echo -e "  $BOLD$WHITE🔐 Permission Configuration$NC"
        print_separator
        echo -e "  $CYAN📁 Base Path:$NC        $WHITE$BASE_PATH$NC"
        echo -e "  $CYAN🔒 Secrets Path:$NC     $WHITE$SECRETS_PATH$NC"
        echo -e "  $CYAN👤 Base Owner:$NC       $WHITE$BASE_USER:$BASE_GROUP$NC"
        echo -e "  $CYAN👤 Secrets Owner:$NC    $WHITE$BASE_USER:$SECRETS_GROUP$NC"
        echo -e "  $CYAN📂 Dir Permissions:$NC  $WHITE$DIR_PERMISSIONS$NC"
        echo -e "  $CYAN📄 File Permissions:$NC $WHITE$FILE_PERMISSIONS$NC"
        echo -e "  $CYAN🔐 Secret Files:$NC     $WHITE$SECRETS_FILE_PERMISSIONS$NC"
        print_separator
        echo ""
    }

    usage() {
        print_header
        echo -e "$BOLD"Usage:"$NC $0"
        echo ""
        echo -e "$BOLD$WHITE"Description:"$NC"
        echo -e "  Sets proper ownership and permissions for homelab directories"
        echo ""
        echo -e "$BOLD$WHITE"What this script does:"$NC"
        echo -e "  $GRAY• Sets ownership of base directory to $BASE_USER:$BASE_GROUP$NC"
        echo -e "  $GRAY• Sets directory permissions to $DIR_PERMISSIONS and file permissions to $FILE_PERMISSIONS$NC"
        echo -e "  $GRAY• Sets secrets directory ownership to $BASE_USER:$SECRETS_GROUP$NC" 
        echo -e "  $GRAY• Sets secrets file permissions to $SECRETS_FILE_PERMISSIONS (more restrictive)$NC"
        echo ""
        echo -e "$BOLD$WHITE"Configuration:"$NC"
        echo -e "  $GRAY• Modify variables at the top of the script to change paths/permissions$NC"
        echo ""
        exit 0
    }

    # Show usage if help is requested
    if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
        usage
    fi

    print_header
    print_config_summary

    print_section "🔍 Validation" "Checking paths and prerequisites..."

    log_step "Validating base directory..."
    if [ ! -d "$BASE_PATH" ]; then
        log_error "Base directory '$BASE_PATH' does not exist!"
        exit 1
    fi
    log_success "Base directory exists"

    log_step "Checking if secrets directory exists..."
    if [ ! -d "$SECRETS_PATH" ]; then
        log_warning "Secrets directory '$SECRETS_PATH' does not exist"
        log_info "Will skip secrets-specific permissions"
        SECRETS_EXISTS=false
    else
        log_success "Secrets directory exists"
        SECRETS_EXISTS=true
    fi

    log_step "Validating users and groups..."
    if ! id "$BASE_USER" >/dev/null 2>&1; then
        log_error "User '$BASE_USER' does not exist!"
        exit 1
    fi

    if ! getent group "$BASE_GROUP" >/dev/null 2>&1; then
        log_error "Group '$BASE_GROUP' does not exist!"
        exit 1
    fi

    if [ "$SECRETS_EXISTS" = true ] && ! getent group "$SECRETS_GROUP" >/dev/null 2>&1; then
        log_error "Group '$SECRETS_GROUP' does not exist!"
        exit 1
    fi

    log_success "All required users and groups exist"

    print_section "👤 Setting Base Ownership" "Applying ownership to homelab directory..."
    log_step "Setting ownership to $BASE_USER:$BASE_GROUP..."

    if chown -R "$BASE_USER:$BASE_GROUP" "$BASE_PATH" 2>/dev/null; then
        log_success "Base ownership applied successfully"
    else
        log_error "Failed to set base ownership"
        exit 1
    fi

    print_section "📂 Setting Base Permissions" "Applying permissions to directories and files..."
    log_step "Setting directory permissions to $DIR_PERMISSIONS..."

    DIR_COUNT=$(find "$BASE_PATH" -type d | wc -l)
    if find "$BASE_PATH" -type d -exec chmod "$DIR_PERMISSIONS" {} \; 2>/dev/null; then
        log_success "Directory permissions applied to $DIR_COUNT directories"
    else
        log_error "Failed to set directory permissions"
        exit 1
    fi

    log_step "Setting file permissions to $FILE_PERMISSIONS..."
    FILE_COUNT=$(find "$BASE_PATH" -type f | wc -l)
    if find "$BASE_PATH" -type f -exec chmod "$FILE_PERMISSIONS" {} \; 2>/dev/null; then
        log_success "File permissions applied to $FILE_COUNT files"
    else
        log_error "Failed to set file permissions"
        exit 1
    fi

    # Handle secrets directory if it exists
    if [ "$SECRETS_EXISTS" = true ]; then
        print_section "🔒 Setting Secrets Permissions" "Applying restricted permissions to secrets..."
        log_step "Setting secrets ownership to $BASE_USER:$SECRETS_GROUP..."
        
        if chown -R "$BASE_USER:$SECRETS_GROUP" "$SECRETS_PATH" 2>/dev/null; then
            log_success "Secrets ownership applied successfully"
        else
            log_error "Failed to set secrets ownership"
            exit 1
        fi

        log_step "Setting secrets file permissions to $SECRETS_FILE_PERMISSIONS..."
        SECRETS_COUNT=$(find "$SECRETS_PATH" -type f | wc -l)
        if find "$SECRETS_PATH" -type f -exec chmod "$SECRETS_FILE_PERMISSIONS" {} \; 2>/dev/null; then
            log_success "Secrets permissions applied to $SECRETS_COUNT files"
        else
            log_error "Failed to set secrets file permissions"
            exit 1
        fi
    fi

    print_section "ℹ️  Summary" "Permission changes completed successfully..."
    log_success "Base directory: $DIR_COUNT directories, $FILE_COUNT files processed"
    if [ "$SECRETS_EXISTS" = true ]; then
        log_success "Secrets directory: $SECRETS_COUNT files secured"
    fi
    log_info "All ownership and permissions have been applied"

    echo ""
    print_separator
    echo -e "  $BOLD$GREEN🎉 Permission Management Completed Successfully! 🎉$NC"
    print_separator
    echo -e "  $CYAN🔐 Base Path:$NC    $WHITE$BASE_PATH ($BASE_USER:$BASE_GROUP)$NC"
    if [ "$SECRETS_EXISTS" = true ]; then
        echo -e "  $CYAN🔒 Secrets Path:$NC $WHITE$SECRETS_PATH ($BASE_USER:$SECRETS_GROUP)$NC"
    fi
    echo -e "  $CYAN📊 Processed:$NC   $WHITE$DIR_COUNT dirs, $FILE_COUNT files total$NC"
    echo ""
  '';
in
{
  environment.systemPackages = [
    fix-permissions
  ];
}
