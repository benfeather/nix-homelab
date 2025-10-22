{
  env,
  pkgs,
  ...
}:
let
  backup-appdata = pkgs.writeShellScriptBin "backup-appdata" ''
    set -euo pipefail

    # Create log directory if it doesn't exist
    LOG_DIR="${env.root_dir}/logs"
    mkdir -p "$LOG_DIR"

    # Use daily log file
    DATE=$(date +"%Y-%m-%d_%H-%M-%S")
    LOG_FILE="$LOG_DIR/appdata_backup_$DATE.log"

    # Generate session timestamp
    SESSION_START=$(date +"%Y-%m-%d %H:%M:%S")

    # Pretty logging functions for log file
    log_to_file() {
      echo "$1" >> "$LOG_FILE"
    }

    log_session_header() {
      log_to_file "================================================================================"
      log_to_file "                          BACKUP APPDATA SCRIPT RUN"
      log_to_file "================================================================================"
      log_to_file "  Session Start: $SESSION_START"
      log_to_file "  PID:           $$"
      log_to_file "  User:          $(whoami)"
      log_to_file "  Backup Dir:    ${env.backup_dir}"
      log_to_file "  Config Dir:    ${env.appdata_dir}"
      log_to_file "================================================================================"
    }

    log_section() {
      local title="$1"
      local description="$2"

      log_to_file ">> $title"
      log_to_file "   $description"
    }

    log_info() {
      local msg="$1"
      local timestamp=$(date '+%H:%M:%S')

      log_to_file "   [INFO]    $timestamp  $msg"
    }

    log_success() {
      local msg="$1"
      local timestamp=$(date '+%H:%M:%S')

      log_to_file "   [SUCCESS] $timestamp  $msg"
    }

    log_error() {
      local msg="$1"
      local timestamp=$(date '+%H:%M:%S')

      log_to_file "   [ERROR]   $timestamp  $msg"
    }

    log_step() {
      local msg="$1"
      local timestamp=$(date '+%H:%M:%S')

      log_to_file "   [STEP]    $timestamp  $msg"
    }

    log_warning() {
      local msg="$1"
      local timestamp=$(date '+%H:%M:%S')

      log_to_file "   [WARNING] $timestamp  $msg"
    }

    log_session_footer() {
      local session_end=$(date +"%Y-%m-%d %H:%M:%S")
      local duration=$(($(date +%s) - $(date -d "$SESSION_START" +%s)))

      log_to_file "================================================================================"
      log_to_file "                            SESSION COMPLETED"
      log_to_file "================================================================================"
      log_to_file "  Session End:   $session_end"
      log_to_file "  Duration:      $duration seconds"
      log_to_file "  Status:        SUCCESS"
      log_to_file "================================================================================"
    }

    log_session_error() {
      local exit_code=$1
      local session_end=$(date +"%Y-%m-%d %H:%M:%S")
      local duration=$(($(date +%s) - $(date -d "$SESSION_START" +%s)))

      log_to_file "================================================================================"
      log_to_file "                            SESSION FAILED"
      log_to_file "================================================================================"
      log_to_file "  Session End:   $session_end"
      log_to_file "  Duration:      $duration seconds"
      log_to_file "  Status:        FAILED"
      log_to_file "  Exit Code:     $exit_code"
      log_to_file "================================================================================"
    }

    # Function to run command with logging
    run_command() {
      local cmd="$1"
      local description="$2"

      log_step "Starting: $description"
      log_info "Command: $cmd"

      if eval "$cmd" >/dev/null 2>&1; then
        log_success "Completed: $description"
        return 0
      else
        local exit_code=$?
        log_error "Failed: $description (exit code: $exit_code)"
        log_error "Command: $cmd"
        exit $exit_code
      fi
    }

    # Main execution
    main() {
      # Initialize session in log file
      log_session_header
      log_to_file ""

      # Stop containers
      log_section "Stopping Containers" "Stopping OCI containers before backup"
      run_command "oci-containers stop" "Stopping OCI containers"
      log_to_file ""

      # Create archive
      log_section "Creating Archive" "Archiving configuration directory"
      run_command "archive ${env.appdata_dir} ${env.backup_dir}" "Creating archive of config directory"
      log_to_file ""

      # Cleanup old archives
      log_section "Cleaning Up" "Removing old backup archives"
      run_command "cleanup ${env.backup_dir} 7 --yes" "Cleaning up old archives"
      log_to_file ""

      # Sync to cloud storage
      log_section "Cloud Sync" "Syncing backups to cloud storage"
      run_command "rclone-sync ${env.backup_dir} backups" "Syncing backups to cloud storage"
      log_to_file ""

      # Start containers
      log_section "Starting Containers" "Starting OCI containers after backup"
      run_command "oci-containers start" "Starting OCI containers"
      log_to_file ""

      # Log successful completion
      log_session_footer
    }

    # Error handling - ensure containers are started even if script fails
    cleanup() {
      local exit_code=$?

      if [ $exit_code -ne 0 ]; then
        log_session_error $exit_code

        log_section "Emergency Cleanup" "Attempting to restart containers after failure"
        log_warning "Script failed, attempting to start containers as cleanup..."

        if oci-containers start >/dev/null 2>&1; then
          log_success "Containers started successfully during cleanup"
        else
          log_error "Failed to start containers during cleanup"
        fi

        log_to_file ""
      fi
    }

    trap cleanup EXIT

    main
  '';
in
{
  environment.systemPackages = [
    backup-appdata
  ];
}
