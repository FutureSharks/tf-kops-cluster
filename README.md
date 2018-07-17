# Terraform module for kops

This module allows you to better integrate [kops](https://github.com/kubernetes/kops) Kubernetes clusters into existing AWS/Terraform infrastructure.

It also allows you to create and destroy clusters quickly and easily like other Terraform resources.

Pull requests welcome.

## Example

```hcl
module "cluster1" {
  source                      = "github.com/FutureSharks/tf-kops-cluster/module"
  sg_allow_ssh                = "${aws_security_group.allow_ssh.id}"
  sg_allow_http_s             = "${aws_security_group.allow_http.id}"
  cluster_name                = "cluster1"
  cluster_fqdn                = "cluster1.mydomain.com"
  route53_zone_id             = "${aws_route53_zone.my_zone.id}"
  kops_s3_bucket_arn          = "${aws_s3_bucket.kops.arn}"
  kops_s3_bucket_id           = "${aws_s3_bucket.kops.id}"
  vpc_id                      = "${aws_vpc.main_vpc.id}"
  instance_key_name           = "default-key"
  master_iam_instance_profile = "${aws_iam_instance_profile.kubernetes_masters.id}"
  node_iam_instance_profile   = "${aws_iam_instance_profile.kubernetes_nodes.id}"
  internet_gateway_id         = "${aws_internet_gateway.public.id}"
  public_subnet_cidr_blocks   = [
    "172.20.3.0/24",
    "172.20.4.0/24",
    "172.20.5.0/24"
  ]
}
```

See comments in [module/variables.tf](module/variables.tf) for list of available options.

A full example with VPC resources in [example](example).

## Supported settings

Authentication: RBAC only

Networking: calico or flannel

Kops version: 1.8.1

Supported Kubernetes versions:
  - 1.7.10
  - 1.8.0
  - 1.8.4
  - 1.8.6
  - 1.8.7
  - 1.9.9
