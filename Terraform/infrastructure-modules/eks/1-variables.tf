variable "cluster_name" {
  description   = "Name of the EKS cluster"
  type          = string
}

variable "cluster_version" {
  description   = "Kubernetes version"
  type          = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description   = "Subnets IDS"
  type          = list(string)
}

variable "node_groups" {
  description   = "EKS node groups configuration"
  type          = map(object({
    instance_types = list(string)
    capacity_type  = string
    disk_size      = optional(number, 20)
    ami_type       = optional(string, "AL2_x86_64")
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number 
    })
  }))
}