# Introducere în Kubernetes pentru Proiecte SO

> **Ghid Opțional pentru Extensii Kubernetes**  
> **Sisteme de Operare** | ASE București - CSIE

---

## Despre Acest Ghid

Acest document oferă o introducere în Kubernetes pentru studenții care doresc să obțină **bonusul de +10%** prin implementarea unei extensii K8s pentru proiectele MEDIUM.

**Notă:** Kubernetes este **complet opțional**. Proiectele pot obține nota maximă fără această extensie.

---

## Ce Este Kubernetes?

Kubernetes (K8s) este o platformă open-source pentru **orchestrarea containerelor**. Permite:

- **Deployment automat** al aplicațiilor containerizate
- **Scalare automată** bazată pe încărcare
- **Auto-vindecare** - restart automat la eșec
- **Service discovery** și load balancing
- **Rollout/rollback controlat**

### Relevanță pentru SO

Kubernetes demonstrează concepte avansate de SO:
- **Procese și containere** (namespaces, cgroups)
- **Programare** (plasare pod-uri pe noduri)
- **Rețea** (comunicare inter-procese distribuită)
- **Stocare** (volume persistente)

---

## Configurare Mediu Local

### Opțiunea 1: Minikube (Recomandat)

```bash
# Install minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install kubectl /usr/local/bin/kubectl

# Start cluster
minikube start --driver=docker

# Verify
kubectl cluster-info
kubectl get nodes
```

### Opțiunea 2: kind (Kubernetes in Docker)

```bash
# Install kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Create cluster
kind create cluster --name so-project

# Verify
kubectl cluster-info --context kind-so-project
```

---

## Concepte Fundamentale

### Pod

Cea mai mică unitate deployabilă. Conține unul sau mai multe containere.

```yaml
# pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox
    command: ['sh', '-c', 'echo "Hello OS!" && sleep 3600']
```

```bash
# Apply and verify
kubectl apply -f pod.yaml
kubectl get pods
kubectl logs myapp-pod
kubectl exec -it myapp-pod -- sh
```

### Deployment

Gestionează replicile pod-urilor și actualizările.

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          limits:
            memory: "128Mi"
            cpu: "100m"
```

```bash
kubectl apply -f deployment.yaml
kubectl get deployments
kubectl scale deployment myapp-deployment --replicas=5
```

### Service

Expune pod-urile ca serviciu de rețea.

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP  # or NodePort, LoadBalancer
```

### ConfigMap și Secret

Configurație externalizată.

```yaml
# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: myapp-config
data:
  LOG_LEVEL: "INFO"
  MAX_CONNECTIONS: "100"
  config.ini: |
    [server]
    port=8080
    debug=false
```

```yaml
# secret.yaml (values are base64 encoded)
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secrets
type: Opaque
data:
  DB_PASSWORD: cGFzc3dvcmQxMjM=  # echo -n "password123" | base64
```

Utilizare în Pod:

```yaml
spec:
  containers:
  - name: myapp
    env:
    - name: LOG_LEVEL
      valueFrom:
        configMapKeyRef:
          name: myapp-config
          key: LOG_LEVEL
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: myapp-secrets
          key: DB_PASSWORD
    volumeMounts:
    - name: config-volume
      mountPath: /etc/config
  volumes:
  - name: config-volume
    configMap:
      name: myapp-config
```

---

## Exemplu Complet: Deployment Monitor Script

Exemplu al modului în care un proiect SO (M02: Process Monitor) ar arăta cu o extensie Kubernetes.

### Structură Fișiere

```
project/
├── src/
│   └── monitor.sh
├── k8s/
│   ├── namespace.yaml
│   ├── configmap.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── cronjob.yaml
├── Dockerfile
└── Makefile
```

### Dockerfile

```dockerfile
FROM ubuntu:24.04

RUN apt-get update && apt-get install -y \
    procps \
    sysstat \
    && rm -rf /var/lib/apt/lists/*

COPY src/monitor.sh /usr/local/bin/monitor
RUN chmod +x /usr/local/bin/monitor

ENTRYPOINT ["/usr/local/bin/monitor"]
CMD ["--daemon"]
```

### Manifeste Kubernetes

