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
# A list of public subnet IDs
variable "vpc_public_subnet_ids" {
  type = "list"
}
# A list of private subnet IDs
variable "vpc_private_subnet_ids" {
  type = "list"
}
# IAM instance profile to use for the master
variable "master_iam_instance_profile" {}
# Instance type for the master
variable "master_instance_type" {
  default = "m3.medium"
}
# IAM instance profile to use for the nodes
variable "node_iam_instance_profile" {}
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
  default = "1.6.2"
}
# Cloudwatch log group log retention in days
variable "cloudwatch_log_group_retention" {
  default = 30
}
# kops DNS setting
variable "dns" {
  default = "public"
}
