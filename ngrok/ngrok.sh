# GoTTY
wget https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_arm.tar.gz
tar xf gotty_linux_arm.tar.gz
./gotty -v
./gotty -p 6060 htop

# Ngrok
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm64.zip
unzip ngrok-stable-linux-arm64.zip
./ngrok -v
./ngrok authtoken <token>
./ngrok http 6060

