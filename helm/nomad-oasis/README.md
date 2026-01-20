# NOMAD Oasis Helm Chart

A Helm chart for deploying NOMAD Oasis distribution on Kubernetes.

## Description

This Helm chart deploys a complete NOMAD Oasis instance on a Kubernetes cluster. NOMAD is an open-source data management platform for materials science, enabling FAIR (Findable, Accessible, Interoperable, Reusable) data management and sharing.

**Important**: This Helm chart uses pre-built Docker images from GitHub Container Registry. You do **not** need to build images yourself - they are available at:
- Main app/worker: `ghcr.io/mecmus/nomad-distro-template:main`
- JupyterHub: `ghcr.io/mecmus/nomad-distro-template/jupyter:main`

The Dockerfile in this repository is only needed if you want to create custom builds.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.x
- PV provisioner support in the underlying infrastructure (for persistent storage)
- Ingress controller (nginx recommended) if ingress is enabled

## Installation

### Quick Start

To install the chart with the release name `my-nomad`:

```bash
helm install my-nomad ./helm/nomad-oasis
```

### Custom Installation

Create a custom `values.yaml` file and install:

```bash
helm install my-nomad ./helm/nomad-oasis -f my-values.yaml
```

### With Custom Namespace

```bash
kubectl create namespace nomad
helm install my-nomad ./helm/nomad-oasis --namespace nomad
```

## Configuration

The following table lists the main configurable parameters of the NOMAD Oasis chart and their default values.

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `global.imageRegistry` | Global Docker image registry | `ghcr.io` |
| `global.imagePullSecrets` | Global Docker registry secret names as an array | `[]` |

### Image Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.repository` | NOMAD image repository | `mecmus/nomad-distro-template` |
| `image.tag` | NOMAD image tag | `main` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |

### NOMAD Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `nomad.apiBasePath` | API base path | `/nomad-oasis` |
| `nomad.apiHost` | API host | `localhost` |
| `nomad.apiSecret` | API secret (auto-generated if empty) | `""` |
| `nomad.deployment.name` | Deployment name | `oasis` |
| `nomad.deployment.url` | Deployment URL | `https://my-oasis.org/api` |
| `nomad.deployment.maintainerEmail` | Maintainer email | `admin@my-oasis.org` |

### Application Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `app.replicaCount` | Number of app replicas | `1` |
| `app.resources.limits.cpu` | CPU limit | `2` |
| `app.resources.limits.memory` | Memory limit | `4Gi` |
| `app.resources.requests.cpu` | CPU request | `500m` |
| `app.resources.requests.memory` | Memory request | `1Gi` |

### Worker Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `worker.replicaCount` | Number of worker replicas | `4` |
| `worker.resources.limits.cpu` | CPU limit | `4` |
| `worker.resources.limits.memory` | Memory limit | `8Gi` |
| `worker.resources.requests.cpu` | CPU request | `1` |
| `worker.resources.requests.memory` | Memory request | `2Gi` |

### NORTH (JupyterHub) Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `north.enabled` | Enable JupyterHub | `true` |
| `north.jupyterhubCryptKey` | JupyterHub crypt key (auto-generated if empty) | `""` |
| `north.image.repository` | JupyterHub image repository | `mecmus/nomad-distro-template/jupyter` |
| `north.image.tag` | JupyterHub image tag | `main` |

### MongoDB Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `mongodb.enabled` | Enable MongoDB | `true` |
| `mongodb.persistence.enabled` | Enable persistence | `true` |
| `mongodb.persistence.size` | Persistent volume size | `10Gi` |
| `mongodb.persistence.storageClass` | Storage class | `""` |

### Elasticsearch Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `elasticsearch.enabled` | Enable Elasticsearch | `true` |
| `elasticsearch.persistence.enabled` | Enable persistence | `true` |
| `elasticsearch.persistence.size` | Persistent volume size | `30Gi` |
| `elasticsearch.persistence.storageClass` | Storage class | `""` |
| `elasticsearch.resources.limits.cpu` | CPU limit | `2` |
| `elasticsearch.resources.limits.memory` | Memory limit | `4Gi` |

### RabbitMQ Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `rabbitmq.enabled` | Enable RabbitMQ (message broker for workers) | `true` |
| `rabbitmq.auth.username` | RabbitMQ username | `rabbitmq` |
| `rabbitmq.auth.password` | RabbitMQ password (auto-generated if empty) | `""` |
| `rabbitmq.erlangCookie` | Erlang cookie for clustering | `SWQOKODSQALRPCLNMEQG` |
| `rabbitmq.persistence.enabled` | Enable persistence | `true` |
| `rabbitmq.persistence.size` | Persistent volume size | `5Gi` |
| `rabbitmq.persistence.storageClass` | Storage class | `""` |

