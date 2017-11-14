resource "aws_subnet" "k8s" {
  count                   = "${length(local.az_names)}"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${element(var.subnet_cidr_blocks, count.index)}"
  availability_zone       = "${element(local.az_names, count.index)}"
  map_public_ip_on_launch = "${var.use_public_subnets}"
  tags {
    "Name"              = "k8s cluster ${var.cluster_name} ${element(local.az_letters, count.index)}"
    "KubernetesCluster" = "${local.cluster_fqdn}"
  }
}

resource "aws_route_table_association" "k8s" {
  count          = "${length(local.az_names)}"
  route_table_id = "${element(var.route_table_ids, var.use_public_subnets == 1 ? 0 : count.index)}"
  subnet_id      = "${element(aws_subnet.k8s.*.id, count.index)}"
}
