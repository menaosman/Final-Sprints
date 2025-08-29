name: Create S3

on:
  workflow_dispatch:

jobs:
  setup-terraform-backend:
    runs-on: ubuntu-latest
    env:
      AWS_REGION: us-east-1
      TF_STATE_BUCKET: mokhaled-bucket-1286
      TF_LOCK_TABLE: terraform-lock
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id:     ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region:            ${{ env.AWS_REGION }}

      - name: Create S3 bucket (if not exists)
        run: |
          if ! aws s3api head-bucket --bucket "$TF_STATE_BUCKET" 2>/dev/null; then
            if [ "$AWS_REGION" = "us-east-1" ]; then
              aws s3api create-bucket --bucket "$TF_STATE_BUCKET"
            else
              aws s3api create-bucket \
                --bucket "$TF_STATE_BUCKET" \
                --create-bucket-configuration LocationConstraint="$AWS_REGION"
            fi
            echo "Created S3 bucket: $TF_STATE_BUCKET"
          else
            echo "Bucket exists: $TF_STATE_BUCKET"
          fi

          aws s3api put-public-access-block --bucket "$TF_STATE_BUCKET" --public-access-block-configuration '{
            "BlockPublicAcls": true, "IgnorePublicAcls": true, "BlockPublicPolicy": true, "RestrictPublicBuckets": true
          }'
          aws s3api put-bucket-versioning --bucket "$TF_STATE_BUCKET" --versioning-configuration Status=Enabled
          aws s3api put-bucket-encryption --bucket "$TF_STATE_BUCKET" --server-side-encryption-configuration '{
            "Rules": [{"ApplyServerSideEncryptionByDefault": {"SSEAlgorithm": "AES256"}}]
          }'

      - name: Create DynamoDB table (if not exists)
        run: |
          if ! aws dynamodb describe-table --table-name "$TF_LOCK_TABLE" >/dev/null 2>&1; then
            aws dynamodb create-table \
              --table-name "$TF_LOCK_TABLE" \
              --attribute-definitions AttributeName=LockID,AttributeType=S \
              --key-schema AttributeName=LockID,KeyType=HASH \
              --billing-mode PAY_PER_REQUEST
            echo "Created DynamoDB table: $TF_LOCK_TABLE"
          else
            echo "DynamoDB table exists: $TF_LOCK_TABLE"
          fi
