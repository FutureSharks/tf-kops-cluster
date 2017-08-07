resource "null_resource" "check_kops_version" {
  provisioner "local-exec" {
    command = "${path.module}/bin/check_kops_version.sh ${path.module}/data/user_data.sh"
  }
}

resource "null_resource" "create_cluster" {
  depends_on = [ "null_resource.check_kops_version" ]
  provisioner "local-exec" {
    command = "kops create cluster --dns ${var.dns} --networking flannel --zones=${join(",", data.aws_availability_zones.available.names)} --node-count=${var.node_asg_desired} --master-zones=${var.force_single_master == 1 ? element(data.aws_availability_zones.available.names, 1) : join(",", data.aws_availability_zones.available.names)} --target=terraform --api-loadbalancer-type=public --vpc=${var.vpc_id} --state=s3://${var.kops_s3_bucket_id} --kubernetes-version ${var.kubernetes_version} ${var.cluster_fqdn}"
  }
  provisioner "local-exec" {
    when    = "destroy"
    command = "kops delete cluster --yes --state=s3://${var.kops_s3_bucket_id} --unregister ${var.cluster_fqdn}"
  }
}

resource "null_resource" "delete_tf_files" {
  depends_on = [ "null_resource.create_cluster" ]
  provisioner "local-exec" {
    command = "rm -rf out"
  }
}
