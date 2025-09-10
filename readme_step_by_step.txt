## Requirements

- Bash
- sudo privileges for config and service changes
- Postfix (or compatible sendmail), configured
- curl utility (for HTTP checks)
- Systemd (standard on modern Linux)

## Initial Interactive Setup

Copy url_monitor.sh to /usr/local/bin
Run -> sudo bash setup_url_monitor.sh

- Guides you through adding URLs, alert emails, Slack webhook, polling interval, and failure threshold (1-10).
- Creates the monitoring config and systemd units.
- Starts the scheduled monitor service.


