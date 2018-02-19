resource "null_resource" "check_kops_version" {
  provisioner "local-exec" {
    command = "kops version | grep -q ${local.supported_kops_version} || echo 'Unsupported kops version. Version ${local.supported_kops_version} must be used'"
  }
}

data "template_file" "tmpl_values" {
  template = "${file("${path.module}/values.yaml.tmpl")}"

  vars {
    cluster_fqdn          = "${local.cluster_fqdn}"
    kubernetes_version    = "${var.kubernetes_version}"
    kops_dns_mode         = "${var.kops_dns_mode}"
    kops_s3_bucket_id     = "${var.kops_s3_bucket_id}"
    kubernetes_networking = "${var.kubernetes_networking}"
    zones                 = "${join(",", data.aws_availability_zones.available.names)}"
    node_asg_desired      = "${var.node_asg_desired}"
    master_azs            = "${local.master_azs}"
    vpc_id                = "${var.vpc_id}"
    ami_name              = "${local.ami_name}"
    k8s_apiserver_options = "${join("\n  ", compact(local.k8s_apiserver_options))}"
  }
}

resource "null_resource" "generate_values" {
  triggers {
    template = "${data.template_file.tmpl_values.rendered}"
  }

  provisioner "local-exec" {
    command = "echo \"${data.template_file.tmpl_values.rendered}\" > values.yaml"
  }
}

resource "null_resource" "generate_template" {
  depends_on = ["null_resource.generate_values"]

  provisioner "local-exec" {
    command = "kops toolbox template --values values.yaml --template ${path.module}/cluster_config.yaml.tmpl --output cluster_config.yaml"
  }
}

resource "null_resource" "create_cluster" {
  depends_on = ["null_resource.check_kops_version", "null_resource.generate_template"]

  provisioner "local-exec" {
    command = "kops create -f cluster_config.yaml --state=s3://${var.kops_s3_bucket_id} && kops create secret --state=s3://${var.kops_s3_bucket_id} --name ${var.cluster_fqdn} sshpublickey admin -i ~/.ssh/id_rsa.pub && kops update cluster ${var.cluster_fqdn} --state=s3://${var.kops_s3_bucket_id} --target=terraform --yes"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "kops delete cluster --yes --state=s3://${var.kops_s3_bucket_id} --unregister ${local.cluster_fqdn}"
  }
}

resource "null_resource" "delete_tf_files" {
  depends_on = ["null_resource.create_cluster"]

  provisioner "local-exec" {
    command = "rm -rf out"
  }
}
