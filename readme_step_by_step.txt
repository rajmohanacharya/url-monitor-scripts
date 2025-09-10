## Requirements

- Bash
- sudo privileges for config and service changes
- Postfix (or compatible sendmail), configured
- curl utility (for HTTP checks)
- Systemd (standard on modern Linux)

## Initial Interactive Setup

Copy ```url_monitor.sh to /usr/local/bin```
Run -> ```sudo bash setup_url_monitor.sh```

- Guides you through adding URLs, alert emails, Slack webhook, polling interval, and failure threshold (1-10).
- Creates the monitoring config and systemd units.
- Starts the scheduled monitor service.

## Monitor Administration (url_monitor_admin.sh)

```sudo bash url_monitor_admin.sh```

# Interactive options:

- Pause monitoring: Temporarily stop all checks/scheduled alerts (systemd stop).
- Resume monitoring: Restart all checks (systemd start).
- Add/Remove URLs: Edit the list of monitored URLs on the fly.
- Add/Remove Emails: Update recipient list for alerts.
- Set Slack Webhook: Change or disable Slack notifications.
- Show Config: Review your effective /etc/url_monitor_config.conf.
- Show last URL Runtime and its Statuses
- All changes take immediate effect on the next scheduled monitor run.
- Uninstall : Remove everything (systemd / config / log files)

## How Monitoring & Scheduling Work

- url_monitor.sh runs your checks, logging results and sending alerts.
- url_monitor.service tells systemd how to run the monitoring script.
- url_monitor.timer schedules the job at the specified interval.
- Logs are rotated automatically and written to /var/log/url_monitor.log by default.

## Advanced

- All configuration is managed in /etc/url_monitor_config.conf.
- To change failure threshold or alert destinations, use the admin tool.
- For custom intervals or service options, rerun setup or edit systemd units directly.


