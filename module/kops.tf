resource "null_resource" "check_kops_version" {
  provisioner "local-exec" {
    command = "kops version | grep -q ${local.supported_kops_version} || echo 'Unsupported kops version. Version ${local.supported_kops_version} must be used'"
  }
}

resource "null_resource" "create_cluster" {
  depends_on = ["null_resource.check_kops_version"]

  provisioner "local-exec" {
    command = <<EOT
      kops create cluster \
      --cloud=aws \
      --dns ${var.kops_dns_mode} \
      --authorization RBAC \
      --networking ${var.kubernetes_networking} \
      --zones=${join(",", local.az_names)} \
      --node-count=${var.node_asg_desired} \
      --node-size=${var.node_instance_type} \
      --master-zones=${join(",", local.master_azs)} \
      --master-count=${var.master_count} \
      --master-size=${var.master_instance_type} \
      --target=terraform \
      --api-loadbalancer-type=public \
      --vpc=${var.vpc_id} \
      --ssh-public-key ${var.ssh_public_key_path} \
      --state=s3://${var.kops_s3_bucket_id} \
      --kubernetes-version ${var.kubernetes_version} \
      ${local.cluster_fqdn}
    EOT
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = <<EOT
      kops delete cluster \
      --state=s3://${var.kops_s3_bucket_id} \
      --unregister \
      --yes \
      ${local.cluster_fqdn}
    EOT
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "null_resource" "delete_tf_files" {
  depends_on = ["null_resource.create_cluster"]

  provisioner "local-exec" {
    command = "rm -rf out"
  }
}
