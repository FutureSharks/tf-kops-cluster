data "aws_availability_zones" "available" {}

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
