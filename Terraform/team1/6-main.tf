terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket         = "mokhaled-bucket-1286"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock" # Table must exist with partition key LockID (String)
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source = "../infrastructure-modules/vpc"

  environment     = "dev"
  project         = "sprints"
  private_subnets = ["10.0.128.0/20", "10.0.144.0/20"]
  public_subnets  = ["10.0.0.0/20", "10.0.16.0/20"]
  azs             = ["us-east-1a", "us-east-1b"]
}

module "eks" {
  source          = "../infrastructure-modules/eks"

  cluster_name    = "sprints-cluster-0"
  cluster_version = "1.31"  # 1.31 currently supported by EKS
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  node_groups     = var.node_groups

  depends_on      = [module.vpc]
}
