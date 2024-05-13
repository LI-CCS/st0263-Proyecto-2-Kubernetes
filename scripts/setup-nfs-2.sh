#!/bin/bash

# Verificar si se proporciona la IP del servidor NFS como argumento
if [ $# -ne 1 ]; then
    echo "Usage: $0 <nfs-server-ip>"
    exit 1
fi

# Asignar el argumento proporcionado a una variable
nfs_server_ip=$1

# Delete existing StorageClass and PersistentVolumeClaim if they exist
microk8s kubectl delete sc nfs-csi --ignore-not-found=true
microk8s kubectl delete pvc nfs-pvc --ignore-not-found=true

# Create if it does not exist the temporary directory for the NFS server
mkdir -p manifests/tmp

# Update the NFS server IP in the StorageClass and PersistentVolumeClaim manifest
cat manifests/04-sc-pvc-nfs.yml | sed "s/NFS_SERVER_IP/$nfs_server_ip/g" > manifests/tmp/04-sc-pvc-nfs.yml.tmp

# Apply the StorageClass and PersistentVolumeClaim manifest
microk8s kubectl apply --force -f manifests/tmp/04-sc-pvc-nfs.yml.tmp

echo "NFS configuration completed."
