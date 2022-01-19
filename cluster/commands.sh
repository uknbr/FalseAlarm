#--- K3s
# Clone
git clone https://github.com/k3s-io/k3s-ansible.git
cd k3s-ansible
# Hosts
cp -Rv inventory/sample/ inventory/florindabox
# Uninstall
ansible-playbook reset.yml -i inventory/florindabox/hosts.ini
# Install
ansible-playbook site.yml -i inventory/florindabox/hosts.ini
# Kubeconfig
ssh pi@192.168.15.36 'cat ~/.kube/config' | sed 's/default/florindabox/g' | tee ~/.kube/config

#--- Ansible roles
# Ping
ansible all -m ping
# Basic Setup
ansible-playbook setup.yaml
# RPi temperature
ansible-playbook temp.yaml
# Deploy Hello App
ansible-playbook hello.yaml
# Install Ngrok
ansible-playbook ngrok.yaml
# Install PiHole
ansible-playbook pihole.yaml

#--- NFS
sudo fdisk -l
sudo mkdir -p /mnt/hd
sudo chown -R pi:pi /mnt/hd/
sudo mount -t ntfs-3g -o nofail,uid=1000,gid=1000,umask=007 /dev/sda1 /mnt/hd

sudo blkid /dev/sda1
echo "PARTUUID=e1094f4b-01  /mnt/hd         ntfs    defaults,nofail,uid=1000,gid=1000,umask=022       0       0" | sudo tee -a /etc/fstab

sudo apt-get install nfs-kernel-server -y
echo "/mnt/hd/florinda/nfs *(rw,sync,no_root_squash,subtree_check)" | sudo tee -a /etc/exports
echo "/mnt/hd/florinda/share *(rw,sync,no_root_squash,subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -ra

sudo apt-get install nfs-common -y
sudo mkdir -p /mnt/hd/florinda/nfs
sudo chown -R pi:pi /mnt/hd/
echo "192.168.15.36:/mnt/hd/florinda/nfs   /mnt/hd/florinda/nfs   nfs    rw  0  0" | sudo tee -a /etc/fstab
sudo mount -a

#--- Monitoring
#git clone https://github.com/cablespaghetti/k3s-monitoring
#cd k3s-monitoring
#k label nodes worker1 type=worker
#k label nodes worker2 type=worker
#helm upgrade --install prometheus prometheus-community/kube-prometheus-stack --version 13.4.1 --values kube-prometheus-stack-values.yaml
k label nodes master type=master
k label nodes worker1 type=worker
k label nodes worker2 type=worker
k apply -f monitoring/

# InfluxDB
docker run --rm influxdb:1.8 influxd config > influxdb.conf
docker run -dti --name influxdb -p 8086:8086 -v $PWD/influxdb.conf:/etc/influxdb/influxdb.conf:ro influxdb:1.8 -config /etc/influxdb/influxdb.conf