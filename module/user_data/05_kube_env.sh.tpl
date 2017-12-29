cat > kube_env.yaml << '__EOF_KUBE_ENV'
Assets:
- ${kubelet_hash}@https://storage.googleapis.com/kubernetes-release/release/v${kubernetes_version}/bin/linux/amd64/kubelet
- ${kubectl_hash}@https://storage.googleapis.com/kubernetes-release/release/v${kubernetes_version}/bin/linux/amd64/kubectl
- ${cni_hash}@https://storage.googleapis.com/kubernetes-release/network-plugins/${cni_file_name}
- ${utils_hash}@https://kubeupv2.s3.amazonaws.com/kops/${kops_version}/linux/amd64/utils.tar.gz
ClusterName: ${cluster_fqdn}
ConfigBase: s3://${kops_s3_bucket}/${cluster_fqdn}
InstanceGroupName: ${instance_group}
Tags:
- _automatic_upgrades
- _aws
${kubernetes_master_tag}
- _networking_cni
channels:
- s3://${kops_s3_bucket}/${cluster_fqdn}/addons/bootstrap-channel.yaml
protokubeImage:
  hash: ${protokube_hash}
  name: protokube:${kops_version}
  source: https://kubeupv2.s3.amazonaws.com/kops/${kops_version}/images/protokube.tar.gz

__EOF_KUBE_ENV

download-release
echo "== nodeup node config done =="
