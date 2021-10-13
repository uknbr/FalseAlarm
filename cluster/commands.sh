#--- Init
ansible all -m ping -i florinda-cluster.ini
ansible-playbook temp.yaml -i florinda-cluster.ini
ansible-playbook main.yaml -i florinda-cluster.ini --become

#--- K3s
git clone https://github.com/k3s-io/k3s-ansible.git
cd k3s-ansible
cp -Rv inventory/sample/ inventory/florindabox
ansible-playbook site.yml -i inventory/florindabox/hosts.ini
scp pi@192.168.15.36:~/.kube/config ~/.kube/config
k get no

#--- Hello World
k apply -f hello.yaml
k get cronjob hello
k get job -w
k delete cronjob hello