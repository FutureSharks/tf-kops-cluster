terraform = {
  required_version = ">= 0.10.6"
}

data "aws_availability_zones" "available" {}

data "aws_region" "current" {
  current = true
}

data "aws_ami" "k8s_1_7_debian_jessie_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["k8s-1.7-debian-jessie-amd64-hvm-ebs-2017-07-28"]
  }

  filter {
    name   = "owner-id"
    values = ["383156758163"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  # Removes the last character of the FQDN if it is '.'
  cluster_fqdn = "${replace(var.cluster_fqdn, "/\\.$/", "")}"
  # AZ names and letters are used in tags and resources names
  az_names = "${sort(data.aws_availability_zones.available.names)}"
  az_letters_csv = "${replace(join(",", local.az_names), data.aws_region.current.name, "")}"
  az_letters = "${split(",", local.az_letters_csv)}"
  # Number master resources to create. Defaults to the number of AZs in the region but should be 1 for regions with odd number of AZs.
  master_resource_count = "${var.force_single_master == 1 ? 1 : length(local.az_names)}"
  # Master AZs is used in the `kops create cluster` command
  master_azs = "${var.force_single_master == 1 ? element(local.az_names, 0) : join(",", local.az_names)}"
  # etcd AZs is used in tags for the master EBS volumes
  etcd_azs = "${var.force_single_master == 1 ? element(az_letters, 0) : local.az_letters_csv}"
}
