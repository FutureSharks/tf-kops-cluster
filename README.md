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

A full example with VPC resources in [example](example). `terraform apply` can be run from this directory to build 2 example clusters with shared VPC and IAM resources. `cluster1` uses public subnets and `cluster2` uses private subnets with NAT gateways.

Note that this example is using non-existent domain and private DNS mode so a configuration change is required to make it work:

```shell
MASTER_ELB_CLUSTER1=$(terraform state show module.cluster1.aws_elb.master | grep dns_name | cut -f2 -d= | xargs)
MASTER_ELB_CLUSTER2=$(terraform state show module.cluster2.aws_elb.master | grep dns_name | cut -f2 -d= | xargs)
kubectl config set-cluster cluster1.my-public-domain.com --insecure-skip-tls-verify=true --server=https://$MASTER_ELB_CLUSTER1
kubectl config set-cluster cluster2.my-public-domain.com --insecure-skip-tls-verify=true --server=https://$MASTER_ELB_CLUSTER2
```

And then test:

```shell
kubectl cluster-info
Kubernetes master is running at https://cluster1-master-999999999.eu-west-1.elb.amazonaws.com
KubeDNS is running at https://cluster1-master-999999999.eu-west-1.elb.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns/proxy

kubectl get nodes
NAME                                          STATUS    ROLES     AGE       VERSION
ip-172-20-25-99.eu-west-1.compute.internal    Ready     master    2m        v1.7.10
ip-172-20-26-11.eu-west-1.compute.internal    Ready     master    3m        v1.7.10
ip-172-20-26-209.eu-west-1.compute.internal   Ready     node      27s       v1.7.10
ip-172-20-27-107.eu-west-1.compute.internal   Ready     master    2m        v1.7.10
```

In real use you should use a valid public Route53 zone and remove the private DNS mode option.

## Versions

Currently kops version 1.7.1 is supported.