```yaml
# k8s/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: so-monitor
---
# k8s/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: monitor-config
  namespace: so-monitor
data:
  INTERVAL: "30"
  LOG_LEVEL: "INFO"
  ALERT_THRESHOLD_CPU: "80"
  ALERT_THRESHOLD_MEM: "90"
---
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: process-monitor
  namespace: so-monitor
spec:
  replicas: 1
  selector:
    matchLabels:
      app: process-monitor
  template:
    metadata:
      labels:
        app: process-monitor
    spec:
      containers:
      - name: monitor
        image: so-monitor:latest
        imagePullPolicy: Never  # for minikube
        envFrom:
        - configMapRef:
            name: monitor-config
        resources:
          limits:
            memory: "64Mi"
            cpu: "50m"
        volumeMounts:
        - name: proc
          mountPath: /host/proc
          readOnly: true
      volumes:
      - name: proc
        hostPath:
          path: /proc
```

### Makefile pentru K8s

```makefile
.PHONY: k8s-build k8s-deploy k8s-status k8s-logs k8s-clean

IMAGE_NAME := so-monitor
NAMESPACE := so-monitor

# Build Docker image in minikube
k8s-build:
	eval $$(minikube docker-env) && \
	docker build -t $(IMAGE_NAME):latest .

# Deploy to Kubernetes
k8s-deploy: k8s-build
	kubectl apply -f k8s/namespace.yaml
	kubectl apply -f k8s/configmap.yaml
	kubectl apply -f k8s/deployment.yaml

# Check status
k8s-status:
	kubectl get all -n $(NAMESPACE)

# View logs
k8s-logs:
	kubectl logs -f -l app=process-monitor -n $(NAMESPACE)

# Cleanup
k8s-clean:
	kubectl delete namespace $(NAMESPACE) --ignore-not-found
```

---

## Cerințe pentru Bonusul Kubernetes (+10%)

Pentru a primi bonusul, proiectul trebuie să includă:

### Obligatorii

1. **Dockerfile funcțional** care containerizează script-ul Bash
2. **Minimum 3 manifeste Kubernetes:**
   - Deployment sau Pod
   - ConfigMap pentru configurație
   - Service (dacă aplicabil)
3. **Documentație** în `docs/KUBERNETES.md`:
   - Instrucțiuni build imagine
   - Instrucțiuni deployment
   - Comenzi de verificare

### Opționale (puncte adiționale)

- CronJob pentru task-uri periodice
- PersistentVolume pentru stocare
- Horizontal Pod Autoscaler
- Network Policies

### Demonstrație la Prezentare

- Deployment live în minikube
- Vizualizare pod-uri rulând
- Demonstrare scalare (scale up/down)
- Vizualizare log-uri

---

## Comenzi kubectl Utile

```bash
# Cluster information
kubectl cluster-info
kubectl get nodes -o wide

# Pod operations
kubectl get pods -n NAMESPACE
kubectl describe pod POD_NAME -n NAMESPACE
kubectl logs POD_NAME -n NAMESPACE
kubectl exec -it POD_NAME -n NAMESPACE -- bash

# Deployment operations
kubectl apply -f manifest.yaml
kubectl delete -f manifest.yaml
kubectl rollout status deployment/NAME
kubectl rollout undo deployment/NAME

# Debugging
kubectl get events -n NAMESPACE --sort-by='.lastTimestamp'
kubectl top pods -n NAMESPACE  # requires metrics-server

# Port forwarding (local access)
kubectl port-forward svc/SERVICE_NAME 8080:80 -n NAMESPACE
```

---

## Depanare Comună

### Pod în Stare Pending

```bash
kubectl describe pod POD_NAME -n NAMESPACE
# Check Events for reasons (insufficient resources, imagePull fail)
```

### ImagePullBackOff

```bash
# For minikube, use docker-env:
eval $(minikube docker-env)
docker build -t myimage:latest .
# Then in manifest: imagePullPolicy: Never
```

### CrashLoopBackOff

```bash
# Check logs for errors
kubectl logs POD_NAME -n NAMESPACE --previous
```

---

## Resurse Adiționale

- **Kubernetes Documentation:** https://kubernetes.io/docs/home/
- **Minikube Handbook:** https://minikube.sigs.k8s.io/docs/
- **kubectl Cheat Sheet:** https://kubernetes.io/docs/reference/kubectl/cheatsheet/
- **Kubernetes Patterns:** https://k8spatterns.io/

---

*Ghid Kubernetes - Proiecte SO | Ianuarie 2025*
