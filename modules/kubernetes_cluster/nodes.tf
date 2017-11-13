resource "aws_autoscaling_group" "node" {
  depends_on           = [ "null_resource.create_cluster" ]
  name                 = "${var.cluster_name}_node"
  launch_configuration = "${aws_launch_configuration.node.id}"
  max_size             = "${var.node_asg_max}"
  min_size             = "${var.node_asg_min}"
  desired_capacity     = "${var.node_asg_desired}"
  vpc_zone_identifier  = ["${aws_subnet.k8s.*.id}"]

  # Ignore changes to autoscaling group min/max/desired as these attributes are
  # managed by the Kubernetes cluster autoscaler addon
  lifecycle {
      ignore_changes = [
        "max_size",
        "min_size",
        "desired_capacity"
      ]
  }

  tag = {
    key                 = "KubernetesCluster"
    value               = "${local.cluster_fqdn}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "${var.cluster_name}_node"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/node"
    value               = "1"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "1"
    propagate_at_launch = true
  }
}

data "template_file" "node_user_data" {
  template = "${file("${path.module}/data/nodeup_node_config.tpl")}"
  vars {
    cluster_fqdn           = "${local.cluster_fqdn}"
    kops_s3_bucket_id      = "${var.kops_s3_bucket_id}"
    autoscaling_group_name = "nodes"
    kubernetes_master_tag  = ""

  }
}

resource "aws_launch_configuration" "node" {
  name_prefix                 = "${var.cluster_name}-node"
  image_id                    = "${data.aws_ami.k8s_1_7_debian_jessie_ami.id}"
  instance_type               = "${var.node_instance_type}"
  key_name                    = "${var.instance_key_name}"
  iam_instance_profile        = "${var.node_iam_instance_profile}"
  security_groups             = [
    "${aws_security_group.node.id}",
    "${var.sg_allow_ssh}"
  ]

  user_data                   = "${file("${path.module}/data/user_data.sh")}${data.template_file.node_user_data.rendered}"

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_security_group" "node" {
  name        = "${var.cluster_name}-node"
  vpc_id      = "${var.vpc_id}"
  description = "Kubernetes cluster ${var.cluster_name} nodes"

  tags = {
    KubernetesCluster = "${local.cluster_fqdn}"
    Name              = "${var.cluster_name}_node"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
