# Full terraform example

You can run `terraform apply` from this directory to build 2 example clusters with shared VPC and IAM resources. `cluster1` uses public subnets and `cluster2` uses private subnets with NAT gateways.

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
