{
  pkgs,
  ...
}:
let
  oci-containers = pkgs.writeShellScriptBin "oci-containers" ''
    # Space-separated list of services to whitelist
    WHITELIST="docker-prune.service"

    if [ $# -ne 1 ]; then
      echo "Usage: $0 <start|stop|restart>"
      echo ""
      echo "Examples:"
      echo "  $0 stop     # Stop all docker services (except whitelisted)"
      echo "  $0 start    # Start all docker services (except whitelisted)"
      echo "  $0 restart  # Restart all docker services (except whitelisted)"
      exit 1
    fi

    ACTION=$1

    case $ACTION in
      start|stop|restart)
        # Valid action, continue
        ;;
      *)
        echo "Error: Invalid action '$ACTION'"
        echo "Valid actions are: start, stop, restart"
        exit 1
        ;;
    esac

    echo "=== Docker Service Manager - $ACTION ==="
    echo ""

    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
      echo "This script requires root privileges to control systemd services."
      echo ""
      read -p "Do you want to run this script with sudo? (y/n): " confirm
      echo ""

      if [[ $confirm =~ ^[Yy]$ ]]; then
        echo "Re-running with sudo..."
        echo ""
        exec sudo "$0" "$@"
      else
        echo "Cannot proceed without root privileges. Exiting."
        exit 1
      fi
    fi

    echo "1. Searching for services matching pattern: docker-*.service"
    all_services=$(systemctl list-unit-files --type=service)
    docker_services=$(echo "$all_services" | grep -E '^docker-.*\.service')
    service_count=$(echo "$docker_services" | wc -l)
    echo "   Found $service_count Docker services"

    echo ""
    echo "2. Whitelisted services (will NOT be affected):"
    for service in $WHITELIST; do
      echo "   - $service"
    done

    echo ""
    echo "3. Filtering out whitelisted services..."
    services_to_affect="$docker_services"

    for service in $WHITELIST; do
      services_to_affect=$(echo "$services_to_affect" | grep -v "$service")
    done

    service_names=$(echo "$services_to_affect" | awk '{print $1}')

    echo ""
    echo "4. Services that will be "$ACTION"ed:"
    if [ -z "$service_names" ]; then
      echo "   (No services found to $ACTION)"
      exit 0
    else
      echo "$service_names" | sed 's/^/   - /'
    fi

    echo ""
    echo "5. Processing services..."

    case $ACTION in
      start)
        echo "$service_names" | xargs systemctl start
        ;;
      stop)
        echo "$service_names" | xargs systemctl stop
        ;;
      restart)
        echo "$service_names" | xargs systemctl restart
        ;;
    esac

    echo "   ✓ Complete! Services have been "$ACTION"ed."
  '';
in
{
  environment.systemPackages = [
    oci-containers
  ];
}
