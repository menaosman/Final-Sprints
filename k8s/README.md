# Kubernetes Deployment with Monitoring

This directory contains the Kubernetes manifests for deploying the Python microservice with basic monitoring.

## 🚀 Quick Start

### Deploy Everything
```bash
./deploy-all.sh
```

### Clean Up
```bash
./cleanup.sh
```

### Troubleshoot Issues
```bash
./troubleshoot.sh
```

### Validate Configuration
```bash
./validate-deployment.sh
```

## 📁 Files

- `deployment.yml` - Main application deployment (improved with better probes and resources)
- `service.yml` - Service for the application
- `mysql-secret.yml` - MySQL connection secrets
- `simple-prometheus.yml` - Basic Prometheus monitoring setup
- `deploy-all.sh` - Deployment script with improved timeout handling
- `cleanup.sh` - Cleanup script
- `troubleshoot.sh` - Troubleshooting and diagnostic script
- `validate-deployment.sh` - Configuration validation script

## 🔧 Recent Improvements

### Fixed Deployment Timeout Issues:
- ✅ **Increased timeouts**: Liveness probe (60s), Readiness probe (30s), Startup probe (30s)
- ✅ **Better resource allocation**: Increased CPU/memory limits and requests
- ✅ **Improved rolling update strategy**: MaxSurge=1, MaxUnavailable=0
- ✅ **Enhanced health checks**: Added startup probe with 30 failure threshold
- ✅ **Better error handling**: Added diagnostic information in CI/CD pipeline

### Health Check Configuration:
- **Startup Probe**: 30s initial delay, 30 failure threshold
- **Readiness Probe**: 30s initial delay, 5 failure threshold  
- **Liveness Probe**: 60s initial delay, 5 failure threshold

## 🚨 Common Issues & Solutions

### 1. Deployment Timeout
**Symptoms**: `error: timed out waiting for the condition`
**Solutions**:
- Check pod status: `kubectl get pods -l app=python-microservice`
- View pod logs: `kubectl logs <pod-name>`
- Run troubleshooting: `./troubleshoot.sh`

### 2. Image Pull Errors
**Symptoms**: `ErrImagePull` or `ImagePullBackOff`
**Solutions**:
- Verify Docker image exists and is accessible
- Check image pull policy in deployment.yml
- Ensure proper registry credentials

### 3. Resource Constraints
**Symptoms**: `Pending` status or `FailedScheduling`
**Solutions**:
- Check cluster resources: `kubectl describe nodes`
- Adjust resource requests/limits in deployment.yml
- Scale cluster if needed

### 4. Health Check Failures
**Symptoms**: Pods not becoming ready
**Solutions**:
- Verify `/healthz` endpoint responds correctly
- Check application startup logs
- Adjust probe timing if needed

## 📊 Monitoring

- **Application Metrics**: Available at `/metrics` endpoint
- **Prometheus**: Scrapes metrics every 15 seconds
- **Health Checks**: `/healthz` endpoint for Kubernetes probes

## 🔍 Troubleshooting Commands

```bash
# Check deployment status
kubectl get deployment python-microservice

# View pod details
kubectl describe pods -l app=python-microservice

# Check pod logs
kubectl logs <pod-name>

# View events
kubectl get events --sort-by='.lastTimestamp'

# Check service status
kubectl get svc python-microservice-service
```

## 📈 Performance Tuning

The deployment now includes:
- **Startup Probe**: Gives app time to initialize (up to 5 minutes)
- **Resource Optimization**: Better CPU/memory allocation
- **Rolling Updates**: Zero-downtime deployments
- **Health Check Tuning**: Appropriate timeouts for different probe types

## 🚀 Next Steps

1. **Test locally**: Run `./validate-deployment.sh`
2. **Deploy**: Use `./deploy-all.sh` when cluster is ready
3. **Monitor**: Check deployment status and pod health
4. **Troubleshoot**: Use `./troubleshoot.sh` if issues occur

## 📝 Notes

- All timeouts have been increased to handle slower startup scenarios
- Health checks are more lenient during initial startup
- Resource allocation is optimized for better performance
- CI/CD pipeline includes better error handling and diagnostics
