#!/bin/bash

# Actualizar los paquetes
sudo apt update

# Instalar el servidor NFS
sudo apt install -y nfs-kernel-server

# Crear el directorio a compartir
sudo mkdir -p /mnt/wordpress

# Cambiar el propietario del directorio
sudo chown nobody:nogroup /mnt/wordpress

# Cambiar los permisos del directorio
sudo chmod 777 /mnt/wordpress

# Editar el archivo /etc/exports y añadir la línea de configuración
sudo sh -c 'echo "/mnt/wordpress *(rw,sync,no_subtree_check)" >> /etc/exports'

# Reiniciar el servicio de NFS
sudo systemctl restart nfs-kernel-server

echo "Servidor NFS instalado y configurado correctamente."
