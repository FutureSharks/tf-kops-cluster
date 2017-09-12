resource "aws_subnet" "public" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${element(var.subnet_cidr_blocks_public, count.index)}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = true
  tags {
    "Name"              = "public ${var.cluster_name} ${element(split(",", "a,b,c"), count.index)}"
    "KubernetesCluster" = "${data.template_file.cluster_fqdn.rendered}"
  }
}

resource "aws_subnet" "private" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${element(var.subnet_cidr_blocks_private, count.index)}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = false
  tags {
    "Name"              = "private ${var.cluster_name} ${element(split(",", "a,b,c"), count.index)}"
    "KubernetesCluster" = "${data.template_file.cluster_fqdn.rendered}"
  }
}

resource "aws_route_table_association" "private" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  route_table_id = "${var.route_table_private_id}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}

resource "aws_route_table_association" "public" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  route_table_id = "${var.route_table_public_id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}
