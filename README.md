# Kubernetes Deployment with Monitoring

This directory contains the Kubernetes manifests for deploying the Python microservice with basic monitoring.

## Files

- `deployment.yml` - Main application deployment
- `service.yml` - Service for the application
- `mysql-secret.yml` - MySQL connection secrets
- `simple-prometheus.yml` - Basic Prometheus monitoring setup
- `deploy-all.sh` - Deployment script
- `cleanup.sh` - Cleanup script

## Quick Start

### Deploy Everything
```bash
./deploy-all.sh
```

### Clean Up
```bash
./cleanup.sh
```

## Manual Deployment

If you prefer to deploy manually:

1. **Deploy the application:**
   ```bash
   kubectl apply -f deployment.yml
   kubectl apply -f service.yml
   kubectl apply -f mysql-secret.yml
   ```

2. **Deploy monitoring:**
   ```bash
   kubectl apply -f simple-prometheus.yml
   ```

## Access Points

- **Application:** `http://localhost:8080` (after port-forward)
- **Prometheus:** `http://localhost:9090` (after port-forward)
- **Metrics:** `http://localhost:8080/metrics`

## Port Forwarding

```bash
# Application
kubectl port-forward service/python-microservice-service 8080:5000

# Prometheus (in another terminal)
kubectl port-forward service/prometheus 9090:9090 -n monitoring
```

## What's Included

- ✅ Python Flask microservice with MySQL
- ✅ Prometheus metrics collection
- ✅ Basic monitoring setup
- ✅ No complex CRDs required
- ✅ Simple deployment scripts

## Notes

- The Flask app now includes Prometheus metrics at `/metrics`
- Prometheus will automatically scrape metrics every 15 seconds
- All resources are deployed in the `default` namespace except monitoring (which uses `monitoring` namespace)
