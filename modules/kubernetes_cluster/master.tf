resource "aws_autoscaling_group" "master" {
  depends_on           = [ "null_resource.create_cluster" ]
  count                = "${var.force_single_master == 1 ? 1 : length(data.aws_availability_zones.available.names)}"
  name                 = "${var.cluster_name}_master_${element(split(",", "a,b,c"), count.index)}"
  vpc_zone_identifier  = ["${element(var.vpc_public_subnet_ids, count.index)}"]
  launch_configuration = "${element(aws_launch_configuration.master.*.id, count.index)}"
  load_balancers       = [
    "${aws_elb.master.name}",
    "${aws_elb.master_internal.name}"
  ]
  max_size         = 1
  min_size         = 1
  desired_capacity = 1

  tag = {
    key                 = "KubernetesCluster"
    value               = "${var.cluster_fqdn}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "Name"
    value               = "${var.cluster_name}_master_${element(split(",", "a,b,c"), count.index)}"
    propagate_at_launch = true
  }

  tag = {
    key                 = "k8s.io/role/master"
    value               = "1"
    propagate_at_launch = true
  }
}

resource "aws_elb" "master" {
  name            = "${var.cluster_name}-master"
  subnets         = ["${var.vpc_public_subnet_ids}"]
  security_groups = [
    "${aws_security_group.master_elb.id}",
    "${var.sg_allow_http_s}"
  ]
  listener {
    instance_port     = 443
    instance_protocol = "tcp"
    lb_port           = 443
    lb_protocol       = "tcp"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:443"
    interval            = 30
  }
  tags {
    Name              = "${var.cluster_name}_master"
    KubernetesCluster = "${var.cluster_fqdn}"
  }
}

resource "aws_elb" "master_internal" {
  name         = "${var.cluster_name}-master-internal"
  subnets      = ["${var.vpc_private_subnet_ids}"]
  internal     = true
  idle_timeout = 300
  listener = {
    instance_port     = 443
    instance_protocol = "TCP"
    lb_port           = 443
    lb_protocol       = "TCP"
  }
  security_groups = [
    "${aws_security_group.master_internal_elb.id}",
  ]
  health_check = {
    target              = "TCP:443"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
    timeout             = 5
  }
  tags = {
    KubernetesCluster = "${var.cluster_fqdn}"
    Name              = "${var.cluster_name}_master_internal"
  }
}

resource "aws_route53_record" "master_elb" {
  name = "api.${var.cluster_fqdn}"
  type = "A"

  alias = {
    name                   = "${aws_elb.master.dns_name}"
    zone_id                = "${aws_elb.master.zone_id}"
    evaluate_target_health = false
  }

  zone_id = "/hostedzone/${var.route53_zone_id}"
}

resource "aws_security_group" "master" {
  name        = "${var.cluster_name}_master"
  vpc_id      = "${var.vpc_id}"
  description = "${var.cluster_name} master"
  tags = {
    Name              = "${var.cluster_name}_master"
    KubernetesCluster = "${var.cluster_fqdn}"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "master_elb_to_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.master_elb.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "internal_master_elb_to_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.master_internal_elb.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group" "master_elb" {
  name        = "${var.cluster_name}-master-elb"
  vpc_id      = "${var.vpc_id}"
  description = "${var.cluster_name} master ELB"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.cluster_name}_master_elb"
  }
}

resource "aws_security_group" "master_internal_elb" {
  name        = "${var.cluster_name}-master-internal-elb"
  vpc_id      = "${var.vpc_id}"
  description = "${var.cluster_name} master internal ELB"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "${var.cluster_name}_master_internal_elb"
  }
}

data "template_file" "master_user_data" {
  count    = "${var.force_single_master == 1 ? 1 : length(data.aws_availability_zones.available.names)}"
  template = "${file("${path.module}/data/nodeup_node_config.tpl")}"
  vars {
    cluster_fqdn           = "${var.cluster_fqdn}"
    kops_s3_bucket_id      = "${var.kops_s3_bucket_id}"
    autoscaling_group_name = "master-${element(data.aws_availability_zones.available.names, count.index)}"
    kubernetes_master_tag  = "- _kubernetes_master"
  }
}

resource "aws_launch_configuration" "master" {
  count                = "${var.force_single_master == 1 ? 1 : length(data.aws_availability_zones.available.names)}"
  name_prefix          = "${var.cluster_name}-master-${element(data.aws_availability_zones.available.names, count.index)}-"
  image_id             = "${data.aws_ami.k8s_1_6_debian_jessie_ami.id}"
  instance_type        = "${var.master_instance_type}"
  key_name             = "${var.instance_key_name}"
  iam_instance_profile = "${var.master_iam_instance_profile}"
  user_data            = "${file("${path.module}/data/user_data.sh")}${element(data.template_file.master_user_data.*.rendered, count.index)}"

  security_groups      = [
    "${aws_security_group.master.id}",
    "${var.sg_allow_ssh}"
  ]

  root_block_device = {
    volume_type           = "gp2"
    volume_size           = 20
    delete_on_termination = true
  }

  ephemeral_block_device = {
    device_name  = "/dev/sdc"
    virtual_name = "ephemeral0"
  }

  lifecycle = {
    create_before_destroy = true
  }
}

resource "aws_ebs_volume" "etcd-events" {
  count             = "${var.force_single_master == 1 ? 1 : length(data.aws_availability_zones.available.names)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "${var.cluster_fqdn}"
    Name                 = "${element(split(",", "a,b,c"), count.index)}.etcd-events.${var.cluster_fqdn}"
    "k8s.io/etcd/events" = "${element(split(",", "a,b,c"), count.index)}/a,b,c"
    "k8s.io/role/master" = "1"
  }
}

resource "aws_ebs_volume" "etcd-main" {
  count             = "${var.force_single_master == 1 ? 1 : length(data.aws_availability_zones.available.names)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  size              = 20
  type              = "gp2"
  encrypted         = false

  tags = {
    KubernetesCluster    = "${var.cluster_fqdn}"
    Name                 = "${element(split(",", "a,b,c"), count.index)}.etcd-main.${var.cluster_fqdn}"
    "k8s.io/etcd/main"   = "${element(split(",", "a,b,c"), count.index)}/a,b,c"
    "k8s.io/role/master" = "1"
  }
}
