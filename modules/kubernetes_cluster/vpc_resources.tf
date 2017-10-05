resource "aws_subnet" "public" {
  count                   = "${length(local.az_names)}"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${element(var.subnet_cidr_blocks_public, count.index)}"
  availability_zone       = "${element(local.az_names, count.index)}"
  map_public_ip_on_launch = true
  tags {
    "Name"              = "public ${var.cluster_name} ${element(local.az_letters, count.index)}"
    "KubernetesCluster" = "${local.cluster_fqdn}"
  }
}

resource "aws_subnet" "private" {
  count                   = "${length(local.az_names)}"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${element(var.subnet_cidr_blocks_private, count.index)}"
  availability_zone       = "${element(local.az_names, count.index)}"
  map_public_ip_on_launch = false
  tags {
    "Name"              = "private ${var.cluster_name} ${element(local.az_letters, count.index)}"
    "KubernetesCluster" = "${local.cluster_fqdn}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(local.az_names)}"
  route_table_id = "${var.route_table_private_id}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(local.az_names)}"
  route_table_id = "${var.route_table_public_id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}
