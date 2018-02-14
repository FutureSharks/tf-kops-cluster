data "template_file" "node_user_data_1" {
  template = "${file("${path.module}/user_data/01_nodeup_url.sh.tpl")}"

  vars {
    kops_version = "${local.supported_kops_version}"
  }
}

data "template_file" "node_user_data_3" {
  template = "${file("${path.module}/user_data/03_node_cluster_spec.sh.tpl")}"

  vars {
    kubernetes_version = "${var.kubernetes_version}"
    cluster_fqdn       = "${local.cluster_fqdn}"
    docker_version     = "${local.docker_version}"
  }
}

data "template_file" "node_user_data_4" {
  template = "${file("${path.module}/user_data/04_ig_spec.sh.tpl")}"

  vars {
    instance_group = "nodes"
  }
}

data "template_file" "node_user_data_5" {
  template = "${file("${path.module}/user_data/05_kube_env.sh.tpl")}"

  vars {
    kubernetes_version    = "${var.kubernetes_version}"
    kops_version          = "${local.supported_kops_version}"
    cluster_fqdn          = "${local.cluster_fqdn}"
    kops_s3_bucket        = "${var.kops_s3_bucket_id}"
    kubernetes_master_tag = ""
    instance_group        = "nodes"
    kubelet_hash          = "${local.kubelet_hash}"
    kubectl_hash          = "${local.kubectl_hash}"
    cni_hash              = "${local.cni_hash}"
    cni_file_name         = "${local.cni_file_name}"
    utils_hash            = "${local.utils_hash}"
    protokube_hash        = "${local.protokube_hash}"
  }
}
