data "template_file" "cluster1_cidr_blocks" {
  count    = "${length(data.aws_availability_zones.available.names)}"
  template = "$${cidr_blocks}"
  vars {
    cidr_blocks = "${cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index + length(data.aws_availability_zones.available.names))}"
  }
}

data "template_file" "cluster2_cidr_blocks" {
  count    = "${length(data.aws_availability_zones.available.names)}"
  template = "$${cidr_blocks}"
  vars {
    cidr_blocks = "${cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index + 8)}"
  }
}

data "template_file" "public_cidr_blocks" {
  count    = "${length(data.aws_availability_zones.available.names)}"
  template = "$${cidr_blocks}"
  vars {
    cidr_blocks = "${cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index)}"
  }
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags {
    Name = "main_vpc"
  }
}

resource "aws_route53_zone" "k8s_zone" {
  name          = "${var.domain_name}"
  comment       = "Kops/Terraform example zone"
  force_destroy = true
  vpc_id        = "${aws_vpc.main_vpc.id}"
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name         = "${aws_route53_zone.k8s_zone.name}"
  domain_name_servers = ["AmazonProvidedDNS"]
  tags {
    Name = "main_vpc_dhcp_options"
  }
}

resource "aws_vpc_dhcp_options_association" "dhcp_options_association" {
  vpc_id          = "${aws_vpc.main_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp_options.id}"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  tags {
    "Name" = "main_vpc"
  }
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.internet_gateway.id}"
  }
  tags {
    "Name" = "public"
  }
}

resource "aws_subnet" "public" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.main_vpc.id}"
  cidr_block              = "${element(data.template_file.public_cidr_blocks.*.rendered, count.index)}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = true
  tags {
    "Name" = "public ${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  tags {
    "Name" = "private"
  }
}

# VPC resources related to private subnets with NAT gateways

resource "aws_route_table" "nat_private" {
  count  = "${length(data.aws_availability_zones.available.names)}"
  vpc_id = "${aws_vpc.main_vpc.id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.nat_gateway.*.id, count.index)}"
  }
  tags {
    "Name" = "NAT private ${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

resource "aws_eip" "nat_gateway" {
  count = "${length(data.aws_availability_zones.available.names)}"
  vpc   = true
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = "${length(data.aws_availability_zones.available.names)}"
  allocation_id = "${element(aws_eip.nat_gateway.*.id, count.index)}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  tags {
    "Name" = "NAT ${element(data.aws_availability_zones.available.names, count.index)}"
  }
}
