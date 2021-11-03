#--- Init
ansible all -m ping -i florinda-cluster.ini
ansible-playbook temp.yaml -i florinda-cluster.ini
ansible-playbook main.yaml -i florinda-cluster.ini --become

#--- NFS
sudo fdisk -l
sudo mkdir -p /mnt/hd
sudo chown -R pi:pi /mnt/hd/
sudo mount -t ntfs-3g -o nofail,uid=1000,gid=1000,umask=007 /dev/sda1 /mnt/hd

sudo blkid /dev/sda1
echo "PARTUUID=e1094f4b-01  /mnt/hd         ntfs    defaults          0       0" | sudo tee -a /etc/fstab

sudo apt-get install nfs-kernel-server -y
echo "/mnt/hd/florinda/nfs *(rw,sync,no_root_squash,subtree_check)" | sudo tee -a /etc/exports
sudo exportfs -ra

sudo apt-get install nfs-common -y
sudo mkdir -p /mnt/hd/florinda/nfs
sudo chown -R pi:pi /mnt/hd/
echo "192.168.15.36:/mnt/hd/florinda/nfs   /mnt/hd/florinda/nfs   nfs    rw  0  0" | sudo tee -a /etc/fstab
sudo mount -a

#--- K3s
git clone https://github.com/k3s-io/k3s-ansible.git
cd k3s-ansible
cp -Rv inventory/sample/ inventory/florindabox
ansible-playbook site.yml -i inventory/florindabox/hosts.ini
scp pi@192.168.15.36:~/.kube/config ~/.kube/config
k get no

#--- Hello World
k create ns hello
k -n hello apply -f hello.yaml
curl -I http://192.168.15.36.traefik.me/

#--- Ngrok
ansible-playbook ngrok.yaml -i florinda-cluster.ini --extra-vars "@ngrok-token.yaml" --become

#--- PiHole
helm repo add mojo2600 https://mojo2600.github.io/pihole-kubernetes/
helm repo update
helm search repo pihole
helm pull mojo2600/pihole --version 2.5.0
helm show values pihole-2.5.0.tgz > pihole.yaml
k label nodes worker1 app=pihole
k label nodes worker2 app=pihole
k create namespace pihole
ssh worker1 'sudo mkdir -p /data ; sudo chmod 777 /data'
k apply -f ../pihole/pihole.persistentvolume.yml
k apply -f ../pihole/pihole.persistentvolumeclaim.yml
k create secret generic pihole-secret --from-literal='password=admin' --namespace pihole
helm upgrade -i -n pihole pihole mojo2600/pihole --values ../pihole/pihole.yaml