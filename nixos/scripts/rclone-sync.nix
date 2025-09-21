{
  env,
  pkgs,
  ...
}:
let
  rclone-sync = pkgs.writeShellScriptBin "rclone-sync" ''
    # Syncs a local directory to Proton Drive
    # Usage: rclone-sync <source_dir> [remote_subdir]

    # Configuration
    BASE_REMOTE_NAME="gcs-base"
    ENCRYPTED_REMOTE_NAME="gcs-encrypted"
    LOCKFILE="/tmp/rclone_sync_gcs_encrypted.lock"
    LOGFILE="/var/log/rclone_sync_gcs_encrypted.log"

    # Function to log messages
    log_message() {
        local message="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
        echo "$message"
        echo "$message" >> "$LOGFILE"
    }

    # Function to setup environment authentication
    setup_env_auth() {
        # Setup GCS auth
        if [ -n "$GCS_PROJECT_ID" ] && [ -n "$GCS_SERVICE_ACCOUNT_FILE" ]; then
            export RCLONE_CONFIG_GCS_BASE_TYPE=googlecloudstorage
            export RCLONE_CONFIG_GCS_BASE_PROJECT_NUMBER="$GCS_PROJECT_ID"
            export RCLONE_CONFIG_GCS_BASE_SERVICE_ACCOUNT_FILE="$GCS_SERVICE_ACCOUNT_FILE"
            export RCLONE_CONFIG_GCS_BASE_BUCKET_ACL=private
            export RCLONE_CONFIG_GCS_BASE_OBJECT_ACL=private
            export RCLONE_CONFIG_GCS_BASE_LOCATION="$GCS_LOCATION"
            log_message "Using environment variable authentication for GCS"
        fi
        
        # Setup encryption
        if [ -n "$RCLONE_CRYPT_PASSWORD" ]; then
            export RCLONE_CONFIG_GCS_ENCRYPTED_TYPE=crypt
            export RCLONE_CONFIG_GCS_ENCRYPTED_REMOTE="$BASE_REMOTE_NAME:"
            export RCLONE_CONFIG_GCS_ENCRYPTED_PASSWORD="$RCLONE_CRYPT_PASSWORD"
            if [ -n "$RCLONE_CRYPT_PASSWORD2" ]; then
                export RCLONE_CONFIG_GCS_ENCRYPTED_PASSWORD2="$RCLONE_CRYPT_PASSWORD2"
            fi
            log_message "Using environment variable encryption passwords"
        fi
    }

    # Function to cleanup on exit
    cleanup() {
        rm -f "$LOCKFILE"
    }

    # Set trap for cleanup
    trap cleanup EXIT

    # Check if script is already running
    if [ -f "$LOCKFILE" ]; then
        log_message "ERROR: Another instance is already running (lockfile exists)"
        exit 1
    fi

    # Create lockfile
    echo $$ > "$LOCKFILE"

    # Setup authentication
    setup_env_auth

    # Check arguments
    if [ $# -lt 2 ] || [ $# -gt 3 ]; then
        echo "Usage: $0 <source_directory> <bucket_name> [remote_subdirectory]"
        echo "Example: $0 /home/user/documents my-backup-bucket"
        echo "Example: $0 /home/user/photos my-backup-bucket backup/photos"
        exit 1
    fi

    SOURCE_DIR="$1"
    BUCKET_NAME="$2"
    REMOTE_SUBDIR="$3"

    # Convert to absolute path if relative
    if [[ "$SOURCE_DIR" != /* ]]; then
        SOURCE_DIR="$(pwd)/$SOURCE_DIR"
    fi

    # Check if source directory exists
    if [ ! -d "$SOURCE_DIR" ]; then
        log_message "ERROR: Source directory '$SOURCE_DIR' does not exist"
        exit 1
    fi

    # Build remote path (using encrypted remote)
    if [ -n "$REMOTE_SUBDIR" ]; then
        REMOTE_PATH="$ENCRYPTED_REMOTE_NAME:$BUCKET_NAME/$REMOTE_SUBDIR"
    else
        REMOTE_PATH="$ENCRYPTED_REMOTE_NAME:$BUCKET_NAME/$(basename "$SOURCE_DIR")"
    fi

    # Check if rclone is available
    if ! command -v rclone >/dev/null 2>&1; then
        log_message "ERROR: rclone is not installed or not in PATH"
        exit 1
    fi

    # Test base remote connectivity
    log_message "Testing connectivity to Google Cloud Storage..."
    if ! rclone lsd "$BASE_REMOTE_NAME:$BUCKET_NAME" >/dev/null 2>&1; then
        log_message "ERROR: Cannot connect to GCS bucket '$BUCKET_NAME'"
        exit 1
    fi

    # Test encrypted remote
    log_message "Testing encrypted remote..."
    if ! rclone lsd "$ENCRYPTED_REMOTE_NAME:$BUCKET_NAME" >/dev/null 2>&1; then
        log_message "ERROR: Cannot access encrypted remote"
        log_message "Please check your encryption configuration"
        exit 1
    fi

    # Start sync
    log_message "Starting encrypted sync: '$SOURCE_DIR' -> '$REMOTE_PATH'"

    # Rclone sync with encryption and GCS optimization
    RCLONE_OUTPUT=$(rclone sync "$SOURCE_DIR" "$REMOTE_PATH" \
        --create-empty-src-dirs \
        --checksum \
        --transfers 8 \
        --checkers 16 \
        --retries 3 \
        --low-level-retries 10 \
        --stats 0 \
        --progress=false \
        --fast-list \
        --use-mmap \
        2>&1)

    SYNC_EXIT_CODE=$?

    if [ $SYNC_EXIT_CODE -eq 0 ]; then
        log_message "Encrypted sync completed successfully"
        if echo "$RCLONE_OUTPUT" | grep -q "Transferred:.*[1-9]"; then
            log_message "Transfer details: $(echo "$RCLONE_OUTPUT" | grep "Transferred:")"
        fi
    else
        log_message "ERROR: Encrypted sync failed with exit code $SYNC_EXIT_CODE"
        log_message "Error output: $RCLONE_OUTPUT"
        exit $SYNC_EXIT_CODE
    fi

    # Check encrypted remote directory size
    REMOTE_SIZE=$(rclone size "$REMOTE_PATH" --json 2>/dev/null | grep -o '"bytes":[0-9]*' | cut -d: -f2)

    if [ -n "$REMOTE_SIZE" ]; then
        HUMAN_SIZE=$(echo "$REMOTE_SIZE" | awk '{
            if ($1 >= 1073741824) printf "%.2f GB", $1/1073741824
            else if ($1 >= 1048576) printf "%.2f MB", $1/1048576  
            else if ($1 >= 1024) printf "%.2f KB", $1/1024
            else printf "%d bytes", $1
        }')
        log_message "Encrypted remote directory size: $HUMAN_SIZE"
    fi

    log_message "Encrypted sync job completed"
  '';
in
{
  environment.systemPackages = [
    rclone-sync
  ];
}
