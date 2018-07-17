# Name for the cluster
variable "cluster_name" {}

# Fully qualified DNS name of cluster
variable "cluster_fqdn" {}

# ID of the VPC
variable "vpc_id" {}

# Route53 zone ID
variable "route53_zone_id" {}

# ARN of the kops bucket
variable "kops_s3_bucket_arn" {}

# ID of the kops bucket
variable "kops_s3_bucket_id" {}

# Name of the SSH key to use for cluster nodes and master
variable "instance_key_name" {}

# Security group ID to allow SSH from. Nodes and masters are added to this security group
variable "sg_allow_ssh" {}

# Security group ID to allow HTTP/S from. Master ELB is added to this security group
variable "sg_allow_http_s" {}

# ID of internet gateway for the VPC
variable "internet_gateway_id" {}

# A list of CIDR subnet blocks to use for Kubernetes public subnets. Should be 1 per AZ.
variable "public_subnet_cidr_blocks" {
  type = "list"
}

# Set the desired amount of master nodes. NB! It should be odd for a quorum : 1, 3, 5, etc.
variable "master_count" {
  default = 3
}

# Instance type for the master
variable "master_instance_type" {
  default = "m4.medium"
}

# Instance type for nodes
variable "node_instance_type" {
  default = "c4.xlarge"
}

# Spot node instance type
variable "spot_node_instance_type" {
  default = "c4.large"
}

# Node autoscaling group min
variable "node_asg_min" {
  default = 3
}

# Node autoscaling group desired
variable "node_asg_desired" {
  default = 3
}

# Node autoscaling group max
variable "node_asg_max" {
  default = 3
}

# Spot instance price, default is null
variable "max_price_spot" {
  default = ""
}

# Kubernetes version tag to use
variable "kubernetes_version" {
  default = "1.8.4"
}

# List of private subnet IDs. Pass 1 per AZ or if left blank then public subnets will be used
variable "private_subnet_ids" {
  type    = "list"
  default = []
}

# kops DNS mode
variable "kops_dns_mode" {
  default = "public"
}

# kops networking mode to use. Values other than flannel and calico are untested
variable "kubernetes_networking" {
  default = "calico"
}

# Cloudwatch alarm CPU
variable "master_k8s_cpu_threshold" {
  default = 80
}

# Local path to the SSH public key. It's not used effectively, but kops requires it
variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
  type = "string"
}
