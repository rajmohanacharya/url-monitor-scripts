# GOAL # 
Monitor URLs from any Linux Server via Bash Scripts for Every X minutes and if they are DOWN, alert via Email | Slack

# URL Monitor Scripts

This repository contains bash scripts and systemd configuration to monitor a list of URLs periodically, send email and Slack alerts on downtime or recovery, and manage the monitoring service using systemd timers.

## Features

- Interactive setup for URLs, multiple email recipients, and Slack webhook.
- Checks URL status at configurable intervals.
- Sends email and Slack alerts on URL status changes.
- Maintains logs with automatic rotation and compression.
- State tracking per URL to avoid alert spam.
- Systemd timer for automated periodic execution.
- Scripts to manage systemd timer (pause, resume, disable).
- Self Healing, Self Start mechanism, catering to Server Reboot or Manual Killing of Script Processes

## Files

- `url_monitor.sh` - Main monitoring script.
- `setup_url_monitor.sh` - Interactive installer for systemd service and timer.
- `manage_url_monitor_timer.sh` - Script to pause, resume, or disable the monitor timer.
- `/etc/url_monitor_config.conf` - Config file storing URLs, emails, and Slack webhook (created after setup).
- `/tmp/url_monitor_states/` - Directory storing per-URL state files (created during runtime).
- `/tmp/url_monitor_heartbeat` - Timestamp file updated on each successful run.
- `/var/log/url_monitor.log` - Log file with rotation and compression.

## Usage

## REFER **readme_step_by_step.txt** for STEP BY STEP INSTRUCTIONS ##

## License

MIT License

## Author

Raj Mohan Acharya

## SCRIPT WORKFLOW ##

<img width="512" height="768" alt="script-workflow" src="https://github.com/user-attachments/assets/11163db2-c3bd-4cfa-ad75-92b837645e8c" />

