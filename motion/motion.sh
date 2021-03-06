
# Install
sudo aptitude install motion

# Recorded files
ll /var/lib/motion/

# Config
cd /etc/motion/
cp motion.conf motion.bkp
diff motion.conf motion.bkp

# Daemon
vim /etc/default/motion

# Service
service motion status
service motion restart

