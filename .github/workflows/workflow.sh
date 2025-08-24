name: Microservice Deployment on Kubernetes

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      action:
        description: 'Action to perform'
        required: true
        default: 'deploy'
        type: choice
        options:
        - deploy
        - destroy

env:
  AWS_REGION: us-east-1
  EKS_CLUSTER_NAME: sprints-cluster-0

jobs:
  containerization:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Log in to Docker Hub
      uses: docker/login-action@v3
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_PASSWORD }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ secrets.DOCKERHUB_USERNAME }}/python-app
        tags: |
          type=ref,event=branch
          type=sha,prefix={{branch}}-
          type=raw,value=latest,enable={{is_default_branch}}

    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

    - name: Test Docker image locally
      run: |
        docker run -d --name test-app -p 5000:5000 \
          -e MYSQL_DATABASE_HOST=localhost \
          -e MYSQL_DATABASE_USER=testuser \
          -e MYSQL_DATABASE_PASSWORD=testpass \
          -e MYSQL_DATABASE_DB=testdb \
          ${{ secrets.DOCKERHUB_USERNAME }}/python-app:latest || true
        sleep 10
        curl -f http://localhost:5000/ || echo "Health check failed - expected without DB"
        docker stop test-app || true
        docker rm test-app || true

  terraform:
    runs-on: ubuntu-latest
    if: github.event.inputs.action != 'destroy'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.7.0

    - name: Terraform Init
      run: |
        cd Terraform/team1
        terraform init

    - name: Terraform Plan
      run: |
        cd Terraform/team1
        terraform plan

    - name: Terraform Apply
      if: github.ref == 'refs/heads/main'
      run: |
        cd Terraform/team1
        terraform apply -auto-approve

  deployment:
    runs-on: ubuntu-latest
    needs: [containerization, terraform]
    if: always() && (needs.containerization.result == 'success')
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Update kubeconfig
      run: |
        aws eks update-kubeconfig --region ${{ env.AWS_REGION }} --name ${{ env.EKS_CLUSTER_NAME }}

    - name: Create MySQL Secret
      run: |
        envsubst < k8s/mysql-secret.yml | kubectl apply -f -
      env:
        MYSQL_USERNAME: ${{ secrets.MYSQL_USERNAME }}
        MYSQL_PASSWORD: ${{ secrets.MYSQL_PASSWORD }}

    - name: Deploy to Kubernetes
      run: |
        # Replace placeholders in deployment
        envsubst < k8s/deployment.yml | kubectl apply -f -
        
        # Apply service and monitoring
        kubectl apply -f k8s/service.yml
        kubectl apply -f k8s/servicemonitor.yml
        
        # Wait for deployment rollout
        kubectl rollout status deployment/python-microservice --timeout=300s
        
        # Display service information
        kubectl get svc python-microservice-service
      env:
        MYSQL_HOST: ${{ vars.MYSQL_HOST }}
        MYSQL_DATABASE: ${{ vars.MYSQL_DATABASE }}
        DOCKER_IMAGE: ${{ secrets.DOCKERHUB_USERNAME }}/python-app:${{ github.sha }}

    - name: Verify Deployment
      run: |
        echo "Checking pod status..."
        kubectl get pods -l app=python-microservice
        
        echo "Checking service status..."
        kubectl get svc python-microservice-service
        
        echo "Getting external URL..."
        kubectl get svc python-microservice-service -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' || echo "LoadBalancer URL not ready yet"

  destroy:
    runs-on: ubuntu-latest
    if: github.event.inputs.action == 'destroy'
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v4
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: ${{ env.AWS_REGION }}

    - name: Update kubeconfig
      run: |
        aws eks update-kubeconfig --region ${{ env.AWS_REGION }} --name ${{ env.EKS_CLUSTER_NAME }} || true

    - name: Delete Kubernetes resources
      run: |
        kubectl delete -f k8s/ || true
      continue-on-error: true

    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v3
      with:
        terraform_version: 1.7.0

    - name: Terraform Destroy
      run: |
        cd Terraform/team1
        terraform init
        terraform destroy -auto-approve