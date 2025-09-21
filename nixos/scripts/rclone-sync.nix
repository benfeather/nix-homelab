{
  config,
  env,
  pkgs,
  ...
}:
let
  rclone-sync = pkgs.writeShellScriptBin "rclone-sync" ''
    # GCS Sync Script using rclone
    # Usage: rclone-sync <local_source_path> <bucket_dest_path> [bucket_name] [credentials_file]

    set -euo pipefail

    # Default values
    DEFAULT_BUCKET_NAME="backups.benfeather.com"
    DEFAULT_CREDENTIALS_FILE="${config.sops.secrets."gcs".path}
    LOG_DIR="${env.log_dir}"
    REMOTE_NAME="gcs-remote"

    # Function to display usage
    usage() {
        echo "Usage: $0 <local_source_path> <bucket_dest_path> [bucket_name] [credentials_file]"
        echo ""
        echo "Arguments:"
        echo "  local_source_path   : Local directory to sync from"
        echo "  bucket_dest_path    : Destination path relative to bucket root"
        echo "  bucket_name         : GCS bucket name (default: $DEFAULT_BUCKET_NAME)"
        echo "  credentials_file    : Path to GCS credentials JSON file (default: $DEFAULT_CREDENTIALS_FILE)"
        echo ""
        echo "Examples:"
        echo "  $0 ./local-folder remote-folder"
        echo "  $0 /home/user/data backup/2025 my-bucket ./auth/creds.json"
        exit 1
    }

    # Check if minimum arguments provided
    if [ $# -lt 2 ]; then
        echo "Error: Missing required arguments"
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
    if [ ! -d "$LOCAL_SOURCE" ]; then
        echo "Error: Local source directory '$LOCAL_SOURCE' does not exist"
        exit 1
    fi

    if [ ! -f "$CREDENTIALS_FILE" ]; then
        echo "Error: Credentials file '$CREDENTIALS_FILE' does not exist"
        exit 1
    fi

    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"

    # Generate timestamp for log file
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    LOG_FILE="$LOG_DIR/gcs-sync_$TIMESTAMP.log"

    # Function to log with timestamp
    log_with_timestamp() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
    }

    # Function to setup rclone config for GCS
    setup_rclone_config() {
        log_with_timestamp "Setting up rclone configuration for GCS..."
        
        # Remove existing config if present
        rclone config delete "$REMOTE_NAME" 2>/dev/null || true
        
        # Create new GCS remote configuration
        rclone config create "$REMOTE_NAME" gcs \
            service_account_file "$CREDENTIALS_FILE" \
            project_number "" \
            object_acl "" \
            bucket_acl "" \
            location "" \
            storage_class ""
        
        log_with_timestamp "Rclone GCS configuration completed"
    }

    # Function to perform the sync
    perform_sync() {
        local source="$1"
        local dest="$2"
        
        log_with_timestamp "Starting sync operation..."
        log_with_timestamp "Source: $source"
        log_with_timestamp "Destination: $REMOTE_NAME:$BUCKET_NAME/$dest"
        
        # Perform the sync with progress and stats
        rclone sync "$source" "$REMOTE_NAME:$BUCKET_NAME/$dest" \
            --progress \
            --stats 30s \
            --stats-one-line \
            --transfers 4 \
            --checkers 8 \
            --retries 3 \
            --low-level-retries 10 \
            --stats-log-level INFO \
            --log-level INFO
        
        local exit_code=$?
        
        if [ $exit_code -eq 0 ]; then
            log_with_timestamp "Sync completed successfully"
        else
            log_with_timestamp "Sync failed with exit code: $exit_code"
            return $exit_code
        fi
    }

    # Function to cleanup
    cleanup() {
        log_with_timestamp "Cleaning up rclone configuration..."
        rclone config delete "$REMOTE_NAME" 2>/dev/null || true
    }

    # Main execution function
    main() {
        {
            log_with_timestamp "=== GCS Sync Script Started ==="
            log_with_timestamp "Local Source: $LOCAL_SOURCE"
            log_with_timestamp "Bucket: $BUCKET_NAME"
            log_with_timestamp "Destination Path: $BUCKET_DEST_PATH"
            log_with_timestamp "Credentials File: $CREDENTIALS_FILE"
            log_with_timestamp "Log File: $LOG_FILE"
            
            # Setup trap for cleanup
            trap cleanup EXIT
            
            # Setup rclone configuration
            setup_rclone_config
            
            # Test connection
            log_with_timestamp "Testing GCS connection..."
            if rclone lsd "$REMOTE_NAME:$BUCKET_NAME" >/dev/null 2>&1; then
                log_with_timestamp "GCS connection test successful"
            else
                log_with_timestamp "Error: Failed to connect to GCS bucket '$BUCKET_NAME'"
                exit 1
            fi
            
            # Perform sync
            perform_sync "$LOCAL_SOURCE" "$BUCKET_DEST_PATH"
            
            log_with_timestamp "=== GCS Sync Script Completed ==="
            
        } 2>&1 | tee "$LOG_FILE"
    }

    # Check if rclone is installed
    if ! command -v rclone >/dev/null 2>&1; then
        echo "Error: rclone is not installed or not in PATH"
        echo "Please install rclone: https://rclone.org/install/"
        exit 1
    fi

    # Run main function
    main

    echo ""
    echo "Sync operation completed. Log file: $LOG_FILE"
  '';
in
{
  environment.systemPackages = [
    rclone-sync
  ];
}
