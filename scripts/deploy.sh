#!/bin/bash

# Delete manifest files if they exist
microk8s kubectl delete -f manifests/ --ignore-not-found=true

# Apply manifest files
microk8s kubectl apply -f manifests/

echo "Manifest files applied."