variable "project" {
  description = "The name of the project"
  type        = string
}

variable "environment" {
  description = "The environment"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnets" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}

variable "azs" {
  description = "The availability zones"
  type        = list(string)
}

# Add cluster name variable for dynamic tagging
variable "cluster_name" {
  description = "EKS cluster name for subnet tagging"
  type        = string
}