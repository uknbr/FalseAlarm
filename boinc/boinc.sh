# Install
aptitude search boinc
sudo aptitude install boinc

# Start manager - GUI
boincmgr

# Service
systemctl status boinc-client
boinc --fetch_minimal_work
ls /lib/systemd/system/boinc-client.service

# CLI
boinccmd --get_tasks
boinccmd --get_state
boinccmd --get_disk_usage
boinccmd --acct_mgr info
boinccmd --get_simple_gui_info

# Config
vim /var/lib/boinc-client/cc_config.xml
sudo cp /boot/config.txt /boot/config.bkp
sudo echo "arm_64bit=1" >> /boot/config.txt

# User manual
#https://boinc.berkeley.edu/wiki/User_manual

# Balena team
#https://github.com/balenalabs/rosetta-at-home/tree/raspberrypi4-4gb