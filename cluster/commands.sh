#--- Init
ansible all -m ping -i cluster/florinda-cluster.ini
ansible-playbook cluster/main.yaml -i cluster/florinda-cluster.ini --become

#--- K3s
git clone https://github.com/k3s-io/k3s-ansible.git
cd k3s-ansible
cp -Rv inventory/sample/ inventory/florindabox
ansible-playbook site.yml -i inventory/florindabox/hosts.ini
scp pi@92.168.15.13:~/.kube/config ~/.kube/config