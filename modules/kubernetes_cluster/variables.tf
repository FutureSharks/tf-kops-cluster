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
# IAM instance profile to use for the master
variable "master_iam_instance_profile" {}
# IAM instance profile to use for the nodes
variable "node_iam_instance_profile" {}
# Private route table ID
variable "route_table_private_id" {}
# Public route table ID
variable "route_table_public_id" {}
# A list of CIDR networks to use for public subnets. Should be 1 per AZ.
variable "subnet_cidr_blocks_public" {
  type = "list"
}
# A list of CIDR networks to use for private subnets. Should be 1 per AZ.
variable "subnet_cidr_blocks_private" {
  type = "list"
}
# Instance type for the master
variable "master_instance_type" {
  default = "t2.small"
}
# Instance type for nodes
variable "node_instance_type" {
  default = "t2.medium"
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
# Kubernetes version tag to use
variable "kubernetes_version" {
  default = "1.7.0"
}
# Cloudwatch log group log retention in days
variable "cloudwatch_log_group_retention" {
  default = 30
}
# kops DNS setting
variable "dns" {
  default = "public"
}
# Force single master. Can be used when a master per AZ is not required or if running in a region with only 2 AZs.
variable "force_single_master" {
  default = false
}
