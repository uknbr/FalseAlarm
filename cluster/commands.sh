#--- Init
ansible all -m ping -i florinda-cluster.ini
ansible-playbook pi.yaml -i florinda-cluster.ini
ansible-playbook main.yaml -i florinda-cluster.ini --become

#--- K3s
git clone https://github.com/k3s-io/k3s-ansible.git
cd k3s-ansible
cp -Rv inventory/sample/ inventory/florindabox
ansible-playbook site.yml -i inventory/florindabox/hosts.ini
scp pi@192.168.15.36:~/.kube/config ~/.kube/config

#--- Hello World (arm - myoung34/armhf-hello-kubernetes:latest)
git clone https://github.com/paulbouwer/hello-kubernetes.git
cd hello-kubernetes/deploy/helm/
helm install --create-namespace --namespace hello-kubernetes custom-message ./hello-kubernetes --set message="Running from my RPi cluster (florindabox)" --set ingress.configured=true --set ingress.pathPrefix="/app/hello-kubernetes/" --set service.type="ClusterIP"