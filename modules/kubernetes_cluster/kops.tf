resource "null_resource" "create_cluster" {
  provisioner "local-exec" {
    command = "kops create cluster --dns private --networking flannel --zones=eu-west-1a,eu-west-1b,eu-west-1c --node-count=${var.node_asg_desired} --master-zones=${var.master_availability_zone} --target=terraform --api-loadbalancer-type=public --vpc=${var.vpc_id} --state=s3://${var.kops_s3_bucket_id} --kubernetes-version ${var.kubernetes_version} ${var.cluster_fqdn}"
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
