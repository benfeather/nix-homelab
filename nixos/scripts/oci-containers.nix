{
  pkgs,
  ...
}:
let
  oci-containers = pkgs.writeShellScriptBin "oci-containers" ''
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

    # Space-separated list of services to whitelist
    WHITELIST="docker-prune.service"

    # Enhanced logging functions
    print_header() {
        echo -e "$BOLD$BLUE┌─────────────────────────────────────────────────────────────────────────────┐$NC"
        echo -e "$BOLD$BLUE│                       🐳 Docker Service Manager                             │$NC"
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

    usage() {
        print_header
        echo -e "$BOLD"Usage:"$NC $0 <start|stop|restart|upgrade> [container_name1 container_name2 ...]"
        echo ""
        echo -e "$BOLD$WHITE"Actions:"$NC"
        echo -e "  $CYAN"start"$NC     : Start Docker services"
        echo -e "  $CYAN"stop"$NC      : Stop Docker services"
        echo -e "  $CYAN"restart"$NC   : Restart Docker services"
        echo -e "  $CYAN"upgrade"$NC   : Pull latest images and restart services"
        echo ""
        echo -e "$BOLD$WHITE"Arguments:"$NC"
        echo -e "  $WHITE"container_name"$NC : Name of container(s) without 'docker-' prefix"
        echo -e "  $GRAY"                  If omitted, operates on all Docker services$NC"
        echo ""
        echo -e "$BOLD$WHITE"Examples:"$NC"
        echo -e "  $GRAY$0 stop                    # Stop all Docker services$NC"
        echo -e "  $GRAY$0 start myapp             # Start docker-myapp.service$NC"
        echo -e "  $GRAY$0 restart myapp postgres  # Restart docker-myapp.service and docker-postgres.service$NC"
        echo -e "  $GRAY$0 upgrade myapp           # Pull latest myapp image and restart$NC"
        echo -e "  $GRAY$0 upgrade                 # Upgrade all containers$NC"
        echo ""
        exit 1
    }

    if [ $# -lt 1 ]; then
        usage
    fi

    ACTION=$1
    shift  # Remove action from arguments, leaving only container names

    case $ACTION in
      start|stop|restart|upgrade)
        # Valid action, continue
        ;;
      *)
        print_header
        log_error "Invalid action '$ACTION'"
        echo -e "   $WHITE"Valid actions are: "$CYAN"start"$NC, $CYAN"stop"$NC, $CYAN"restart"$NC, $CYAN"upgrade"$NC"
        echo ""
        exit 1
        ;;
    esac

    # Get action emoji and capitalize action
    case $ACTION in
      start)
        ACTION_EMOJI="▶️"
        ACTION_COLOR="$GREEN"
        ACTION_DISPLAY="Start"
        ;;
      stop)
        ACTION_EMOJI="⏸️"
        ACTION_COLOR="$RED"
        ACTION_DISPLAY="Stop"
        ;;
      restart)
        ACTION_EMOJI="🔄"
        ACTION_COLOR="$YELLOW"
        ACTION_DISPLAY="Restart"
        ;;
      upgrade)
        ACTION_EMOJI="⬆️"
        ACTION_COLOR="$PURPLE"
        ACTION_DISPLAY="Upgrade"
        ;;
    esac

    print_header
    echo -e "  $ACTION_COLOR$BOLD$ACTION_EMOJI Action: $ACTION_DISPLAY Docker Services$NC"
    echo ""

    # Check if specific containers were specified
    if [ $# -gt 0 ]; then
        # Specific containers requested
        print_section "🎯 Target Mode" "Operating on specified containers..."

        service_names=""
        invalid_services=""

        for container in "$@"; do
            service="docker-$container.service"

            # Check if service exists
            if systemctl list-unit-files --type=service 2>/dev/null | grep -q "^$service"; then
                # Check if service is whitelisted
                is_whitelisted=0
                for whitelist_service in $WHITELIST; do
                    if [ "$service" = "$whitelist_service" ]; then
                        is_whitelisted=1
                        log_warning "Skipping $service (whitelisted)"
                        break
                    fi
                done

                if [ $is_whitelisted -eq 0 ]; then
                    service_names="$service_names$service"$'\n'
                    log_info "Added: $service"
                fi
            else
                invalid_services="$invalid_services$service"$'\n'
                log_error "Not found: $service"
            fi
        done

        # Remove trailing newline
        service_names=$(echo "$service_names" | sed '/^$/d')
        invalid_services=$(echo "$invalid_services" | sed '/^$/d')

        if [ -n "$invalid_services" ]; then
            echo ""
            log_error "Some specified services do not exist. Aborting."
            exit 1
        fi
    else
        # No specific containers, operate on all
        print_section "🔍 Service Discovery" "Searching for Docker services..."
        log_step "Scanning systemctl for docker-*.service patterns..."

        all_services=$(systemctl list-unit-files --type=service 2>/dev/null)
        docker_services=$(echo "$all_services" | grep -E '^docker-.*\.service' || true)
        service_count=$(echo "$docker_services" | wc -l)

        if [ -z "$docker_services" ] || [ $service_count -eq 0 ]; then
            log_warning "No Docker services found matching pattern docker-*.service"
            exit 0
        fi

        log_success "Found $service_count Docker services"

        print_section "🛡️  Whitelist Configuration" "Services that will be protected from changes..."
        if [ -n "$WHITELIST" ]; then
            for service in $WHITELIST; do
                echo -e "   $GRAY   • $service$NC"
            done
        else
            log_info "No services whitelisted - all Docker services will be affected"
        fi

        print_section "🔧 Service Filtering" "Removing whitelisted services from operation..."
        log_step "Filtering out protected services..."

        services_to_affect="$docker_services"
        for service in $WHITELIST; do
            services_to_affect=$(echo "$services_to_affect" | grep -v "$service" || true)
        done

        service_names=$(echo "$services_to_affect" | awk '{print $1}')
    fi

    print_section "📋 Target Services" "Services that will be ""$ACTION""ed..."
    if [ -z "$service_names" ]; then
        log_warning "No services found to $ACTION after filtering"
        echo ""
        print_separator
        echo -e "  $BOLD$YELLOW🤷 No Action Required$NC"
        print_separator
        echo ""
        exit 0
    else
        echo "$service_names" | while read -r service; do
            echo -e "   $GRAY   • $service$NC"
        done
    fi

    affected_count=$(echo "$service_names" | wc -l)
    log_info "Total services to $ACTION: $affected_count"

    print_section "$ACTION_EMOJI Processing Services" "Executing $ACTION operation on target services..."

    case $ACTION in
      start)
        log_step "Starting services..."
        if echo "$service_names" | xargs systemctl start 2>/dev/null; then
            log_success "All services started successfully!"
        else
            log_error "Some services failed to start"
            exit 1
        fi
        ;;
      stop)
        log_step "Stopping services..."
        if echo "$service_names" | xargs systemctl stop 2>/dev/null; then
            log_success "All services stopped successfully!"
        else
            log_error "Some services failed to stop"
            exit 1
        fi
        ;;
      restart)
        log_step "Restarting services..."
        if echo "$service_names" | xargs systemctl restart 2>/dev/null; then
            log_success "All services restarted successfully!"
        else
            log_error "Some services failed to restart"
            exit 1
        fi
        ;;
      upgrade)
        log_step "Upgrading containers..."
        upgrade_failed=0
        upgrade_count=0

        echo "$service_names" | while read -r service; do
            # Extract container name from service name (remove docker- prefix and .service suffix)
            container_name=$(echo "$service" | sed 's/^docker-//' | sed 's/\.service$//')

            echo ""
            log_info "Processing: $container_name"

            # Get the image name from the running/stopped container or service definition
            image=$(docker inspect --format='{{.Config.Image}}' "$container_name" 2>/dev/null)

            if [ -z "$image" ]; then
                # Container might not exist yet or is not running, try to extract from service file
                log_warning "Container not found, attempting to extract image from service definition..."
                image=$(systemctl cat "$service" 2>/dev/null | grep -oP '(?<=--image=)[^ ]+' | head -1)

                if [ -z "$image" ]; then
                    log_error "Could not determine image for $container_name"
                    continue
                fi
            fi

            log_step "Image: $image"
            log_step "Pulling latest version..."

            if docker pull "$image" 2>&1 | while IFS= read -r line; do
                echo -e "$GRAY      $line$NC"
            done; then
                log_success "Image pulled successfully"

                log_step "Restarting service..."
                if systemctl restart "$service" 2>/dev/null; then
                    log_success "Service restarted: $service"
                    upgrade_count=$((upgrade_count + 1))
                else
                    log_error "Failed to restart service: $service"
                    upgrade_failed=1
                fi
            else
                log_error "Failed to pull image: $image"
                upgrade_failed=1
            fi
        done

        echo ""
        if [ $upgrade_failed -eq 0 ]; then
            log_success "All containers upgraded successfully!"
        else
            log_warning "Some containers failed to upgrade"
        fi
        ;;
    esac

    echo ""
    print_separator
    echo -e "  $BOLD$GREEN🎉 Operation Completed Successfully! 🎉$NC"
    print_separator
    echo -e "  $CYAN📊 Summary:$NC $WHITE$affected_count services ""$ACTION""ed$NC"
    echo ""
  '';
in
{
  environment.systemPackages = [
    oci-containers
  ];
}
