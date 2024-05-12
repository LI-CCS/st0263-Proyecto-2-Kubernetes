#!/bin/bash

# Update packages
sudo apt update

# Install NFS server
sudo apt install -y nfs-kernel-server

# Create the directory to be shared
sudo mkdir -p /mnt/wordpress

# Change the owner of the directory
sudo chown nobody:nogroup /mnt/wordpress

# Change the permissions of the directory
sudo chmod 777 /mnt/wordpress

# Edit the /etc/exports file and add the configuration line
sudo sh -c 'echo "/mnt/wordpress *(rw,sync,no_subtree_check)" >> /etc/exports'

# Create the directory to be shared
sudo mkdir -p /mnt/mysql

# Change the owner of the directory
sudo chown nobody:nogroup /mnt/mysql

# Change the permissions of the directory
sudo chmod 777 /mnt/mysql

# Edit the /etc/exports file and add the configuration line
sudo sh -c 'echo "/mnt/mysql *(rw,sync,no_subtree_check)" >> /etc/exports'

# Restart the NFS service
sudo systemctl restart nfs-kernel-server

echo "NFS server installed and configured successfully."
