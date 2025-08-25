#!/bin/bash

echo "🧹 Cleaning up all resources..."

# Delete the main application
echo "🗑️  Deleting Python microservice..."
kubectl delete -f deployment.yml --ignore-not-found=true
kubectl delete -f service.yml --ignore-not-found=true
kubectl delete -f mysql-secret.yml --ignore-not-found=true

# Delete monitoring resources
echo "🗑️  Deleting monitoring resources..."
kubectl delete -f simple-prometheus.yml --ignore-not-found=true

# Delete the monitoring namespace
echo "🗑️  Deleting monitoring namespace..."
kubectl delete namespace monitoring --ignore-not-found=true

echo "✅ Cleanup completed!"
