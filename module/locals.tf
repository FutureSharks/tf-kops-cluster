locals {
  # Currently support kops version
  supported_kops_version = "1.8.0"

  # KubeAPIServer optional vars
  k8s_apiserver_options = [
    "${var.oidc_clientid != "" ? "oidcClientID: ${var.oidc_clientid}" : ""}",
    "${var.oidc_issuerurl != "" ? "oidcIssuerURL: ${var.oidc_issuerurl}" : ""}",
    "${var.oidc_usernameclaim != "" ? "oidcUsernameClaim: ${var.oidc_usernameclaim}": ""}",
    "${var.oidc_usernameprefix != "" ? "oidcUsernamePrefix: ${var.oidc_usernameprefix}": ""}",
    "${var.oidc_groupsclaim != "" ? "oidcGroupsClaim: ${var.oidc_groupsclaim}": ""}",
    "${var.oidc_groupsprefix != "" ? "oidcGroupsPrefix: ${var.oidc_groupsprefix}": ""}",
    "${var.auditlog_logpath != "" ? "auditLogPath: ${var.auditlog_logpath}": ""}",
    "${var.auth_webhook_config_file != "" ? "AuthenticationTokenWebhookConfigFile: ${var.auth_webhook_config_file}": ""}",
  ]

  # Removes the last character of the FQDN if it is '.'
  cluster_fqdn = "${replace(var.cluster_fqdn, "/\\.$/", "")}"

  # AZ names and letters are used in tags and resources names
  az_names       = "${sort(data.aws_availability_zones.available.names)}"
  az_letters_csv = "${replace(join(",", local.az_names), data.aws_region.current.name, "")}"
  az_letters     = "${split(",", local.az_letters_csv)}"

  # Number master resources to create. Defaults to the number of AZs in the region but should be 1 for regions with odd number of AZs.
  master_resource_count = "${var.force_single_master == 1 ? 1 : length(local.az_names)}"

  # Master AZs is used in the `kops create cluster` command
  master_azs = "${var.force_single_master == 1 ? element(local.az_names, 0) : join(",", local.az_names)}"

  # etcd AZs is used in tags for the master EBS volumes
  etcd_azs = "${var.force_single_master == 1 ? element(local.az_letters, 0) : local.az_letters_csv}"

  # Subnet IDs to be used by k8s ASGs
  k8s_subnet_ids = "${length(var.private_subnet_ids) == 0 ? join(",", aws_subnet.public.*.id) : join(",", var.private_subnet_ids)}"
}

locals {
  k8s_versions = {
    "1.8.4" = {
      kubelet_hash   = "125993c220d1a9b5b60ad20a867a0e7cda63e64c"
      kubectl_hash   = "8e2314db816b9b4465c5f713c1152cb0603db15e"
      cni_hash       = "1d9788b0f5420e1a219aad2cb8681823fc515e7c"
      cni_file_name  = "cni-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz"
      utils_hash     = "f62360d3351bed837ae3ffcdee65e9d57511695a"
      protokube_hash = "1b972e92520b3cafd576893ae3daeafdd1bc9ffd"
      ami_name       = "k8s-1.8-debian-jessie-amd64-hvm-ebs-2017-12-02"
      docker_version = "1.13.1"
    }

    "1.8.0" = {
      kubelet_hash   = "4c7b8aafe652ae107c9131754a2ad4e9641a025b"
      kubectl_hash   = "006fd43085e6ba2dc6b35b89af4d68cee3f689c9"
      cni_hash       = "1d9788b0f5420e1a219aad2cb8681823fc515e7c"
      cni_file_name  = "cni-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz"
      utils_hash     = "f62360d3351bed837ae3ffcdee65e9d57511695a"
      protokube_hash = "1b972e92520b3cafd576893ae3daeafdd1bc9ffd"
      ami_name       = "k8s-1.8-debian-jessie-amd64-hvm-ebs-2017-12-02"
      docker_version = "1.13.1"
    }

    "1.7.10" = {
      kubelet_hash   = "4d38bdc8e850c05103348cee2cbffbddce62bcf8"
      kubectl_hash   = "4c174128ad3657bb09c5b3bd4a05565956b44744"
      cni_hash       = "1d9788b0f5420e1a219aad2cb8681823fc515e7c"
      cni_file_name  = "cni-0799f5732f2a11b329d9e3d51b9c8f2e3759f2ff.tar.gz"
      utils_hash     = "f62360d3351bed837ae3ffcdee65e9d57511695a"
      protokube_hash = "1b972e92520b3cafd576893ae3daeafdd1bc9ffd"
      ami_name       = "k8s-1.7-debian-jessie-amd64-hvm-ebs-2017-12-02"
      docker_version = "1.12.6"
    }
  }
}

locals {
  k8s_settings = "${local.k8s_versions["${var.kubernetes_version}"]}"
}

locals {
  kubelet_hash   = "${local.k8s_settings["kubelet_hash"]}"
  kubectl_hash   = "${local.k8s_settings["kubectl_hash"]}"
  cni_hash       = "${local.k8s_settings["cni_hash"]}"
  cni_file_name  = "${local.k8s_settings["cni_file_name"]}"
  utils_hash     = "${local.k8s_settings["utils_hash"]}"
  protokube_hash = "${local.k8s_settings["protokube_hash"]}"
  ami_name       = "${local.k8s_settings["ami_name"]}"
  docker_version = "${local.k8s_settings["docker_version"]}"
}
