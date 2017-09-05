# Full working example with VPC resources

data "aws_availability_zones" "available" {}

variable "aws_region" {
  default = "eu-west-1"
}

provider "aws" {
  region = "${var.aws_region}"
}

module "cluster1" {
  source                      = "modules/kubernetes_cluster"
  sg_allow_ssh                = "${aws_security_group.allow_ssh.id}"
  sg_allow_http_s             = "${aws_security_group.allow_http.id}"
  cluster_name                = "cluster1"
  cluster_fqdn                = "cluster1.${aws_route53_zone.internal_zone.name}"
  route53_zone_id             = "${aws_route53_zone.internal_zone.id}"
  kops_s3_bucket_arn          = "${aws_s3_bucket.kops.arn}"
  kops_s3_bucket_id           = "${aws_s3_bucket.kops.id}"
  vpc_id                      = "${aws_vpc.main_vpc.id}"
  instance_key_name           = "default-key"
  route_table_public_id       = "${aws_route_table.public.id}"
  route_table_private_id      = "${aws_route_table.private.id}"
  subnet_cidr_blocks_public   = ["${data.template_file.cluster1_public_cidr.*.rendered}"]
  subnet_cidr_blocks_private  = ["${data.template_file.cluster1_private_cidr.*.rendered}"]
  node_asg_desired            = 1
  node_asg_min                = 1
  node_asg_max                = 1
  master_instance_type        = "t2.small"
  node_instance_type          = "t2.small"
  master_iam_instance_profile = "${aws_iam_instance_profile.kubernetes_masters.id}"
  node_iam_instance_profile   = "${aws_iam_instance_profile.kubernetes_nodes.id}"
  dns                         = "private"
}

data "template_file" "cluster1_private_cidr" {
  count    = "${length(data.aws_availability_zones.available.names)}"
  template = "$${cluster1_private_cidr}"
  vars {
    cluster1_private_cidr = "${cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index)}"
  }
}

data "template_file" "cluster1_public_cidr" {
  count    = "${length(data.aws_availability_zones.available.names)}"
  template = "$${cluster1_public_cidr}"
  vars {
    cluster1_public_cidr = "${cidrsubnet(aws_vpc.main_vpc.cidr_block, 8, count.index + length(data.aws_availability_zones.available.names))}"
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

resource "aws_route53_zone" "internal_zone" {
  name       = "vpc-local"
  comment    = "Internal zone"
  vpc_id     = "${aws_vpc.main_vpc.id}"
}


resource "aws_vpc_dhcp_options" "dhcp_options" {
  domain_name         = "${aws_route53_zone.internal_zone.name}"
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

resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main_vpc.id}"
  tags {
    "Name" = "private"
  }
}

resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  vpc_id = "${aws_vpc.main_vpc.id}"
  description = "Allows SSH access from everywhere"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_http" {
  name = "allow_http_s"
  vpc_id = "${aws_vpc.main_vpc.id}"
  description = "Allows HTTP/S access from everywhere"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "allow_http"
  }
}
