name: destroy-infra

on:
  workflow_dispatch:
  push:
    branches:
      - main
    inputs:
      confirm:
        description: "Type EXACTLY: destroy my stack"
        required: true
        default: "no"

env:
  AWS_REGION: us-east-1
  EKS_CLUSTER_NAME: sprints-cluster-0
  TERRAFORM_DIR: ./Terraform/team1
  K8S_DIR: ./k8s

jobs:
  guardrail:
    runs-on: ubuntu-latest
    steps:
      - name: Check confirmation
        run: |
          if [ "${{ github.event.inputs.confirm }}" != "destroy my stack" ]; then
            echo "Confirmation mismatch. Aborting."
            exit 1
          fi

  destroy:
    needs: guardrail
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id:     ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region:            ${{ env.AWS_REGION }}

      - name: Install Helm (for cleanup)
        run: |
          sudo apt-get update -y
          sudo apt-get install -y helm

      - name: Delete K8s & Helm (idempotent)
        env:
          AWS_REGION: ${{ env.AWS_REGION }}
          EKS_CLUSTER_NAME: ${{ env.EKS_CLUSTER_NAME }}
          K8S_DIR: ${{ env.K8S_DIR }}
        run: |
          aws eks update-kubeconfig --name "$EKS_CLUSTER_NAME" --region "$AWS_REGION"
          # Uninstall monitoring chart if present
          if kubectl get ns monitoring >/dev/null 2>&1; then
            helm uninstall kube-prometheus-stack -n monitoring || true
          fi
          # Delete app manifests
          if [ -d "$K8S_DIR" ]; then
            kubectl delete -f "$K8S_DIR/servicemonitor.yml" --ignore-not-found
            kubectl delete -f "$K8S_DIR/service.yml"        --ignore-not-found
            kubectl delete -f "$K8S_DIR/deployment.yml"     --ignore-not-found
            kubectl delete -f "$K8S_DIR/mongodb.yml"        --ignore-not-found
          fi
          echo "Waiting 60s for load balancers to release..."
          sleep 60

      - uses: hashicorp/setup-terraform@v3
        with: { terraform_version: 1.6.6 }

      - name: Terraform Destroy
        working-directory: ${{ env.TERRAFORM_DIR }}
        run: |
          terraform init -input=false -reconfigure
          terraform destroy -auto-approve -input=false
