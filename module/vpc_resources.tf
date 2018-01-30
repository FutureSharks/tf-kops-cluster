resource "aws_subnet" "public" {
  count                   = "${length(local.az_names)}"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${element(var.public_subnet_cidr_blocks, count.index)}"
  availability_zone       = "${element(local.az_names, count.index)}"
  map_public_ip_on_launch = true

  tags {
    "Name"              = "k8s cluster ${var.cluster_name} ${element(local.az_letters, count.index)} public"
    "KubernetesCluster" = "${local.cluster_fqdn}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.internet_gateway_id}"
  }

  tags {
    "Name" = "k8s cluster ${var.cluster_name} public"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(local.az_names)}"
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}
