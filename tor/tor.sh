# Installation
aptitude install tor

# Service
systemctl list-unit-files | grep -i tor
service tor status
service tor@default.service status
systemctl restart tor@default.service
systemctl status tor@default.service

# Config
cd /etc/tor/
cp torrc torrc.bkp
diff torrc torrc.bkp
ls torsocks.conf
ls /run/tor/control.authcookie

# Page
cd /var/lib/tor/hidden_service/
cat /var/lib/tor/hidden_service/hostname

# Log
less /var/log/tor/notices.log
