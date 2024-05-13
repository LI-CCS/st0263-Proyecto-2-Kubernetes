#!/bin/bash

# Delete manifest files if they exist
microk8s kubectl delete -f manifests/ --ignore-not-found=true

# Delete kustomization files if they exist
microk8s kubectl delete -k . --ignore-not-found=true

# Apply manifest files
microk8s kubectl apply -f manifests/

# Apply kustomization files
microk8s kubectl apply -k .

echo "Manifest files applied."