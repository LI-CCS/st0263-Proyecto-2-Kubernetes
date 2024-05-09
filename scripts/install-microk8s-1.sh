#!/bin/bash

# Update the system
sudo apt update -y

# Install MicroK8s
sudo snap install microk8s --classic

# Add the current user to the 'microk8s' group
sudo usermod -aG microk8s $USER

# Create .kube directory if it doesn't exist
mkdir -p ~/.kube

# Change ownership of .kube directory to the current user
sudo chown -f -R $USER ~/.kube

# Add MicroK8s alias to the user's bashrc file if it's not already added
if ! grep -q "alias kubectl='microk8s kubectl'" ~/.bashrc; then
    echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
    source ~/.bashrc
fi

# Output instructions for post-installation steps
echo "MicroK8s installed successfully."
echo "You may need to log out and log back in for group membership changes to take effect."
echo "Then you should run the second script to finish the installation."
echo "Happy Kubernetting!"