### Temporal Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `temporal.enabled` | Enable Temporal workflow engine | `true` |
| `temporal.postgresql.enabled` | Enable PostgreSQL for Temporal | `true` |
| `temporal.postgresql.persistence.enabled` | Enable persistence | `true` |
| `temporal.postgresql.persistence.size` | Persistent volume size | `5Gi` |
| `temporal.postgresql.persistence.storageClass` | Storage class | `""` |

### Ingress Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `nginx` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | Ingress TLS configuration | `[]` |

### Persistence Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `persistence.enabled` | Enable shared storage | `true` |
| `persistence.storageClass` | Storage class | `""` |
| `persistence.accessModes` | Access modes | `[ReadWriteMany]` |
| `persistence.size` | Persistent volume size | `100Gi` |

### Service Account Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceAccount.create` | Create service account | `true` |
| `serviceAccount.name` | Service account name | `""` |
| `serviceAccount.annotations` | Service account annotations | `{}` |

## Examples

### Basic Installation with Custom Domain

```yaml
# custom-values.yaml
nomad:
  apiHost: "nomad.example.com"
  deployment:
    url: "https://nomad.example.com/api"
    maintainerEmail: "admin@example.com"

ingress:
  hosts:
    - host: nomad.example.com
      paths:
        - path: /nomad-oasis
          pathType: Prefix
  tls:
    - secretName: nomad-tls
      hosts:
        - nomad.example.com
```

Install:
```bash
helm install nomad ./helm/nomad-oasis -f custom-values.yaml
```

### Production Installation with Custom Resources

```yaml
# production-values.yaml
app:
  replicaCount: 2
  resources:
    limits:
      cpu: "4"
      memory: 8Gi
    requests:
      cpu: "1"
      memory: 2Gi

worker:
  replicaCount: 8
  resources:
    limits:
      cpu: "8"
      memory: 16Gi
    requests:
      cpu: "2"
      memory: 4Gi

mongodb:
  persistence:
    size: 50Gi
    storageClass: "fast-ssd"

elasticsearch:
  persistence:
    size: 100Gi
    storageClass: "fast-ssd"

persistence:
  size: 500Gi
  storageClass: "fast-ssd"
```

Install:
```bash
helm install nomad ./helm/nomad-oasis -f production-values.yaml --namespace nomad-prod
```

### Minimal Installation (Development)

```yaml
# dev-values.yaml
worker:
  replicaCount: 1

mongodb:
  persistence:
    enabled: false

elasticsearch:
  persistence:
    enabled: false

persistence:
  enabled: false

ingress:
  enabled: false
```

Install:
```bash
helm install nomad ./helm/nomad-oasis -f dev-values.yaml
```

## Upgrading

To upgrade an existing installation:

```bash
helm upgrade my-nomad ./helm/nomad-oasis
```

With custom values:
```bash
helm upgrade my-nomad ./helm/nomad-oasis -f my-values.yaml
```

## Uninstalling

To uninstall/delete the deployment:

```bash
helm uninstall my-nomad
```

**Note:** This will not delete the PersistentVolumeClaims. To delete them:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=my-nomad
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/instance=my-nomad
```

### View Application Logs

```bash
kubectl logs -l app.kubernetes.io/component=app --tail=100
```

### View Worker Logs

```bash
kubectl logs -l app.kubernetes.io/component=worker --tail=100
```

### Check Elasticsearch Status

```bash
kubectl exec -it <elasticsearch-pod> -- curl http://localhost:9200/_cluster/health
```

### Check MongoDB Status

```bash
kubectl exec -it <mongodb-pod> -- mongosh --eval "db.adminCommand('ping')"
```

### Common Issues

#### Pods stuck in Pending state

This usually indicates storage provisioning issues. Check:
```bash
kubectl get pvc
kubectl describe pvc <pvc-name>
```

#### Elasticsearch fails to start

Elasticsearch requires `vm.max_map_count` to be set. The chart includes an init container to set this, but it requires privileged access. Ensure your cluster allows privileged containers or set this at the node level:
```bash
sysctl -w vm.max_map_count=262144
```

#### Application fails to connect to services

Check that all services are running:
```bash
kubectl get svc -l app.kubernetes.io/instance=my-nomad
```

Verify connectivity from app pod:
```bash
kubectl exec -it <app-pod> -- curl http://<service-name>:9200
```

## Support

For issues and questions:
- GitHub Issues: https://github.com/mecmus/nomad-distro-template/issues
- NOMAD Documentation: https://nomad-lab.eu/
- NOMAD Forum: https://matsci.org/c/nomad

## License

This Helm chart is licensed under the same license as the NOMAD Oasis distribution.
