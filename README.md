# ST0263 Tópicos Especiales en Telemática

- **Estudiante: Miguel Sosa, msosav@eafit.edu.co**
- **Estudiante: Miguel Jaramillo, mjaramil20@eafit.edu.co**
- **Estudiante: Sergio Córdoba, sacordobam@eafit.edu.co**

**Profesor: Edwin Montoya, emontoya@eafit.edu.co**

## Proyecto 2

### 1. Breve descripción de la actividad

Se debe desplegar una aplicación monolítica (Wordpress) en un clúster de Kubernetes montado en diferentes máquinas virtuales en IaaS nube AWS. Allí se debe considerar el manejo de volúmenes compartidos (Montar un servidor NFS) y la capa de acceso al clúster ya sea con un balanceador o con otras opciones como Service, Ingress o similar.

Se debe contar con nombre de dominio, https, balanceador, base de datos externa y sistema de archivos externos a la capa de servicios (app).

#### 1.1. Que aspectos cumplió o desarrolló de la actividad propuesta por el profesor (requerimientos funcionales y no funcionales)

- [x] Clúster de Kubernetes en diferentes máquinas virtuales en IaaS nube AWS.
- [ ] Desplegar una aplicación monolítica (Wordpress) en un clúster de Kubernetes.
- [ ] Base de datos.
- [x] Montar un servidor NFS.
- [ ] Capa de acceso al clúster con Service, Ingress o similar.
- [ ] Nombre de dominio.
- [ ] HTTPS.

#### 1.2. Que aspectos NO cumplió o desarrolló de la actividad propuesta por el profesor (requerimientos funcionales y no funcionales)

### 2. Información general de diseño de alto nivel, arquitectura, patrones, mejores prácticas utilizadas.

#### Arquitectura

