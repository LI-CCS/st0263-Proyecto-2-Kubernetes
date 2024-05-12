#!/bin/bash

# Verificar si se proporciona la IP del servidor NFS como argumento
if [ $# -ne 1 ]; then
    echo "Usage: $0 <nfs-server-ip>"
    exit 1
fi

# Asignar el argumento proporcionado a una variable
nfs_server_ip=$1

# Create the env directory if it doesn't exist
mkdir -p manifests/env

# Delete existing ConfigMap if it exists
microk8s kubectl delete configmap nfs-server-config --ignore-not-found=true


# Create the ConfigMap manifest
cat <<EOF > manifests/env/01-configmap-nfs-client.yml
apiVersion: v1
kind: ConfigMap
metadata:
  name: nfs-server-config
data:
  NFS_SERVER_IP: $nfs_server_ip
EOF

# Apply the ConfigMap manifest
microk8s kubectl apply --force -f manifests/env/01-configmap-nfs-client.yml

# Delete existing StorageClass and PersistentVolumeClaim if they exist
microk8s kubectl delete sc nfs-csi --ignore-not-found=true
microk8s kubectl delete pvc nfs-pvc --ignore-not-found=true

# Apply the StorageClass and PersistentVolumeClaim manifest
microk8s kubectl apply --force -f manifests/04-sc-pvc-nfs.yml

echo "NFS configuration completed."
