# NOMAD Oasis Kubernetes Deployment Guide

This guide provides instructions for deploying NOMAD Oasis on Kubernetes using the Helm chart.

## Quick Start

### Prerequisites

1. Kubernetes cluster (1.23+)
2. Helm 3.x installed
3. kubectl configured to access your cluster
4. Storage provisioner for PersistentVolumes

### Basic Installation

```bash
# Install with default values
helm install nomad-oasis ./helm/nomad-oasis --namespace nomad --create-namespace

# Check deployment status
kubectl get pods -n nomad

# Get the service URL
kubectl get svc -n nomad
```

### Access the Application

If using port-forward for local access:

```bash
kubectl port-forward -n nomad svc/nomad-oasis-app 8000:8000
```

Then visit: http://localhost:8000/nomad-oasis

## Example Deployments

### Development Environment

For local development or testing:

```bash
helm install nomad-dev ./helm/nomad-oasis \
  -f helm/nomad-oasis/examples/dev-values.yaml \
  --namespace nomad-dev \
  --create-namespace
```

This configuration:
- Uses minimal resources
- Disables persistence (uses emptyDir)
- Runs only 1 worker
- No ingress (use port-forward)

### Production Environment

For production deployment:

```bash
# First, create a custom values file
cat > my-production-values.yaml <<EOF
nomad:
  apiHost: "nomad.mycompany.com"
  deployment:
    name: "production"
    url: "https://nomad.mycompany.com/api"
    maintainerEmail: "admin@mycompany.com"

ingress:
  hosts:
    - host: nomad.mycompany.com
      paths:
        - path: /nomad-oasis
          pathType: Prefix
  tls:
    - secretName: nomad-tls
      hosts:
        - nomad.mycompany.com

persistence:
  storageClass: "fast-ssd"
  size: 500Gi

mongodb:
  persistence:
    storageClass: "fast-ssd"
    size: 50Gi

elasticsearch:
  persistence:
    storageClass: "fast-ssd"
    size: 100Gi
EOF

# Install
helm install nomad-prod ./helm/nomad-oasis \
  -f my-production-values.yaml \
  --namespace nomad-prod \
  --create-namespace
```

## Configuration Options

### Custom API Secret

To use a specific API secret instead of auto-generated:

```bash
helm install nomad-oasis ./helm/nomad-oasis \
  --set nomad.apiSecret="your-secret-key-here" \
  --namespace nomad
```

### Scaling Workers

To scale the number of worker pods:

```bash
helm upgrade nomad-oasis ./helm/nomad-oasis \
  --set worker.replicaCount=8 \
  --namespace nomad
```

### Disable NORTH (JupyterHub)

If you don't need JupyterHub functionality:

```bash
helm install nomad-oasis ./helm/nomad-oasis \
  --set north.enabled=false \
  --namespace nomad
```

## Upgrading

To upgrade an existing deployment:

```bash
helm upgrade nomad-oasis ./helm/nomad-oasis --namespace nomad
```

With custom values:

```bash
helm upgrade nomad-oasis ./helm/nomad-oasis \
  -f my-values.yaml \
  --namespace nomad
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -n nomad
kubectl describe pod <pod-name> -n nomad
```

### View Logs

```bash
# App logs
kubectl logs -n nomad -l app.kubernetes.io/component=app --tail=100

# Worker logs
kubectl logs -n nomad -l app.kubernetes.io/component=worker --tail=100

# MongoDB logs
kubectl logs -n nomad -l app.kubernetes.io/component=mongodb --tail=100

# Elasticsearch logs
kubectl logs -n nomad -l app.kubernetes.io/component=elasticsearch --tail=100
```

### Check Services

```bash
kubectl get svc -n nomad
kubectl describe svc nomad-oasis-app -n nomad
```

### Check Storage

```bash
kubectl get pvc -n nomad
kubectl describe pvc nomad-oasis-data -n nomad
```

### Common Issues

#### Pods in Pending State

Usually indicates storage issues:
```bash
kubectl describe pvc -n nomad
```

Make sure your cluster has a default storage class or specify one in values.yaml.

#### Elasticsearch Crashes

Elasticsearch requires `vm.max_map_count` to be set to at least 262144:
```bash
# On each node
sudo sysctl -w vm.max_map_count=262144

# To make it permanent
echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
```

The chart includes an init container to set this, but it requires privileged access.

## Uninstalling

To completely remove the deployment:

```bash
# Uninstall the release
helm uninstall nomad-oasis --namespace nomad

# Delete persistent volumes (if needed)
kubectl delete pvc -n nomad -l app.kubernetes.io/instance=nomad-oasis

# Delete the namespace (if needed)
kubectl delete namespace nomad
```

## Advanced Configuration

### Using External Databases

If you want to use external MongoDB and Elasticsearch:

```yaml
mongodb:
  enabled: false

elasticsearch:
  enabled: false
```

Then configure the connection in the app deployment using environment variables.

### Custom Resource Limits

```yaml
app:
  resources:
    limits:
      cpu: "4"
      memory: 8Gi
    requests:
      cpu: "1"
      memory: 2Gi

worker:
  resources:
    limits:
      cpu: "8"
      memory: 16Gi
    requests:
      cpu: "2"
      memory: 4Gi
```

### Multiple Ingress Hosts

```yaml
ingress:
  hosts:
    - host: nomad.example.com
      paths:
        - path: /nomad-oasis
          pathType: Prefix
    - host: oasis.example.com
      paths:
        - path: /
          pathType: Prefix
```

## Monitoring

### Health Checks

All pods include liveness and readiness probes. Monitor pod health:

```bash
kubectl get pods -n nomad -o wide
```

### Resource Usage

```bash
kubectl top pods -n nomad
kubectl top nodes
```

## Backup and Restore

### Backup MongoDB

```bash
kubectl exec -n nomad <mongo-pod> -- mongodump --out /backup
kubectl cp nomad/<mongo-pod>:/backup ./backup
```

### Backup Files

```bash
# The shared storage is mounted at /app/.volumes in the app pod
kubectl exec -n nomad <app-pod> -- tar czf /tmp/backup.tar.gz /app/.volumes
kubectl cp nomad/<app-pod>:/tmp/backup.tar.gz ./nomad-files-backup.tar.gz
```

## Support

For more information:
- Helm Chart README: `helm/nomad-oasis/README.md`
- NOMAD Documentation: https://nomad-lab.eu/
- GitHub Issues: https://github.com/mecmus/nomad-distro-template/issues
