locals {
  public_cidr_blocks = [
    "172.20.1.0/24",
    "172.20.2.0/24",
    "172.20.3.0/24",
    "172.20.4.0/24",
    "172.20.5.0/24",
    "172.20.6.0/24",
    "172.20.7.0/24",
    "172.20.8.0/24",
  ]

  cluster1_public_subnet_cidr_blocks = [
    "172.20.9.0/24",
    "172.20.10.0/24",
    "172.20.11.0/24",
    "172.20.12.0/24",
    "172.20.13.0/24",
    "172.20.14.0/24",
    "172.20.15.0/24",
    "172.20.16.0/24",
  ]

  cluster2_public_subnet_cidr_blocks = [
    "172.20.17.0/24",
    "172.20.18.0/24",
    "172.20.19.0/24",
    "172.20.20.0/24",
    "172.20.21.0/24",
    "172.20.22.0/24",
    "172.20.23.0/24",
    "172.20.24.0/24",
  ]

  cluster3_public_subnet_cidr_blocks = [
    "172.20.25.0/24",
    "172.20.26.0/24",
    "172.20.27.0/24",
    "172.20.28.0/24",
    "172.20.29.0/24",
    "172.20.30.0/24",
    "172.20.31.0/24",
    "172.20.32.0/24",
  ]

  nat_private_cidr_blocks = [
    "172.20.25.0/24",
    "172.20.26.0/24",
    "172.20.27.0/24",
    "172.20.28.0/24",
    "172.20.29.0/24",
    "172.20.30.0/24",
    "172.20.31.0/24",
    "172.20.32.0/24",
  ]
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

resource "aws_route53_zone" "vpc_internal_zone" {
  name          = "local.vpc"
  comment       = "Internal zone"
  vpc_id        = "${aws_vpc.main_vpc.id}"
  force_destroy = true
}

resource "aws_route53_zone" "k8s_zone" {
  name          = "${var.domain_name}"
  vpc_id        = "${aws_vpc.main_vpc.id}"
  force_destroy = true
}

resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name         = "${aws_route53_zone.vpc_internal_zone.name}"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags {
    Name = "main_vpc_dhcp_options"
  }
}

resource "aws_vpc_dhcp_options_association" "dhcp_options_association" {
  vpc_id          = "${aws_vpc.main_vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.dhcp_options.id}"
}

resource "aws_internet_gateway" "public" {
  vpc_id = "${aws_vpc.main_vpc.id}"
}

resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.public.id}"
  }

  tags {
    "Name" = "public"
  }
}

resource "aws_subnet" "public" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.main_vpc.id}"
  cidr_block              = "${element(local.public_cidr_blocks, count.index)}"
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

# VPC resources related to private subnets with NAT gateways

resource "aws_subnet" "nat_private" {
  count                   = "${length(data.aws_availability_zones.available.names)}"
  vpc_id                  = "${aws_vpc.main_vpc.id}"
  cidr_block              = "${element(local.nat_private_cidr_blocks, count.index)}"
  availability_zone       = "${element(data.aws_availability_zones.available.names, count.index)}"
  map_public_ip_on_launch = false

  tags {
    "Name" = "NAT private ${element(data.aws_availability_zones.available.names, count.index)}"
  }
}

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

resource "aws_route_table_association" "nat_private" {
  count          = "${length(data.aws_availability_zones.available.names)}"
  route_table_id = "${element(aws_route_table.nat_private.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.nat_private.*.id, count.index)}"
}
