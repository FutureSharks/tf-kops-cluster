echo "== nodeup node config starting =="
ensure-install-dir

cat > kube_env.yaml << __EOF_KUBE_ENV
Assets:
- 57afca200aa6cec74fcc3072cae12385014f59c0@https://storage.googleapis.com/kubernetes-release/release/v1.6.2/bin/linux/amd64/kubelet
- 984095cd0fe8a8172ab92e2ee0add49dfc46e0c2@https://storage.googleapis.com/kubernetes-release/release/v1.6.2/bin/linux/amd64/kubectl
- 1d9788b0f5420e1a219aad2cb8681823fc515e7c@https://storage.googleapis.com/kubernetes-release/network-plugins/cni-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz
- a821df4b965dbb119ed207c397b605a1fd99db3c@https://kubeupv2.s3.amazonaws.com/kops/1.6.0/linux/amd64/utils.tar.gz
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
  hash: ca9f3a641d4130616f09403afbf5eed749633a86
  name: protokube:1.6.0
  source: https://kubeupv2.s3.amazonaws.com/kops/1.6.0/images/protokube.tar.gz

__EOF_KUBE_ENV

download-release
echo "== nodeup node config done =="
