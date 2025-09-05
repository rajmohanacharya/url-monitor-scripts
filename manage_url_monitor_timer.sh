#!/bin/bash
#Created by RajMohanAcharya
HEARTBEAT_FILE="/tmp/url_monitor_heartbeat"

if [ ! -f "$HEARTBEAT_FILE" ]; then
    echo "Heartbeat file $HEARTBEAT_FILE not found."
    exit 1
fi

last_timestamp=$(cat "$HEARTBEAT_FILE")
last_date=$(date -d "@$last_timestamp")

current_date=$(date)

echo "Last url_monitor.sh run time: $last_date"
echo "Current system time:         $current_date"

[root@d199c1h1kk rajmo]# cat manage_url_monitor_timer.sh
#!/bin/bash
#Created by RajMohanAcharya

TIMER_NAME="url_monitor.timer"
SERVICE_NAME="url_monitor.service"

print_usage() {
    echo "Usage:"
    echo "  $0 pause <minutes>    # Temporarily disable timer for <minutes> (0 means pause indefinitely)"
    echo "  $0 resume            # Resume timer if paused"
    echo "  $0 disable           # Permanently disable and uninstall timer and service"
    echo "  $0 status            # Show timer and service status"
    exit 1
}

if [ $# -lt 1 ]; then
    print_usage
fi

case "$1" in
    pause)
        if [ -z "$2" ] || ! [[ "$2" =~ ^[0-9]+$ ]]; then
            echo "Please specify number of minutes to pause or 0 for indefinite."
            exit 1
        fi
        MINUTES=$2

        echo "Stopping and disabling $TIMER_NAME temporarily..."
        sudo systemctl stop "$TIMER_NAME"
        sudo systemctl disable "$TIMER_NAME"

        if [ "$MINUTES" -gt 0 ]; then
            echo "Timer paused for $MINUTES minutes..."

            # Run background sleep + resume timer
            (
                sleep "${MINUTES}m"
                echo "Resuming $TIMER_NAME after pause."
                sudo systemctl enable --now "$TIMER_NAME"
            ) & disown
        else
            echo "Timer paused indefinitely. Run '$0 resume' to restart."
        fi
        ;;

    resume)
        echo "Enabling and starting $TIMER_NAME..."
        sudo systemctl enable --now "$TIMER_NAME"
        ;;

    disable)
        echo "Stopping, disabling, and uninstalling $TIMER_NAME and $SERVICE_NAME..."

        sudo systemctl stop "$TIMER_NAME"
        sudo systemctl disable "$TIMER_NAME"

        sudo systemctl stop "$SERVICE_NAME"
        sudo systemctl disable "$SERVICE_NAME"

        echo "Removing systemd service and timer files..."
        sudo rm -f "/etc/systemd/system/$TIMER_NAME"
        sudo rm -f "/etc/systemd/system/$SERVICE_NAME"

        sudo systemctl daemon-reload
        echo "Uninstall complete."
        ;;

    status)
        echo "Status of $TIMER_NAME:"
        sudo systemctl status "$TIMER_NAME"

        echo -e "\nStatus of $SERVICE_NAME:"
        sudo systemctl status "$SERVICE_NAME"
        ;;

    *)
        print_usage
        ;;
esac

