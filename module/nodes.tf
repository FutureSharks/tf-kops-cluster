### ASG OnDemand Instances
resource "aws_autoscaling_group" "node" {
  depends_on           = ["null_resource.create_cluster"]
  name                 = "${var.cluster_name}_node"
  launch_configuration = "${aws_launch_configuration.node.id}"
  max_size             = "${var.node_asg_max}"
  min_size             = "${var.node_asg_min}"
  desired_capacity     = "${var.node_asg_desired}"
  vpc_zone_identifier  = ["${split(",", local.k8s_subnet_ids)}"]

  # Ignore changes to autoscaling group min/max/desired as these attributes are
  # managed by the Kubernetes cluster autoscaler addon
  lifecycle {
    ignore_changes = [
      "max_size",
      "min_size",
      "desired_capacity",
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

resource "aws_launch_configuration" "node" {
  name_prefix          = "${var.cluster_name}-node"
  image_id             = "${data.aws_ami.k8s_ami.id}"
  instance_type        = "${var.node_instance_type}"
  key_name             = "${var.instance_key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.nodes.name}"
  user_data            = "${element(data.template_file.node_user_data_1.*.rendered, count.index)}${file("${path.module}/user_data/02_download_nodeup.sh")}${element(data.template_file.node_user_data_3.*.rendered, count.index)}${element(data.template_file.node_user_data_4.*.rendered, count.index)}${element(data.template_file.node_user_data_5.*.rendered, count.index)}"

  security_groups = [
    "${aws_security_group.node.id}",
    "${var.sg_allow_ssh}",
  ]

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

### If max_price_spot, then will be created one more ASG and LC
resource "aws_autoscaling_group" "node_spot" {
  count                = "${var.max_price_spot != "" ? 1 : 0}"

  depends_on           = ["null_resource.create_cluster"]
  name                 = "${var.cluster_name}_node_spot"
  launch_configuration = "${aws_launch_configuration.node_spot.id}"
  max_size             = "${var.node_asg_max}"
  min_size             = "${var.node_asg_min}"
  desired_capacity     = "${var.node_asg_desired}"
  vpc_zone_identifier  = ["${split(",", local.k8s_subnet_ids)}"]

  # Ignore changes to autoscaling group min/max/desired as these attributes are
  # managed by the Kubernetes cluster autoscaler addon
  lifecycle {
    ignore_changes = [
      "max_size",
      "min_size",
      "desired_capacity",
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

resource "aws_launch_configuration" "node_spot" {
  count                = "${var.max_price_spot != "" ? 1 : 0}"

  name_prefix          = "${var.cluster_name}-node-spot"
  image_id             = "${data.aws_ami.k8s_ami.id}"
  instance_type        = "${var.spot_node_instance_type}"
  key_name             = "${var.instance_key_name}"
  spot_price           = "${var.max_price_spot}"
  iam_instance_profile = "${aws_iam_instance_profile.nodes.name}"
  user_data            = "${element(data.template_file.node_user_data_1.*.rendered, count.index)}${file("${path.module}/user_data/02_download_nodeup.sh")}${element(data.template_file.node_user_data_3.*.rendered, count.index)}${element(data.template_file.node_user_data_4.*.rendered, count.index)}${element(data.template_file.node_user_data_5.*.rendered, count.index)}"

  security_groups = [
    "${aws_security_group.node.id}",
    "${var.sg_allow_ssh}",
  ]

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 128
    delete_on_termination = true
  }

  lifecycle = {
    create_before_destroy = true
  }
}
