echo "== nodeup node config starting =="
ensure-install-dir

cat > kube_env.yaml << __EOF_KUBE_ENV
Assets:
- 4d38bdc8e850c05103348cee2cbffbddce62bcf8@https://storage.googleapis.com/kubernetes-release/release/v1.7.10/bin/linux/amd64/kubelet
- 4c174128ad3657bb09c5b3bd4a05565956b44744@https://storage.googleapis.com/kubernetes-release/release/v1.7.10/bin/linux/amd64/kubectl
- 1d9788b0f5420e1a219aad2cb8681823fc515e7c@https://storage.googleapis.com/kubernetes-release/network-plugins/cni-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz
- c18ca557507c662e3a072c3475da9bd1bc8a503b@https://kubeupv2.s3.amazonaws.com/kops/1.8.0/linux/amd64/utils.tar.gz
ClusterName: ${cluster_fqdn}
ConfigBase: s3://${kops_s3_bucket_id}/${cluster_fqdn}
InstanceGroupName: ${autoscaling_group_name}
Tags:
- _automatic_upgrades
- _aws
${kubernetes_master_tag}
- _networking_cni
channels:
- s3://${kops_s3_bucket_id}/${cluster_fqdn}/addons/bootstrap-channel.yaml
protokubeImage:
  hash: 8f796b29894b0184bff97906d072284c8e579331
  name: protokube:1.8.0
  source: https://kubeupv2.s3.amazonaws.com/kops/1.8.0/images/protokube.tar.gz

__EOF_KUBE_ENV

download-release
echo "== nodeup node config done =="
