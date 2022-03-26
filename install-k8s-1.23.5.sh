#!/bin/bash

# TODO: Disable SWAP
# # /swap.img     none    swap    sw      0       0
# sudo swapoff -a

modprobe br_netfilter ip_vs ip_vs_rr ip_vs_sh ip_vs_wrr nf_conntrack_ipv4
mkdir -p /etc/modules-load.d
cat > /etc/modules-load.d/k8s.conf <<EOF
br_netfilter
ip_vs
ip_vs_rr
ip_vs_sh
ip_vs_wrr
nf_conntrack_ipv4
EOF


mkdir -p /etc/systemd/system/docker.service.d
mkdir -p /etc/docker/
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF


sudo systemctl daemon-reload
sudo systemctl restart docker


sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubectl kubelet kubeadm

kubeadm config images pull

# master
kubeadm init

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo 'source <(kubectl completion bash)' >>~/.bashrc
source ~/.bashrc


kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"


# workers
kubeadm join 192.168.100.51:6443 --token 0j36oq.mgs4j2gcffac19pc \
        --discovery-token-ca-cert-hash sha256:3cb3a7e150f33e63f60bb41a41a58d68f4ab5b87478d9fbcddc44e7cb600dc6a
