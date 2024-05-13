#!/bin/bash

# Verificar si se proporciona la IP del servidor NFS como argumento
if [ $# -ne 1 ]; then
    echo "Usage: $0 <nfs-server-ip>"
    exit 1
fi


# Enable Helm3 and add the CSI Driver for NFS repository
microk8s enable helm3
microk8s helm3 repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
microk8s helm3 repo update

# Install the NFS driver
microk8s helm3 install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
    --namespace kube-system \
    --set kubeletDir=/var/snap/microk8s/common/var/lib/kubelet

# Apply the ConfigMap manifest
microk8s kubectl apply --force -f manifests/env/01-configmap-nfs-client.yml

# Delete existing StorageClass and PersistentVolumeClaim if they exist
microk8s kubectl delete -f manifests/04-sc-pvc-nfs.yml --ignore-not-found=true
# Apply the StorageClass and PersistentVolumeClaim manifest
microk8s kubectl apply --force -f manifests/04-sc-pvc-nfs.yml

echo "NFS configuration completed."
