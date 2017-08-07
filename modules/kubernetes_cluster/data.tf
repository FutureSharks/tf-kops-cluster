data "aws_availability_zones" "available" {}

data "aws_region" "current" {
  current = true
}

data "aws_ami" "k8s_1_6_debian_jessie_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["k8s-1.6-debian-jessie-amd64-hvm-ebs-2017-05-02"]
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

data "template_file" "az_letters" {
  template = "$${az_letters}"
  vars {
    az_letters = "${ replace(join(",", sort(data.aws_availability_zones.available.names)), data.aws_region.current.name, "") }"
  }
}

data "template_file" "master_resource_count" {
   template = "$${master_resource_count}"
   vars {
     master_resource_count = "${var.force_single_master == 1 ? 1 : length(data.aws_availability_zones.available.names)}"
   }
}

data "template_file" "master_azs" {
   template = "$${master_azs}"
   vars {
     master_azs = "${var.force_single_master == 1 ? element(sort(data.aws_availability_zones.available.names), 0) : join(",", data.aws_availability_zones.available.names)}"
   }
}

data "template_file" "etcd_azs" {
   template = "$${etcd_azs}"
   vars {
     etcd_azs = "${var.force_single_master == 1 ? element(split(",", data.template_file.az_letters.rendered), 0) : data.template_file.az_letters.rendered}"
   }
}
