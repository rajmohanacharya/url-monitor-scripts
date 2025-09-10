# GOAL # 
Monitor URLs from any Linux Server via Bash Scripts for Every X minutes and if they are persistently DOWN after configured Y minutes,  alert via Email | Slack

# URL Monitor Scripts

A robust Bash-based URL monitoring system for Linux, featuring persistent alerting, automated scheduling with systemd, and interactive administration.

## Features

- URL and service health monitoring with automatic polling at configurable intervals
- Email and Slack notifications for downtime and recovery
- Configurable threshold for consecutive failures before alerts fire
- Systemd integration (url_monitor.service and url_monitor.timer) for robust scheduling
- Interactive setup
- Admin tool (url_monitor_admin.sh): Pause/resume monitor, interactively add/remove URLs, emails, or Slack webhook

## Files

- `url_monitor.sh` - Main monitoring script.
- `setup_url_monitor.sh` - Interactive installer for systemd service and timer.
- `url_monitor_admin.sh` - Interactive administrator tool for pausing/resuming, adding/removing URLs/emails/SlackWebhook.
- `check_url_monitor_heartbeat_encrypted.sh` - To Check Last Script RunTime vs Current Time.
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









