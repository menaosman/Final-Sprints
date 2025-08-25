#!/bin/bash

echo "🔍 Troubleshooting Python Microservice Deployment..."

echo ""
echo "📊 Deployment Status:"
kubectl get deployment python-microservice

echo ""
echo "🐳 Pod Status:"
kubectl get pods -l app=python-microservice

echo ""
echo "📋 Pod Details:"
kubectl describe pods -l app=python-microservice

echo ""
echo "📝 Recent Pod Logs:"
POD_NAME=$(kubectl get pods -l app=python-microservice -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ ! -z "$POD_NAME" ]; then
    echo "Logs for pod: $POD_NAME"
    kubectl logs $POD_NAME --tail=50
else
    echo "No pods found"
fi

echo ""
echo "🔌 Service Status:"
kubectl get svc python-microservice-service

echo ""
echo "🗄️  Secret Status:"
kubectl get secret mysql-secret

echo ""
echo "📊 Events:"
kubectl get events --sort-by='.lastTimestamp' | tail -20

echo ""
echo "💡 Common Issues & Solutions:"
echo "1. Image pull errors: Check if Docker image exists and is accessible"
echo "2. Resource constraints: Check if cluster has enough CPU/memory"
echo "3. Database connection: Verify MySQL credentials and connectivity"
echo "4. Health check failures: Check if /healthz endpoint responds correctly"
