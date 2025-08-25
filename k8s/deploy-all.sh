#!/bin/bash

echo "🚀 Deploying Python Microservice with Monitoring..."

# Create namespace first
echo "📦 Creating monitoring namespace..."
kubectl apply -f simple-prometheus.yml

# Wait for namespace to be ready
kubectl wait --for=condition=Active namespace/monitoring --timeout=30s

# Deploy the main application
echo "🐍 Deploying Python microservice..."
kubectl apply -f deployment.yml
kubectl apply -f service.yml
kubectl apply -f mysql-secret.yml

# Wait for the application to be ready
echo "⏳ Waiting for application to be ready..."
kubectl wait --for=condition=available --timeout=600s deployment/python-microservice

# Check pod status if there are issues
echo "🔍 Checking pod status..."
kubectl get pods -l app=python-microservice
kubectl describe deployment python-microservice

# Deploy Prometheus (simple version without CRDs)
echo "📊 Deploying Prometheus..."
kubectl apply -f simple-prometheus.yml

# Wait for Prometheus to be ready
echo "⏳ Waiting for Prometheus to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring

echo "✅ Deployment completed successfully!"
echo ""
echo "🌐 Access your application:"
echo "   kubectl port-forward service/python-microservice-service 8080:5000"
echo "   Then visit: http://localhost:8080"
echo ""
echo "📊 Access Prometheus:"
echo "   kubectl port-forward service/prometheus 9090:9090 -n monitoring"
echo "   Then visit: http://localhost:9090"
echo ""
echo "📈 Your app now has metrics at: http://localhost:8080/metrics"
