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

A full example with VPC resources in [example](example). `terraform apply` can be run from this directory to build 2 example clusters with shared VPC and IAM resources. `cluster1` uses public subnets and `cluster2` uses private subnets with NAT gateways.

Note that this example is using non-existent domain and private DNS mode so a configuration change is required to connect to the Kubernetes API after creation:

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

## Supported settings

### Kubernetes API Server settings:
Currently this module only supports a handful of API server settings but they are trivial to add as you require them.

| Parameter | Description | Example |
| -------------- | --------------- | ------------ |
| oidc_issuerurl | 	URL of the provider which allows the API server to discover public signing keys. Only URLs which use the https:// scheme are accepted. This is typically the provider’s discovery URL without a path, for example “https://accounts.google.com” or “https://login.salesforce.com”. This URL should point to the level below .well-known/openid-configuration | If the discovery URL is https://accounts.google.com/.well-known/openid-configuration, the value should be https://accounts.google.com
| oidc_clientid | A client id that all tokens must be issued for. | kubernetes |
| oidc_usernameclaim | JWT claim to use as the user name. By default sub, which is expected to be a unique identifier of the end user. Admins can choose other claims, such as email or name, depending on their provider. However, claims other than email will be prefixed with the issuer URL to prevent naming clashes with other plugins. | sub |
| oidc_usernameprefix |Prefix prepended to username claims to prevent clashes with existing names (such as system: users). For example, the value oidc: will create usernames like oidc:jane.doe. If this flag isn’t provided and --oidc-user-claim is a value other than email the prefix defaults to ( Issuer URL )# where ( Issuer URL ) is the value of --oidc-issuer-url. The value - can be used to disable all prefixing.	 | oidc: |
| oidc_groupsclaim | JWT claim to use as the user’s group. If the claim is present it must be an array of strings.	 | groups |
| oidc_groupsprefix | Prefix prepended to group claims to prevent clashes with existing names (such as system: groups). For example, the value oidc: will create group names like oidc:engineering and oidc:infra.	 | oidc: |
| auditlog_logpath | specifies the log file path that log backend uses to write audit events. Not specifying this flag disables log backend. - means standard out | /var/log/audit |
| auth_webhook_config_file | This is used for authentication webhooks. Required for [Heptio Authenticator for AWS](https://github.com/heptio/authenticator) for example. | /etc/kubernetes/heptio-authenticator-aws/kubeconfig.yaml |

>For more information on OIDC Authentication in Kubernetes, read https://kubernetes.io/docs/admin/authentication/#openid-connect-tokens  
>For more information on authenticating using AWS IAM role, read https://github.com/heptio/authenticator#how-do-i-use-it

To add additional API Server settings, add new variables to the `k8s_apiserver_options` list in the  [`locals.tf`](https://github.com/FutureSharks/tf-kops-cluster/blob/master/module/locals.tf#L6) file and make sure they are formated correctly.  
The correct final format is
`Key: Value` where `Key` is a valid config flag from [Kops](https://github.com/kubernetes/kops/blob/master/docs/cluster_spec.md#kubeapiserver).


Authorisation: RBAC

Networking: calico or flannel

Kops version: 1.8.0

Supported Kubernetes versions:
  - 1.7.10
  - 1.8.0
  - 1.8.4
