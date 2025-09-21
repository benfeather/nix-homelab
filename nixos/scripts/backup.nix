{
  env,
  pkgs,
  ...
}:
let
  backup = pkgs.writeShellScriptBin "backup" ''
    # Usage: ./backup.sh <source_dir> <dest_dir>

    # Check for correct number of arguments
    if [ $# -ne 2 ]; then
      echo "Usage: $0 <source_directory> <destination_directory>"
      echo "Example: $0 /home/user/documents /backup/location"
      exit 1
    fi

    SOURCE_DIR="$1"
    DEST_DIR="$2"

    # Check if source directory exists
    if [ ! -d "$SOURCE_DIR" ]; then
        echo "Error: Source directory '$SOURCE_DIR' does not exist."
        exit 1
    fi

    # Check for sudo privileges and rerun with sudo if needed
    if [ "$EUID" -ne 0 ]; then
        echo "This script requires sudo privileges. Rerunning with sudo..."
        exec sudo "$0" "$@"
    fi

    # Create destination directory if it doesn't exist
    mkdir -p "$DEST_DIR"

    # Check if destination directory creation was successful
    if [ ! -d "$DEST_DIR" ]; then
        echo "Error: Cannot create or access destination directory '$DEST_DIR'."
        exit 1
    fi

    # Get the base name of the source directory
    SOURCE_NAME=$(basename "$SOURCE_DIR")

    # Generate timestamp in human-readable format (YYYY-MM-DD_HH-MM-SS)
    TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

    # Create backup filename
    BACKUP_NAME="$SOURCE_NAME"_backup_"$TIMESTAMP".tar.gz

    # Full path for the backup file
    BACKUP_PATH="$DEST_DIR"/"$BACKUP_NAME"

    echo "Starting backup of '$SOURCE_DIR'..."
    echo "Backup will be saved as: '$BACKUP_PATH'"

    # Create compressed archive
    if tar -czf "$BACKUP_PATH" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"; then
        echo "Backup completed successfully!"
        echo "Backup size: $(du -h "$BACKUP_PATH" | cut -f1)"
    else
        echo "Error: Backup failed!"
        exit 1
    fi

    # Clean up old backups (older than 7 days)
    echo "Cleaning up old backups..."

    # Find and delete backup files older than 7 days that match our naming pattern
    OLD_BACKUPS=$(find "$DEST_DIR" -name "$SOURCE_NAME"_backup_*.tar.gz -type f -mtime +7)

    if [ -n "$OLD_BACKUPS" ]; then
        echo "Found old backups to remove:"
        echo "$OLD_BACKUPS"
        find "$DEST_DIR" -name "$SOURCE_NAME"_backup_*.tar.gz -type f -mtime +7 -delete
        echo "Old backups cleaned up."
    else
        echo "No old backups found to clean up."
    fi

    echo "Backup process completed!"
  '';
in
{
  environment.systemPackages = [
    backup
  ];
}