Se accede mediante [https://ṕroyecto2.temporaladventures.tech](https://ṕroyecto2.temporaladventures.tech).

<p align="center">
  <img src="https://github.com/LI-CCS/st0263-Proyecto-2-Kubernetes/assets/85181687/6f69c046-1f0f-4f6c-a8d6-ec8a87ee9eb2" alt="Arquitectura">
</p>

### 3. Descripción del ambiente de desarrollo y técnico: lenguaje de programación, librerias, paquetes, etc, con sus numeros de versiones.

#### Máquinas virtuales en GCP

Se crearon 4 máquinas virtuales e2-medium en Google Cloud Platform con las siguientes características:

- **Ubuntu 22.04 LTS x86_64**
- **2 vCPUs**
- **4 GB de memoria**
- **20 GB de disco**

En la sección de **Firewall** se habilitó lo siguiente:

- [x] Tráfico HTTP
- [x] Tráfico HTTPS
- [x] Verificaciones de estado del balanceador de cargas

_**Nota:** Llamamos a las máquinas virtuales `microk8s-master`, `microk8s-worker-1`, `microk8s-worker-2` y `microk8s-nfs`._

#### NFS

_**Nota:** Se tiene que hacer en la máquina `microk8s-nfs`._

##### Opción 1: Script de Instalación de NFS

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/LI-CCS/st0263-Proyecto-2-Kubernetes.git
   ```

2. Ejecutar el script `nfs.sh`:

   ```bash
   cd st0263-Proyecto-2-Kubernetes
   ./scripts/install-nfs.sh
   ```

##### Opción 2: Instalación Manual de NFS

1. Instalar el servidor NFS con el siguiente comando:

   ```bash
   sudo apt update
   sudo apt install nfs-kernel-server
   ```

1. Crear el directorio que se compartirá:

   ```bash
   sudo mkdir -p /mnt/wordpress
   ```

1. Cambiar el propietario del directorio:

   ```bash
   sudo chown nobody:nogroup /mnt/wordpress
   ```

1. Cambiar los permisos del directorio:

   ```bash
   sudo chmod 777 /mnt/wordpress
   ```

1. Editar el archivo `/etc/exports`:

   ```bash
   sudo nano /etc/exports
   ```

   Añadir la siguiente línea:

   ```bash
   /mnt/wordpress *(rw,sync,no_subtree_check)
   ```

1. Crear el directorio que se compartirá:

   ```bash
   sudo mkdir -p /mnt/mysql
   ```

1. Cambiar el propietario del directorio:

   ```bash
   sudo chown nobody:nogroup /mnt/mysql
   ```

1. Cambiar los permisos del directorio:

   ```bash
   sudo chmod 777 /mnt/mysql
   ```

1. Editar el archivo `/etc/exports`:

   ```bash
   sudo nano /etc/exports
   ```

   Añadir la siguiente línea:

   ```bash
   /mnt/mysql *(rw,sync,no_subtree_check)
   ```

1. Reiniciar el servicio de NFS:
   ```bash
   sudo systemctl restart nfs-kernel-server
   ```

#### Instalación de MicroK8s en Ubuntu 22.04

_**Nota:** Se tiene que hacer por cada nodo._

##### Opción 1: Script de Instalación de MicroK8s

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/LI-CCS/st0263-Proyecto-2-Kubernetes.git
   ```

1. Ejecutar el script `install-microk8s-1.sh`:

   ```bash
   cd st0263-Proyecto-2-Kubernetes
   ./scripts/install-microk8s-1.sh
   ```

1. Salir de la sesión y volver a entrar.

1. Ejecutar el script `install-microk8s-2.sh`:

   ```bash
   cd st0263-Proyecto-2-Kubernetes
   ./scripts/install-microk8s-2.sh
   ```

##### Opción 2: Instalación Manual de MicroK8s

1. Actualizar el sistema:

   ```bash
   sudo apt update -y
   ```

1. Instalar MicroK8s con el siguiente comando:

   ```bash
   sudo snap install microk8s --classic
   ```

1. Añadir el usuario al grupo de microk8s:

   ```bash
   sudo usermod -a -G microk8s $USER
   ```

1. Crear el directorio `~/.kube`:

   ```bash
   mkdir -p ~/.kube
   ```

1. Añaadir el alias de `microk8s.kubectl`:

   ```bash
   echo "alias kubectl='microk8s kubectl'" >> ~/.bashrc
   source ~/.bashrc
   ```

1. Salir de la sesión y volver a entrar.

1. Habilitar los servicios de MicroK8s:

   ```bash
   microk8s enable dns dashboard registry istio
   ```

### 4. Descripción del ambiente de ejecución (en producción) lenguaje de programación, librerias, paquetes, etc, con sus numeros de versiones.

#### Configuración de los nodos Worker

_**Nota:** Se tiene que hacer en los nodos `microk8s-worker-1` y `microk8s-worker-2`._

1. En el nodo `microk8s-master`, obtener el token de unión:

   ```bash
   microk8s add-node
   ```

1. En el nodo `microk8s-worker-n`, unir el nodo al clúster:

   ```bash
   microk8s join <IP_MASTER>:25000/<TOKEN> --worker
   ```

#### Configuración del Master

_**Nota:** Se tiene que hacer en el nodo `microk8s-master`._

Clona el repositorio:

```bash
git clone https://github.com/LI-CCS/st0263-Proyecto-2-Kubernetes.git
```

##### NFS

##### Opción 1: Script de configuración de NFS

1. Ejecutar el script `setup-nfs.sh`:

   ```bash
   cd st0263-Proyecto-2-Kubernetes
   ./scripts/setup-nfs.sh <IP-NFS-SERVER>
   ```

##### Opción 2: Configuración Manual de NFS

1. Habilitar Helm3 y añadir el repositorio de CSI Driver para NFS:

   ```bash
   microk8s enable helm3
   microk8s helm3 repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
   microk8s helm3 repo update
   ```

1. Instalar el driver para NFS:

   ```bash
   microk8s helm3 install csi-driver-nfs csi-driver-nfs/csi-driver-nfs \
    --namespace kube-system \
    --set kubeletDir=/var/snap/microk8s/common/var/lib/kubelet
   ```

1. Crear el StorageClass en un archivo `nfs-csi.yaml`:

   ```yml
   ---
   apiVersion: storage.k8s.io/v1
   kind: StorageClass
   metadata:
   name: nfs-csi
   provisioner: nfs.csi.k8s.io
   parameters:
   server: <NFS_SERVER_IP>
   share: /mnt/wordpress
   reclaimPolicy: Delete
   volumeBindingMode: Immediate
   mountOptions:
     - hard
     - nfsvers=4.1
   ```

1. Aplicar el archivo `nfs-csi.yaml`:

   ```bash
   kubectl apply -f nfs-csi.yaml
   ```

1. Crear el PersistentVolumeClaim en un archivo `nfs-pvc.yaml`:

   ```yml
   ---
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
   name: nfs-pvc
   spec:
   storageClassName: nfs-csi
   accessModes: [ReadWriteOnce]
   resources:
     requests:
       storage: 5Gi
   ```

1. Aplicar el archivo `nfs-pvc.yaml`:

   ```bash
   kubectl apply -f nfs-pvc.yaml
   ```

### 5. Otra información que considere relevante para esta actividad.

## Referencias:

- [Install MicroK8s](https://microk8s.io/#install-microk8s)
- [Create a MicroK8s cluster](https://microk8s.io/docs/clustering)
- [NFS in MicroK8s](https://microk8s.io/docs/how-to-nfs)
