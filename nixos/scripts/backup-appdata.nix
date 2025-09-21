{
  env,
  pkgs,
  ...
}:
let
  backup-appdata = pkgs.writeShellScriptBin "backup-appdata" ''
    set -euo pipefail

    # Configuration
    SOURCE_DIR="${env.conf_dir}"
    BACKUP_DIR="${env.backup_dir}"
    LOG_FILE="/var/log/backup.log"
    DATE=$(date '+%Y-%m-%d %H:%M:%S')

    # Colors for output
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    log() {
        echo -e "${DATE} - $1" | tee -a "$LOG_FILE"
    }

    log_error() {
        echo -e "${RED}${DATE} - ERROR: $1${NC}" | tee -a "$LOG_FILE"
    }

    log_success() {
        echo -e "${GREEN}${DATE} - SUCCESS: $1${NC}" | tee -a "$LOG_FILE"
    }

    log_warning() {
        echo -e "${YELLOW}${DATE} - WARNING: $1${NC}" | tee -a "$LOG_FILE"
    }

    # Check if source directory exists
    if [[ ! -d "$SOURCE_DIR" ]]; then
        log_error "Source directory does not exist: $SOURCE_DIR"
        exit 1
    fi

    # Create backup directory if it doesn't exist
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
    fi

    # Check available space
    SOURCE_SIZE=$(du -sb "$SOURCE_DIR" | cut -f1)
    BACKUP_AVAIL=$(df "$BACKUP_DIR" | tail -1 | awk '{print $4 * 1024}')

    if [[ $SOURCE_SIZE -gt $BACKUP_AVAIL ]]; then
        log_error "Insufficient space on backup drive"
        log_error "Required: $(numfmt --to=iec $SOURCE_SIZE), Available: $(numfmt --to=iec $BACKUP_AVAIL)"
        exit 1
    fi

    log "Starting backup from $SOURCE_DIR to $BACKUP_DIR"

    # Rclone sync with options
    # --progress: show progress
    # --stats: show stats every 30s
    # --verbose: verbose output
    # --checksum: verify file integrity
    # --delete-excluded: delete files on dest not in source
    # --backup-dir: move deleted files to backup location instead of deleting

    rclone sync \
        "$SOURCE_DIR" \
        "$BACKUP_DIR" \
        --progress \
        --stats 30s \
        --verbose \
        --checksum \
        --delete-excluded \
        --backup-dir "$BACKUP_DIR/.rclone-backups/$(date +%Y%m%d-%H%M%S)" \
        --log-file "$LOG_FILE" \
        --log-level INFO

    if [[ $? -eq 0 ]]; then
        log_success "Backup completed successfully"
    else
        log_error "Backup failed with exit code $?"
        exit 1
    fi

    # Optional: Clean up old backup folders (keep last 7 days)
    find "$BACKUP_DIR/.rclone-backups" -type d -mtime +7 -exec rm -rf {} + 2>/dev/null || true

    log "Backup process finished"
  '';
in
{
  environment.systemPackages = [
    backup-appdata
  ];
}
