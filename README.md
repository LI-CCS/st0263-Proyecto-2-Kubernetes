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
- [x] Desplegar una aplicación monolítica (Wordpress) en un clúster de Kubernetes.
- [x] Base de datos.
- [x] Montar un servidor NFS.
- [x] Capa de acceso al clúster con Service, Ingress o similar.
- [x] Nombre de dominio.
- [x] HTTPS.

#### 1.2. Que aspectos NO cumplió o desarrolló de la actividad propuesta por el profesor (requerimientos funcionales y no funcionales)

Todo lo propuesto por el profesor fue cumplido.

### 2. Información general de diseño de alto nivel, arquitectura, patrones, mejores prácticas utilizadas.

#### Arquitectura

Se accede mediante [https://proyecto2.temporaladventures.tech](https://proyecto2.temporaladventures.tech).

<p align="center">
  <img src="https://github.com/LI-CCS/st0263-Proyecto-2-Kubernetes/assets/85181687/26729eeb-10e5-4520-8a10-4bbdfdddb268" alt="Arquitectura">
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

1. Instalar el servidor NFS con el siguiente comando:

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

##### NFS

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

##### MySQL

1. Crear el servicio de MySQL en un archivo `mysql-svc.yaml`:

   ```yml
   ---
   apiVersion: v1
   kind: Service
   metadata:
   name: wordpress-mysql
   labels:
     app: wordpress
   spec:
     ports:
       - port: 3306
     selector:
       app: wordpress
       tier: mysql
     clusterIP: None
   ```

1. Aplicar el archivo `mysql-svc.yaml`:

   ```bash
   kubectl apply -f mysql-svc.yaml
   ```

1. Crear el PV y PVC de MySQL en un archivo `mysql-pv-pvc.yaml`:

   ```yml
   apiVersion: v1
   kind: PersistentVolume
   metadata:
   name: mysql-pv
   labels:
     type: local
   spec:
   storageClassName: manual
   capacity:
     storage: 20Gi
   accessModes:
     - ReadWriteOnce
   hostPath:
     path: "/mnt/mysql"

   ---
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
   name: mysql-pvc
   labels:
     app: wordpress
   spec:
   storageClassName: manual
   accessModes:
     - ReadWriteOnce
   volumeName: mysql-pv
   resources:
     requests:
       storage: 20Gi
   ```

1. Aplicar el archivo `mysql-pv-pvc.yaml`:

   ```bash
   kubectl apply -f mysql-pv-pvc.yaml
   ```

1. Crear el Deployment de MySQL en un archivo `mysql-deployment.yaml`:

   ```yml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
   name: wordpress-mysql
   labels:
      app: wordpress
   spec:
   selector:
      matchLabels:
         app: wordpress
         tier: mysql
   strategy:
      type: Recreate
   template:
      metadata:
         labels:
         app: wordpress
         tier: mysql
      spec:
         containers:
         - image: mysql:8.0
            name: mysql
            env:
               - name: MYSQL_ROOT_PASSWORD
               valueFrom:
                  secretKeyRef:
                     name: mysql-pass
                     key: password
               - name: MYSQL_DATABASE
               value: wordpress
               - name: MYSQL_USER
               value: wordpress
               - name: MYSQL_PASSWORD
               valueFrom:
                  secretKeyRef:
                     name: mysql-pass
                     key: password
            ports:
               - containerPort: 3306
               name: mysql
            volumeMounts:
               - name: mysql-persistent-storage
               mountPath: /var/lib/mysql
         volumes:
         - name: mysql-persistent-storage
            persistentVolumeClaim:
               claimName: mysql-pvc
   ```

1. Aplicar el archivo `mysql-deployment.yaml`:

   ```bash
   kubectl apply -f mysql-deployment.yaml
   ```

##### Wordpress

1. Crear el Servicio de Wordpress en un archivo `wordpress-svc.yaml`:

   ```yml
   ---
   apiVersion: v1
   kind: Service
   metadata:
   name: wordpress
   labels:
      app: wordpress
   spec:
   ports:
      - protocol: TCP
         port: 80
         targetPort: 80
   selector:
      app: wordpress
      tier: frontend
   ```

1. Aplicar el archivo `wordpress-svc.yaml`:

   ```bash
   kubectl apply -f wordpress-svc.yaml
   ```

1. Crear elPVC de Wordpress en un archivo `wordpress-pvc.yaml`:

   ```yml
   apiVersion: v1
   kind: PersistentVolumeClaim
   metadata:
   name: wp-pv-claim
   labels:
     app: wordpress
   spec:
   accessModes:
     - ReadWriteOnce
   resources:
     requests:
       storage: 1Gi
   storageClassName: nfs-csi
   ```

1. Crear el Deployment de Wordpress en un archivo `wordpress-deployment.yaml`:

   ```yml
   apiVersion: apps/v1
   kind: Deployment
   metadata:
   name: wordpress
   labels:
      app: wordpress
   spec:
   replicas: 3
   selector:
      matchLabels:
         app: wordpress
         tier: frontend
   strategy:
      type: Recreate
   template:
      metadata:
         labels:
         app: wordpress
         tier: frontend
      spec:
         containers:
         - image: wordpress
            name: wordpress
            env:
               - name: WORDPRESS_DB_HOST
               value: wordpress-mysql
               - name: WORDPRESS_DB_PASSWORD
               valueFrom:
                  secretKeyRef:
                     name: mysql-pass
                     key: password
               - name: WORDPRESS_DB_USER
               value: wordpress
            ports:
               - containerPort: 80
               name: wordpress
            volumeMounts:
               - name: wordpress-persistent-storage
               mountPath: /var/www/html
         volumes:
         - name: wordpress-persistent-storage
            persistentVolumeClaim:
               claimName: wp-pv-claim
   ```

1. Aplicar el archivo `wordpress-deployment.yaml`:

   ```bash
   kubectl apply -f wordpress-deployment.yaml
   ```

1. Crear el kustomization.yaml:

   ```yml
   secretGenerator:
   - name: mysql-pass
      literals:
         - password=YOUR_PASSWORD
   resources:
   - mysql-deployment.yaml
   - wordpress-deployment.yaml
   ```

1. Aplicar el kustomization.yaml:

   ```bash
   kubectl apply -k .
   ```

##### Ingress

1. Habilitar el Ingress y el Cert-Manager:

   ```bash
   microk8s enable ingress cert-manager
   ```

1. Crear el ClusterIssuer en un archivo `cluster-issuer.yaml`:

   ```yml
   apiVersion: cert-manager.io/v1
   kind: ClusterIssuer
   metadata:
   name: lets-encrypt
   spec:
   acme:
     email: me@email.com
     server: https://acme-v02.api.letsencrypt.org/directory
     privateKeySecretRef:
       name: lets-encrypt-priviate-key
     solvers:
       - http01:
           ingress:
             class: public
   ```

1. Aplicar el archivo `cluster-issuer.yaml`:

   ```bash
   kubectl apply -f cluster-issuer.yaml
   ```

1. Crear el Ingress en un archivo `ingress.yaml`:

   ```yml
   apiVersion: networking.k8s.io/v1
   kind: Ingress
   metadata:
   name: wordpress-ingress
   annotations:
     kubernetes.io/ingress.class: public
     cert-manager.io/cluster-issuer: lets-encrypt
   spec:
   tls:
     - hosts:
         - dominio.com
       secretName: dominio-com-tls
   rules:
     - host: dominio.com
       http:
         paths:
           - path: /
             pathType: Prefix
             backend:
               service:
                 name: wordpress
                 port:
                   number: 80
   ```

#### Pantallazos

<p align="center">
  <img src="https://github.com/LI-CCS/st0263-Proyecto-2-Kubernetes/assets/85181687/6e06ae60-918f-4c18-b176-d2b2a69a7f5b" alt="Pantallazo">
</p>

### 5. Otra información que considere relevante para esta actividad.

## Referencias:

- [Install MicroK8s](https://microk8s.io/#install-microk8s)
- [Create a MicroK8s cluster](https://microk8s.io/docs/clustering)
- [NFS in MicroK8s](https://microk8s.io/docs/how-to-nfs)
- [Deploying WordPress and MySQL with Persistent Volumes](https://kubernetes.io/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/)
- [MicroK8s: Setup Ingress Nginx Controller and Cert Manager on Kubernetes Single Node Cluster](https://8grams.medium.com/microk8s-setup-ingress-nginx-controller-and-cert-manager-on-kubernetes-single-node-cluster-39100b0e86bc)
