{
  env,
  pkgs,
  ...
}:
let
  backup = pkgs.writeShellScriptBin "backup" ''
    # Create a compressed backup of a local directory
    # Usage: backup <source_dir> <dest_dir>

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

    # Enhanced logging functions
    print_header() {
        echo -e "$BOLD$BLUE┌─────────────────────────────────────────────────────────────────────────────┐$NC"
        echo -e "$BOLD$BLUE│                         📦 Directory Backup Tool                            │$NC"
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
        echo -e "  $BOLD$WHITE📋 Backup Configuration$NC"
        print_separator
        echo -e "  $CYAN📁 Source:$NC      $WHITE$SOURCE_DIR$NC"
        echo -e "  $CYAN📍 Destination:$NC $WHITE$DEST_DIR$NC"
        echo -e "  $CYAN📦 Archive Name:$NC $WHITE$BACKUP_NAME$NC"
        echo -e "  $CYAN🕒 Timestamp:$NC   $WHITE$TIMESTAMP$NC"
        print_separator
        echo ""
    }

    usage() {
        print_header
        echo -e "$BOLD"Usage:"$NC $0 <source_directory> <destination_directory>"
        echo ""
        echo -e "$BOLD$WHITE"Arguments:"$NC"
        echo -e "  $CYAN"source_directory"$NC      : Directory to backup"
        echo -e "  $CYAN"destination_directory"$NC : Where to store the backup"
        echo ""
        echo -e "$BOLD$WHITE"Example:"$NC"
        echo -e "  $GRAY$0 /home/user/documents /backup/location$NC"
        echo ""
        echo -e "$BOLD$WHITE"Features:"$NC"
        echo -e "  $GRAY• Creates timestamped .tar.gz archive$NC"
        echo -e "  $GRAY• Automatically cleans up backups older than 7 days$NC"
        echo -e "  $GRAY• Shows backup size and progress$NC"
        echo ""
        exit 1
    }

    # Check for correct number of arguments
    if [ $# -ne 2 ]; then
        usage
    fi

    SOURCE_DIR="$1"
    DEST_DIR="$2"

    # Check for sudo privileges and rerun with sudo if needed
    if [ "$EUID" -ne 0 ]; then
        echo "This script requires sudo privileges. Rerunning with sudo..."
        echo ""
        exec sudo "$0" "$@"
    fi

    print_header

    print_section "🔍 Validation" "Checking source and destination directories..."

    # Check if source directory exists
    if [ ! -d "$SOURCE_DIR" ]; then
        log_error "Source directory '$SOURCE_DIR' does not exist"
        exit 1
    fi
    log_success "Source directory exists and is accessible"

    # Create destination directory if it doesn't exist
    log_step "Creating destination directory if needed..."
    mkdir -p "$DEST_DIR"

    # Check if destination directory creation was successful
    if [ ! -d "$DEST_DIR" ]; then
        log_error "Cannot create or access destination directory '$DEST_DIR'"
        exit 1
    fi
    log_success "Destination directory is ready"

    # Generate backup details
    SOURCE_NAME=$(basename "$SOURCE_DIR")
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
    BACKUP_NAME="$SOURCE_NAME"_backup_"$TIMESTAMP".tar.gz
    BACKUP_PATH="$DEST_DIR"/"$BACKUP_NAME"

    # Show configuration summary
    print_config_summary

    print_section "📦 Creating Backup" "Compressing directory into archive..."
    log_step "Starting backup process..."
    log_info "Creating archive: $BACKUP_NAME"

    # Create compressed archive with progress indication
    if tar -czf "$BACKUP_PATH" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")" 2>/dev/null; then
        BACKUP_SIZE=$(du -h "$BACKUP_PATH" | cut -f1)
        log_success "Backup created successfully!"
        log_info "Archive size: $BACKUP_SIZE"
    else
        log_error "Backup creation failed!"
        exit 1
    fi

    print_section "🧹 Cleanup" "Removing old backups (older than 7 days)..."
    log_step "Scanning for old backups to clean up..."

    # Find and delete backup files older than 7 days that match our naming pattern
    OLD_BACKUPS=$(find "$DEST_DIR" -name "$SOURCE_NAME"_backup_*.tar.gz -type f -mtime +7 2>/dev/null || true)

    if [ -n "$OLD_BACKUPS" ]; then
        OLD_COUNT=$(echo "$OLD_BACKUPS" | wc -l)
        log_warning "Found $OLD_COUNT old backup(s) to remove:"
        echo "$OLD_BACKUPS" | while read -r backup; do
            echo -e "   $GRAY   • $(basename "$backup")$NC"
        done
        
        log_step "Removing old backups..."
        find "$DEST_DIR" -name "$SOURCE_NAME"_backup_*.tar.gz -type f -mtime +7 -delete 2>/dev/null || true
        log_success "Old backups cleaned up"
    else
        log_info "No old backups found to clean up"
    fi

    # Final success message
    echo ""
    print_separator
    echo -e "  $BOLD$GREEN🎉 Backup Process Completed Successfully! 🎉$NC"
    print_separator
    echo -e "  $CYAN📦 Archive:$NC $WHITE$BACKUP_NAME$NC"
    echo -e "  $CYAN📏 Size:$NC    $WHITE$BACKUP_SIZE$NC"
    echo -e "  $CYAN📍 Location:$NC $WHITE$BACKUP_PATH$NC"
    echo ""
  '';
in
{
  environment.systemPackages = [
    backup
  ];
}
