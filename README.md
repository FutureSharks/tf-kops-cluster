# Terraform module for kops

This module allows you to better integrate [kops](https://github.com/kubernetes/kops) Kubernetes clusters into existing AWS/Terraform infrastructure.

One of the main problems with the Terraform output from kops is that it is too simplistic and creates many duplicated resources. This can make integrating the Terraform code into an existing and already complex Terraform code base challenging. Especially when you need multiple clusters.

This module aims to solve this by using a Terraform module and shared resources to reduce duplication. Common resource that already exist in your AWS account can then be used:

  - VPC
  - IAM policies
  - Security Groups
  - kops bucket
  - Instance profiles
  - NAT gateway resources

The module will create these resources per cluster:

  - Autoscaling groups and launch configuration for nodes
  - Autoscaling groups and launch configuration for masters (per AZ)
  - Master ELB
  - Public subnets (per AZ) for ELBs
  - Security groups
  - Etcd volumes used by masters (per AZ)

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
  route_table_ids             = ["${aws_route_table.public.id}"]
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

A full example with VPC resources in [example](example). `terraform apply` can be run from this directory to build 2 example clusters with shared VPC and IAM resources. `cluster1` uses public subnets and `cluster2` uses subnets with NAT gateways.

Not that if you don't replace the variable `domain_name` with a public Route 53 zone then you will need to edit your local `~/.kube/config` file:

```shell
MASTER_ELB=$(terraform state show module.cluster1.aws_elb.master | grep dns_name | cut -f2 -d= | xargs)
sed -i "s/api.cluster1.local.vpc/$MASTER_ELB/g" ~/.kube/config
```

And then use run `kubectl` with the `--insecure-skip-tls-verify` option:

```shell
kubectl --insecure-skip-tls-verify cluster-info
Kubernetes master is running at https://cluster1-master-999999999.eu-west-1.elb.amazonaws.com
KubeDNS is running at https://cluster1-master-999999999.eu-west-1.elb.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns/proxy
```

## Versions

Currently kops version 1.7.1 is supported.
