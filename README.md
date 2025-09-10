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

## Services

- `/etc/systemd/system/url_monitor.service` - how to run the script - url_monitor.sh
- `/etc/systemd/system/url_monitor.timer` - when to run the script automatically, by starting the service at scheduled times


## Usage

The provided **.sh scripts** have been secured using encryption. To obtain access, please contact me directly.
I will provide the required password and decryption instructions upon request.

Significant time and effort have been invested in developing and securing these scripts. As outlined in the LICENSE agreement, distribution is not free. 
Please review the LICENSE for full details regarding usage and distribution terms.

## REFER **readme_step_by_step.txt** for STEP BY STEP INSTRUCTIONS ##

## License

MIT License

## Author

Raj Mohan Acharya

## SCRIPT WORKFLOW ##

<img width="512" height="768" alt="script-workflow" src="https://github.com/user-attachments/assets/11163db2-c3bd-4cfa-ad75-92b837645e8c" />

## Sample Screenshots ##

<img width="866" height="296" alt="image" src="https://github.com/user-attachments/assets/785db99f-7992-4cba-9f88-64095ae1a92b" />

<img width="1157" height="187" alt="image" src="https://github.com/user-attachments/assets/dca4b2ed-9389-48d0-ab38-7f2de4f7ea7a" />

<img width="595" height="71" alt="image" src="https://github.com/user-attachments/assets/48aa13ef-7f22-4fad-83d2-0da7eee57ee4" />

<img width="1047" height="277" alt="image" src="https://github.com/user-attachments/assets/c555311f-ce8b-4ae6-86d4-1ee29b39c494" />

<img width="1053" height="274" alt="image" src="https://github.com/user-attachments/assets/44b7eb82-90a8-4407-9ce0-bfa032d3728e" />

<img width="517" height="266" alt="image" src="https://github.com/user-attachments/assets/fed59539-bc82-41c5-b271-ff9d479817e8" />

<img width="1155" height="360" alt="image" src="https://github.com/user-attachments/assets/a11bed14-2120-4ca5-b54c-a0994ec9c500" />

<img width="834" height="110" alt="image" src="https://github.com/user-attachments/assets/8676820e-98cb-478f-8ac0-cdbe14ce4e72" />









