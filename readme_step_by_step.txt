---------------------------------------------------___STEP_1_____---------------------------------------------------

>>> Download of Scripts and Setup to be performed as ROOT
>>> It is expected or assumed that URLs to be MONITORED from this server, are already tested / verified REACHABLE and showing HTTP_CODE either 2XX or 3XX, Else Please select a different working machine or work with Network / Server team and ALLOW ports from Destination URL to this SERVER
>>> It is expected or assumed that Linux Machine has POSTFIX Installed and SMTP Setup Done else, please configure
>>> It is expected that Linux Machine has necessary network ports allowed to Slack WebHool URL, (test this via CURL against the URL), else, Please work with your Org Network Team and get this to work

---------------------------------------------------___STEP_2_____---------------------------------------------------

You will need to download url_monitor.sh to /usr/local/bin/ and enable CHMOD +X

You will need to dowload check_url_monitor_heartbeat.sh || manage_url_monitor_timer.sh || setup_url_monitor.sh to either /tmp or /home/YOURUSER or any SHARED folder which does not have FILE/FOLDER PERMISSION RESTRICTIONS and enable CHMOD +X

---------------------------------------------------___STEP_3_____---------------------------------------------------

--> #1 SETUP for Initial Config File Run

1. RUN /usr/local/bin/url_monitor.sh

It will ask to Enter LIST of URL, once typed, to exit, enter on BLANK prompt
Next, It will ask to Enter LIST of Destination Email-ids, once typed, to exit, enter on BLANK prompt
Next, it will ask to enter slack webhook URL, type or ignore

--> #2 SETUP for Automated Scheduled Run

1. RUN ./setup_url_monitor.sh

It will ask to enter frequency of script to run between 2-60 minutes, SELECT a NUMBER

---------------------------------------------------___STEP_4_____---------------------------------------------------

$$__CONFIG_&_LOG_FILES_GENERATED_AFTER_RUNNING_ABOVE_$$


/etc/systemd/system/url_monitor.service - SYSTEMD SERVICE OF THE MAIN SCRIPT
/etc/systemd/system/url_monitor.timer - SYSTEMD SERVICE RUNNING THE ABOVE MAIN SCRIPT EVERY X MINUTES


/etc/url_monitor_config.conf  --> List of URLs / Desination-Email-ID / Slack Webhook URL

/tmp/url_monitor_states       --> last known status (UP or DOWN) for a specific URL
/var/log/url_monitor.log      --> Log file for recording URL DOWN events and script errors.
/tmp/url_monitor_heartbeat    --> Unix timestamp of the last successful RUN

---------------------------------------------------___STEP_5_____---------------------------------------------------


$$__SECONDARY_SCRIPTS_SYNTAX_AND_USAGE__$$

======>__MANAGE_URL_MONITOR_TIMER.SH__<======

--Temporarily pause for 10 minutes:--
./manage_url_monitor_timer.sh pause 10

--Pause indefinitely until manually resumed:--
./manage_url_monitor_timer.sh pause 0

--Resume timer manually:--
./manage_url_monitor_timer.sh resume

--Permanently disable and uninstall service and timer:--
./manage_url_monitor_timer.sh disable

--Check status of timer and service:--
./manage_url_monitor_timer.sh status

======>__CHECK_URL_MONITOR_HEARTBEAT.SH__<======

Tells us when main scripts last run VS current time - it SHOULD NOT BE MORE THAN X MINUTES SET INITIALLY FOR AUTOMATED SCHEDULED RUN
./check_url_monitor_heartbeat.sh

---------------------------------------------------___STEP_6_____---------------------------------------------------

IF YOU NEED TO ADD or REMOVE URLS or EMAIL IDS - FOLLOW THE BELOW

./manage_url_monitor_timer.sh pause 0
---EDIT /etc/url_monitor_config.conf and UPDATE under URLs Section---
----NOTE : NO NEED TO PROVIDE DELIMITER LIKE COLON or COMMA, Just ENTER in new line contained in DOUBLE QUOTES--
./manage_url_monitor_timer.sh resume
---VERIFY /tmp/url_monitor_states and you should new files there for new URLs

---------------------------------------------------___STEP_7_____---------------------------------------------------

URL Down History Logs are located at /var/log/url_monitor.log

---------------------------------------------------___STEP_8_____---------------------------------------------------

Any issue / suggestions / improvement Reach out to https://github.com/rajmohanacharya/

--------------------------------------------------------------------------------------------------------------------

