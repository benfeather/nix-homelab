{
  pkgs,
  ...
}:
let
  cleanup = pkgs.writeShellScriptBin "cleanup" ''
    # Clean up old files from a directory
    # Usage: cleanup <source_directory> [days_to_keep] [--yes]

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

    # Default configuration
    DEFAULT_DAYS_TO_KEEP=7
    SKIP_CONFIRMATION=false

    # Enhanced logging functions
    print_header() {
        echo -e "$BOLD$BLUE┌─────────────────────────────────────────────────────────────────────────────┐$NC"
        echo -e "$BOLD$BLUE│                        🧹 File Cleanup Tool                                 │$NC"
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
        echo -e "  $BOLD$WHITE🧹 Cleanup Configuration$NC"
        print_separator
        echo -e "  $CYAN📁 Source Dir:$NC    $WHITE$SOURCE_DIR$NC"
        echo -e "  $CYAN📅 Days to Keep:$NC  $WHITE$DAYS_TO_KEEP days$NC"
        echo -e "  $CYAN👁️  Exclusions:$NC   $WHITE""Hidden files/folders (.*)""$NC"
        echo -e "  $CYAN🤖 Auto-confirm:$NC  $WHITE$SKIP_CONFIRMATION$NC"
        print_separator
        echo ""
    }

    usage() {
        print_header
        echo -e "$BOLD""Usage:""$NC $0 <source_directory> [days_to_keep] [--yes|-y]"
        echo ""
        echo -e "$BOLD$WHITE""Arguments:""$NC"
        echo -e "  $CYAN""source_directory""$NC : Directory to clean up files from"
        echo -e "  $CYAN""days_to_keep""$NC     : Keep files newer than this (default: $DEFAULT_DAYS_TO_KEEP days)"
        echo ""
        echo -e "$BOLD$WHITE""Options:""$NC"
        echo -e "  $CYAN""--yes, -y""$NC        : Skip confirmation prompt"
        echo ""
        echo -e "$BOLD$WHITE""Examples:""$NC"
        echo -e "  $GRAY$0 /backup/location$NC"
        echo -e "  $GRAY$0 /backup/location 14$NC"
        echo -e "  $GRAY$0 /backup/location 14 --yes    # Auto-confirm$NC"
        echo -e "  $GRAY$0 /backup/location --yes       # Use default 7 days$NC"
        echo ""
        echo -e "$BOLD$WHITE""What gets cleaned:""$NC"
        echo -e "  $GRAY• ALL files older than the specified number of days$NC"
        echo -e "  $GRAY• Hidden files and directories are ignored$NC"
        echo ""
        echo -e "$BOLD$WHITE""Safety features:""$NC"
        echo -e "  $GRAY• Shows preview before deletion$NC"
        echo -e "  $GRAY• Requires confirmation (unless --yes is used)$NC"
        echo -e "  $GRAY• Detailed summary of actions taken$NC"
        echo ""
        exit 1
    }

    # Parse arguments
    SOURCE_DIR=""
    DAYS_TO_KEEP=""

    for arg in "$@"; do
        case $arg in
            --yes|-y)
                SKIP_CONFIRMATION=true
                shift
                ;;
            *)
                if [ -z "$SOURCE_DIR" ]; then
                    SOURCE_DIR="$arg"
                elif [ -z "$DAYS_TO_KEEP" ]; then
                    DAYS_TO_KEEP="$arg"
                fi
                ;;
        esac
    done

    # Check if source directory is provided
    if [ -z "$SOURCE_DIR" ]; then
        usage
    fi

    # Set default days to keep if not provided
    if [ -z "$DAYS_TO_KEEP" ]; then
        DAYS_TO_KEEP="$DEFAULT_DAYS_TO_KEEP"
    fi

    # Validate days_to_keep is a number
    if ! [[ "$DAYS_TO_KEEP" =~ ^[0-9]+$ ]]; then
        print_header
        log_error "Days to keep must be a positive number, got: '$DAYS_TO_KEEP'"
        exit 1
    fi

    print_header

    print_section "🔍 Validation" "Checking source directory and parameters..."

    # Check if source directory exists
    if [ ! -d "$SOURCE_DIR" ]; then
        log_error "Source directory '$SOURCE_DIR' does not exist"
        exit 1
    fi
    log_success "Source directory exists and is accessible"

    # Check if we have read permissions
    if [ ! -r "$SOURCE_DIR" ]; then
        log_error "Cannot read from source directory '$SOURCE_DIR'"
        exit 1
    fi
    log_success "Directory permissions verified"

    # Show configuration summary
    print_config_summary

    print_section "🔍 Scanning for Old Files" "Finding files older than $DAYS_TO_KEEP days..."
    log_step "Scanning directory..."

    # Find all files older than specified days, excluding hidden files
    OLD_FILES_TEMP=$(mktemp)

    find "$SOURCE_DIR" -maxdepth 1 -not -name ".*" -type f -mtime +"$DAYS_TO_KEEP" 2>/dev/null > "$OLD_FILES_TEMP" || true

    OLD_FILES=$(cat "$OLD_FILES_TEMP")
    rm -f "$OLD_FILES_TEMP"

    FILE_COUNT=$(echo "$OLD_FILES" | grep -c . || echo 0)

    if [ "$FILE_COUNT" -eq 0 ] || [ -z "$OLD_FILES" ]; then
        log_info "No old files found to clean up"
        echo ""
        print_separator
        echo -e "  $BOLD$GREEN🎉 Directory is Already Clean! 🎉$NC"
        print_separator
        echo -e "  $CYAN📁 Scanned:$NC $WHITE$SOURCE_DIR$NC"
        echo -e "  $CYAN📅 Cutoff:$NC  $WHITE$DAYS_TO_KEEP days ago$NC"
        echo ""
        exit 0
    fi

    log_success "Found $FILE_COUNT old files"

    print_section "📋 Files to Remove" "Files that will be deleted..."

    # Calculate total size and show file list
    echo "$OLD_FILES" | while read -r file; do
        if [ -n "$file" ] && [ -f "$file" ]; then
            size=$(du -h "$file" 2>/dev/null | cut -f1 || echo "?")
            age_days=$(find "$file" -printf '%A@\n' 2>/dev/null | xargs -I {} date -d "@{}" "+%Y-%m-%d" 2>/dev/null || echo "unknown")
            echo -e "   $GRAY   • $(basename "$file")$NC $CYAN($size, $age_days)$NC"
        fi
    done

    # Calculate total size
    TOTAL_SIZE=$(echo "$OLD_FILES" | xargs -I {} du -b {} 2>/dev/null | awk '{sum += $1} END {print sum}' || echo 0)
    if [ "$TOTAL_SIZE" -gt 0 ]; then
        TOTAL_SIZE_HUMAN=$(echo "$TOTAL_SIZE" | awk '{
            if ($1 >= 1073741824) printf "%.1fGB", $1/1073741824
            else if ($1 >= 1048576) printf "%.1fMB", $1/1048576
            else if ($1 >= 1024) printf "%.1fKB", $1/1024
            else printf "%dB", $1
        }')
    else
        TOTAL_SIZE_HUMAN="0B"
    fi

    log_warning "Total size to be freed: $TOTAL_SIZE_HUMAN"

    # Confirmation prompt (unless --yes flag is used)
    if [ "$SKIP_CONFIRMATION" = false ]; then
        print_section "⚠️  Confirmation" "Please confirm the cleanup operation..."
        echo ""
        echo -e "   $BOLD$YELLOW⚠️  This will permanently delete $FILE_COUNT files!$NC"
        echo -e "   $GRAY   Files older than $DAYS_TO_KEEP days will be removed$NC"
        echo -e "   $GRAY   Total space to be freed: $TOTAL_SIZE_HUMAN$NC"
        echo ""
        echo -e "   $WHITE""Do you want to proceed? (y/N):$NC "
        read -r CONFIRMATION

        case $CONFIRMATION in
            [Yy]|[Yy][Ee][Ss])
                log_info "Proceeding with cleanup..."
                ;;
            *)
                log_info "Cleanup cancelled by user"
                echo ""
                print_separator
                echo -e "  $BOLD$YELLOW🚫 Cleanup Cancelled$NC"
                print_separator
                echo -e "  $CYAN📊 Would have removed:$NC $WHITE$FILE_COUNT files ($TOTAL_SIZE_HUMAN)$NC"
                echo ""
                exit 0
                ;;
        esac
    else
        log_info "Auto-confirming cleanup (--yes flag used)"
    fi

    print_section "🗑️  Removing Old Files" "Deleting old files..."
    log_step "Removing files..."

    REMOVED_COUNT=0
    FAILED_COUNT=0

    echo "$OLD_FILES" | while read -r file; do
        if [ -n "$file" ] && [ -f "$file" ]; then
            if rm "$file" 2>/dev/null; then
                echo -e "   $GREEN   ✓$NC  Removed: $(basename "$file")"
                REMOVED_COUNT=$((REMOVED_COUNT + 1))
            else
                echo -e "   $RED   ✗$NC  Failed: $(basename "$file")"
                FAILED_COUNT=$((FAILED_COUNT + 1))
            fi
        fi
    done

    # Get final counts
    FINAL_REMOVED=$(echo "$OLD_FILES" | while read -r file; do [ -n "$file" ] && [ ! -f "$file" ] && echo 1; done | wc -l)
    FINAL_FAILED=$((FILE_COUNT - FINAL_REMOVED))

    if [ "$FINAL_FAILED" -eq 0 ]; then
        log_success "All $FINAL_REMOVED files removed successfully!"
    elif [ "$FINAL_REMOVED" -gt 0 ]; then
        log_warning "Removed $FINAL_REMOVED files, $FINAL_FAILED failed"
    else
        log_error "Failed to remove any files"
        exit 1
    fi

    # Final success message
    echo ""
    print_separator
    echo -e "  $BOLD$GREEN🎉 Cleanup Completed! 🎉$NC"
    print_separator
    echo -e "  $CYAN🗑️  Removed:$NC     $WHITE$FINAL_REMOVED files$NC"
    if [ "$FINAL_FAILED" -gt 0 ]; then
        echo -e "  $CYAN❌ Failed:$NC      $WHITE$FINAL_FAILED files$NC"
    fi
    echo -e "  $CYAN💾 Space Freed:$NC $WHITE$TOTAL_SIZE_HUMAN$NC"
    echo -e "  $CYAN📁 Directory:$NC   $WHITE$SOURCE_DIR$NC"
    echo ""
  '';
in
{
  environment.systemPackages = [
    cleanup
  ];
}
