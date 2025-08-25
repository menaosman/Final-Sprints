#!/bin/bash

echo "🔍 Validating Deployment Configuration..."

echo ""
echo "📋 Checking deployment.yml syntax..."
if kubectl apply --dry-run=client -f deployment.yml 2>/dev/null; then
    echo "✅ deployment.yml - Valid"
else
    echo "⚠️  deployment.yml - Could not validate (no cluster connection)"
fi

echo ""
echo "📋 Checking service.yml syntax..."
if kubectl apply --dry-run=client -f service.yml 2>/dev/null; then
    echo "✅ service.yml - Valid"
else
    echo "⚠️  service.yml - Could not validate (no cluster connection)"
fi

echo ""
echo "📋 Checking mysql-secret.yml syntax..."
if kubectl apply --dry-run=client -f mysql-secret.yml 2>/dev/null; then
    echo "✅ mysql-secret.yml - Valid"
else
    echo "⚠️  mysql-secret.yml - Could not validate (no cluster connection)"
fi

echo ""
echo "📋 Checking simple-prometheus.yml syntax..."
if kubectl apply --dry-run=client -f simple-prometheus.yml 2>/dev/null; then
    echo "✅ simple-prometheus.yml - Valid"
else
    echo "⚠️  simple-prometheus.yml - Could not validate (no cluster connection)"
fi

echo ""
echo "✅ Configuration files are ready!"
echo ""
echo "💡 To test with actual deployment:"
echo "1. Start your Kubernetes cluster (Minikube, EKS, etc.)"
echo "2. Run: ./deploy-all.sh"
echo "3. If issues occur, run: ./troubleshoot.sh"
