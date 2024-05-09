# ST0263 Tópicos Especiales en Telemática

- **Estudiante: Miguel Sosa, msosav@eafit.edu.co**
- **Estudiante: Miguel Jaramillo, mjaramil20@eafit.edu.co**
- **Estudiante: Sergio Córdoba, sacordobam@eafit.edu.co**

**Profesor: Edwin Montoya, emontoya@eafit.edu.co**

## Proyecto 2

### 1. Breve descripción de la actividad

#### 1.1. Que aspectos cumplió o desarrolló de la actividad propuesta por el profesor (requerimientos funcionales y no funcionales)

#### 1.2. Que aspectos NO cumplió o desarrolló de la actividad propuesta por el profesor (requerimientos funcionales y no funcionales)

### 2. Información general de diseño de alto nivel, arquitectura, patrones, mejores prácticas utilizadas.

### 3. Descripción del ambiente de desarrollo y técnico: lenguaje de programación, librerias, paquetes, etc, con sus numeros de versiones.

_**Nota:** Para mayor facilidad, se debe clonar el repositorio en cada máquina virtual._

```bash
git clone https://github.com/LI-CCS/st0263-Proyecto-2-Kubernetes.git
```

#### Máquinas virtuales en GCP

Se crearon 4 máquinas virtuales en Google Cloud Platform con las siguientes características:

- **Ubuntu 22.04 LTS x86_64**
- **2 vCPUs**
- **4 GB de memoria**
- **20 GB de disco**

En la sección de **Firewall** se habilitó lo siguiente:

- [x] Tráfico HTTP
- [x] Tráfico HTTPS
- [x] Verificaciones de estado del balanceador de cargas

_**Nota:** Llamamos a las máquinas virtuales `microk8s-master`, `microk8s-worker-1`, `microk8s-worker-1` y `microk8s-nfs`._

#### NFS

##### Opción 1: Script de Instalación de NFS

1. Clonar el repositorio:

   ```bash
   git clone https://github.com/LI-CCS/st0263-Proyecto-2-Kubernetes.git
   ```

2. Ejecutar el script `nfs.sh`:

   ```bash
   cd st0263-Proyecto-2-Kubernetes
   ./nfs.sh
   ```

##### Opción 2: Instalación Manual de NFS

1. Instalar el servidor NFS en la máquina `microk8s-nfs`:

   ```bash
   sudo apt update
   sudo apt install nfs-kernel-server
   ```

2. Crear el directorio que se compartirá:

   ```bash
   sudo mkdir -p /mnt/wordpress
   ```

3. Cambiar el propietario del directorio:

   ```bash
   sudo chown nobody:nogroup /mnt/wordpress
   ```

4. Cambiar los permisos del directorio:

   ```bash
   sudo chmod 777 /mnt/wordpress
   ```

5. Editar el archivo `/etc/exports`:

   ```bash
   sudo nano /etc/exports
   ```

   Añadir la siguiente línea:

   ```bash
   /mnt/wordpress *(rw,sync,no_subtree_check)
   ```

6. Reiniciar el servicio de NFS:

   ```bash
   sudo systemctl restart nfs-kernel-server
   ```

#### Instalación de MicroK8s en Ubuntu 22.04

_**Nota:** Se tiene que hacer por cada nodo._

1. Actualizar el sistema:

   ```bash
   sudo snap install microk8s --classic
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
   ```

1. Reiniciar la terminal o ejecutar el siguiente comando:

   ```bash
    source ~/.bashrc
   ```

1. Habilitar los servicios de MicroK8s:

   ```bash
   microk8s enable dns dashboard registry istio
   ```

### 4. Descripción del ambiente de ejecución (en producción) lenguaje de programación, librerias, paquetes, etc, con sus numeros de versiones.

- IP o nombres de dominio en nube o en la máquina servidor.
- Descripción y como se configura los parámetros del proyecto (ej: ip, puertos, conexión a bases de datos, variables de ambiente, parámetros, etc)
- Como se lanza el servidor.
- Una mini guia de como un usuario utilizaría el software o la aplicación
- Opcional - si quiere mostrar resultados o pantallazos

### 5. Otra información que considere relevante para esta actividad.

## Referencias:

- [Install MicroK8s](https://microk8s.io/#install-microk8s)
- [Create a MicroK8s cluster](https://microk8s.io/docs/clustering)
- [NFS in MicroK8s](https://microk8s.io/docs/how-to-nfs)
