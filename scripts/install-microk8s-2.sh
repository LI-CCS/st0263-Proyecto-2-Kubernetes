#!/bin/bash 

# Enable required MicroK8s services
microk8s enable dashboard dns registry istio

# Output instructions for post-installation steps
echo "MicroK8s services enabled successfully."
echo "You should now be able to access the Kubernetes dashboard. Thats it for now."
echo "Happy Kubernetting!"