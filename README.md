# Terraform module for kops

This module allows you to better integrate kops created Kubernetes clusters into existing AWS/Terraform infrastructure.

One of the main problems with the Terraform output from kops is that it is too simplistic and creates many duplicated resources. This can make integrating the Terraform code into an existing and already complex Terraform code base challenging. Especially when you need multiple clusters.

This module aims to solve this by using a Terraform module and shared resources to reduce duplication. Common resource that already exist in your AWS account can then be used:

  - VPC
  - IAM policies
  - Security Groups
  - kops bucket
  - Instance profiles

Pull requests welcome.

## Example

```hcl
module "cluster1" {
  source                      = "modules/kubernetes_cluster"
  sg_allow_ssh                = "${aws_security_group.allow_ssh.id}"
  sg_allow_http_s             = "${aws_security_group.allow_http.id}"
  cluster_name                = "cluster1"
  cluster_fqdn                = "cluster1.local"
  route53_zone_id             = "${aws_route53_zone.my_zone.id}"
  kops_s3_bucket_arn          = "${aws_s3_bucket.kops.arn}"
  kops_s3_bucket_id           = "${aws_s3_bucket.kops.id}"
  vpc_id                      = "${aws_vpc.my_vpc.id}"
  instance_key_name           = "${aws_key_pair.my_keys.id}"
  vpc_public_subnet_ids       = ["${aws_subnet.public.*.id}"]
  vpc_private_subnet_ids      = ["${aws_subnet.private.*.id}"]
  master_iam_instance_profile = "${aws_iam_instance_profile.kubernetes_masters.id}"
  node_iam_instance_profile   = "${aws_iam_instance_profile.kubernetes_nodes.id}"
}
```

See comments in [modules/kubernetes_cluster/variables.tf](modules/kubernetes_cluster/variables.tf) for list of available options.

Full example with VPC resources in [kubernetes_cluster_example.tf](kubernetes_cluster_example.tf). `terraform apply` can be run from the root of this repo to build example cluster with shared VPC and IAM resources.

## Notes

If the `cluster_fqdn` is not resolvable from where you run `kubectl` then you get an SSL error. The easiest solution is to use a public domain in Route53.

## Versions

Currently kops version 1.6.2 is supported. When a new kops version is available and the user data scripts are changed, a tag will be created with this format: `kops_version`-`module_version`
