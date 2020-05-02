# Install
aptitude search boinc
sudo aptitude install boinc

# Start manager - GUI
boincmgr

# CLI
boinccmd --get_tasks
boinccmd --get_state
boinccmd --get_disk_usage
boinccmd --acct_mgr info
boinccmd --get_simple_gui_info

# Config
vim /var/lib/boinc-client/cc_config.xml

# User manual 
#https://boinc.berkeley.edu/wiki/User_manual