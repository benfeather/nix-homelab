{
  config,
  env,
  pkgs,
  ...
}:
let
  rclone-sync = pkgs.writeShellScriptBin "rclone-sync" ''
    # GCS Sync Script using rclone
    # Usage: rclone-sync local_source_path bucket_dest_path [bucket_name] [credentials_file]

    # Check if running as root, if not re-run with sudo
    if [ "$EUID" -ne 0 ]; then
      echo "This script requires root privileges. Re-running with sudo..."
      echo ""
      exec sudo "$0" "$@"
    fi

    set -euo pipefail

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

    # Default values
    DEFAULT_BUCKET_NAME="backups.benfeather.com"
    DEFAULT_CREDENTIALS_FILE="${config.sops.secrets."gcs".path}"
    REMOTE_NAME="gcs-remote"

    # Function to display usage
    usage() {
        echo -e "$BOLD$BLUE┌─────────────────────────────────────────────────────────────────────────────┐$NC"
        echo -e "$BOLD$BLUE│                          🚀 GCS Sync Script                                 │$NC"
        echo -e "$BOLD$BLUE└─────────────────────────────────────────────────────────────────────────────┘$NC"
        echo ""
        echo -e "$BOLDUsage:$NC $0 LOCAL_SOURCE_PATH BUCKET_DEST_PATH [BUCKET_NAME] [CREDENTIALS_FILE]"
        echo ""
        echo -e "$BOLD$WHITEArguments:$NC"
        echo -e "  $CYANLOCAL_SOURCE_PATH$NC   : Local directory to sync from"
        echo -e "  $CYANBUCKET_DEST_PATH$NC    : Destination path relative to bucket root"
        echo -e "  $CYANBUCKET_NAME$NC         : GCS bucket name (default: $GRAY$DEFAULT_BUCKET_NAME$NC)"
        echo -e "  $CYANCREDENTIALS_FILE$NC    : Path to GCS credentials JSON file (default: $GRAY$DEFAULT_CREDENTIALS_FILE$NC)"
        echo ""
        echo -e "$BOLD$WHITEExamples:$NC"
        echo -e "  $GRAY$0 ./local-folder remote-folder$NC"
        echo -e "  $GRAY$0 /home/user/data backup/2025 my-bucket ./auth/creds.json$NC"
        echo ""
        exit 1
    }

    # Enhanced logging functions
    print_header() {
        echo -e "$BOLD$BLUE┌─────────────────────────────────────────────────────────────────────────────┐$NC"
        echo -e "$BOLD$BLUE│                          🚀 GCS Sync Script                                 │$NC"
        echo -e "$BOLD$BLUE└─────────────────────────────────────────────────────────────────────────────┘$NC"
        echo ""
    }

    print_section() {
        echo ""
        echo -e "$BOLD$PURPLE▶  $1$NC"
        echo -e "$GRAY   $2$NC"
    }

    log_info() {
        echo -e "$CYAN   ℹ  $NC$(date '+%H:%M:%S') $WHITE$1$NC"
    }

    log_success() {
        echo -e "$GREEN   ✓  $NC$(date '+%H:%M:%S') $WHITE$1$NC"
    }

    log_warning() {
        echo -e "$YELLOW   ⚠  $NC$(date '+%H:%M:%S') $WHITE$1$NC"
    }

    log_error() {
        echo -e "$RED   ✗  $NC$(date '+%H:%M:%S') $WHITE$1$NC"
    }

    log_step() {
        echo -e "$BLUE   →  $NC$(date '+%H:%M:%S') $WHITE$1$NC"
    }

    print_separator() {
        echo -e "$GRAY─────────────────────────────────────────────────────────────────────────────$NC"
    }

    print_config_summary() {
        echo ""
        print_separator
        echo -e "$BOLD$WHITE  📋 Configuration Summary$NC"
        print_separator
        echo -e "  $CYAN Bucket:$NC      $WHITE$BUCKET_NAME$NC"
        echo -e "  $CYAN Credentials:$NC $WHITE$CREDENTIALS_FILE$NC"
        echo -e "  $CYAN Source:$NC      $WHITE$LOCAL_SOURCE$NC"
        echo -e "  $CYAN Destination:$NC $WHITE$BUCKET_DEST_PATH$NC"
        print_separator
        echo ""
    }

    # Check if minimum arguments provided
    if [ $# -lt 2 ]; then
        print_header
        echo -e "$RED   ✗  Error: Missing required arguments$NC"
        echo ""
        usage
    fi

    # Parse arguments
    LOCAL_SOURCE="$1"
    BUCKET_DEST_PATH="$2"

    # Set bucket name with fallback
    if [ $# -ge 3 ] && [ -n "$3" ]; then
        BUCKET_NAME="$3"
    else
        BUCKET_NAME="$DEFAULT_BUCKET_NAME"
    fi

    # Set credentials file with fallback
    if [ $# -ge 4 ] && [ -n "$4" ]; then
        CREDENTIALS_FILE="$4"
    else
        CREDENTIALS_FILE="$DEFAULT_CREDENTIALS_FILE"
    fi

    # Validate inputs
    print_header
    print_section "🔍 Validating Inputs" "Checking source directory and credentials..."

    if [ ! -d "$LOCAL_SOURCE" ]; then
        log_error "Local source directory '$LOCAL_SOURCE' does not exist"
        exit 1
    fi
    log_success "Source directory exists"

    if [ ! -f "$CREDENTIALS_FILE" ]; then
        log_error "Credentials file '$CREDENTIALS_FILE' does not exist"
        exit 1
    fi
    log_success "Credentials file found"

    # Function to setup rclone config for GCS
    setup_rclone_config() {
        print_section "⚙️  Setting up rclone" "Configuring GCS remote with uniform bucket-level access..."
        
        log_step "Removing existing configuration..."
        rclone config delete "$REMOTE_NAME" >/dev/null 2>&1 || true
        
        log_step "Creating new GCS remote configuration..."
        rclone config create "$REMOTE_NAME" gcs \
            service_account_file "$CREDENTIALS_FILE" \
            project_number "" \
            object_acl "" \
            bucket_acl "" \
            location "" \
            storage_class "" \
            bucket_policy_only "true" \
            --non-interactive >/dev/null 2>&1
        
        log_success "Rclone GCS configuration completed"
    }

    # Function to perform the sync
    perform_sync() {
        local source="$1"
        local dest="$2"
        
        print_section "🚀 Starting Sync Operation" "Syncing files to Google Cloud Storage..."
        
        log_info "Source: $source"
        log_info "Destination: $REMOTE_NAME:$BUCKET_NAME/$dest"
        log_warning "Hidden files (.*) will be excluded from sync"
        
        echo ""
        echo -e "   $BOLD$GREEN📊 Sync Progress:$NC"
        echo -e "   $GRAY   Press Ctrl+C to cancel$NC"
        echo ""
        
        # Perform the sync with progress and stats, optimized for uniform bucket-level access
        rclone sync "$source" "$REMOTE_NAME:$BUCKET_NAME/$dest" \
            --progress \
            --stats 10s \
            --stats-one-line \
            --transfers 4 \
            --checkers 8 \
            --retries 3 \
            --low-level-retries 10 \
            --stats-log-level INFO \
            --log-level ERROR \
            --gcs-no-check-bucket \
            --gcs-bucket-policy-only \
            --exclude ".*" 2>&1 | while IFS= read -r line; do
                if [[ "$line" == *"INFO"* ]] && [[ "$line" == *"There was nothing to transfer"* ]]; then
                    echo -e "   $CYAN   ℹ  $NC$(date '+%H:%M:%S') $WHITE""No new files to transfer$NC"
                elif [[ "$line" == *"INFO"* ]]; then
                    # Skip other INFO messages to reduce noise
                    continue
                elif [[ "$line" == *"ERROR"* ]]; then
                    echo -e "   $RED   ✗  $NC$(date '+%H:%M:%S') $WHITE""$line$NC"
                elif [[ "$line" =~ ^[0-9] ]]; then
                    echo -e "   $BLUE   📈  $NC$line"
                else
                    echo "   $line"
                fi
            done
        
        local exit_code=$?
        
        echo ""
        if [ $exit_code -eq 0 ]; then
            log_success "Sync completed successfully! 🎉"
        else
            log_error "Sync failed with exit code: $exit_code"
            return $exit_code
        fi
    }

    # Function to cleanup
    cleanup() {
        print_section "🧹 Cleanup" "Removing temporary rclone configuration..."
        log_step "Cleaning up rclone configuration..."
        rclone config delete "$REMOTE_NAME" >/dev/null 2>&1 || true
        log_success "Cleanup completed"
    }

    # Main execution function
    main() {
        # Setup trap for cleanup
        trap cleanup EXIT
        
        # Show configuration summary
        print_config_summary
        
        # Setup rclone configuration
        setup_rclone_config
        
        # Test connection
        print_section "🔗 Testing Connection" "Verifying access to GCS bucket..."
        log_step "Testing GCS connection..."
        
        if rclone lsd "$REMOTE_NAME:$BUCKET_NAME" --gcs-no-check-bucket --gcs-bucket-policy-only >/dev/null 2>&1; then
            log_success "GCS connection test successful"
        else
            log_error "Failed to connect to GCS bucket '$BUCKET_NAME'"
            exit 1
        fi
        
        # Perform sync
        perform_sync "$LOCAL_SOURCE" "$BUCKET_DEST_PATH"
        
        # Final success message
        echo ""
        print_separator
        echo -e "  $BOLD$GREEN🎉 Sync Operation Completed Successfully! 🎉$NC"
        print_separator
        echo ""
    }

    # Check if rclone is installed
    if ! command -v rclone >/dev/null 2>&1; then
        print_header
        log_error "rclone is not installed or not in PATH"
        echo -e "   $YELLOW💡 Please install rclone: $CYAN""https://rclone.org/install/$NC"
        exit 1
    fi

    # Run main function
    main
  '';
in
{
  environment.systemPackages = [
    rclone-sync
  ];
}
