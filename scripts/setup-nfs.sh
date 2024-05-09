#!/bin/bash

# Check if the variable is defined
if [ -z "$NFS_SERVER_IP" ]; then
    echo "The NFS_SERVER_IP environment variable is not defined."
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

# Apply the StorageClass and PersistentVolumeClaim manifest
cd ../manifests
microk8s kubectl apply -f 04-sc-pvc-nfs.yaml

echo "CSI Driver for NFS installed successfully."
echo "NFS configuration completed."
