################################################################################
# Cluster using public subnets

module "cluster1" {
  source                    = "../module"
  kubernetes_version        = "1.9.9"
  sg_allow_ssh              = "${aws_security_group.allow_ssh.id}"
  sg_allow_http_s           = "${aws_security_group.allow_http.id}"
  cluster_name              = "cluster1"
  cluster_fqdn              = "cluster1.${aws_route53_zone.k8s_zone.name}"
  route53_zone_id           = "${aws_route53_zone.k8s_zone.id}"
  kops_s3_bucket_arn        = "${aws_s3_bucket.kops.arn}"
  kops_s3_bucket_id         = "${aws_s3_bucket.kops.id}"
  vpc_id                    = "${aws_vpc.main_vpc.id}"
  instance_key_name         = "default-key"
  node_asg_desired          = 1
  node_asg_min              = 1
  node_asg_max              = 1
  master_instance_type      = "t2.small"
  node_instance_type        = "t2.small"
  internet_gateway_id       = "${aws_internet_gateway.public.id}"
  public_subnet_cidr_blocks = ["${local.cluster1_public_subnet_cidr_blocks}"]
  kops_dns_mode             = "private"
}

################################################################################
# Cluster using private subnets

module "cluster2" {
  source                    = "../module"
  kubernetes_version        = "1.7.10"
  sg_allow_ssh              = "${aws_security_group.allow_ssh.id}"
  sg_allow_http_s           = "${aws_security_group.allow_http.id}"
  cluster_name              = "cluster2"
  cluster_fqdn              = "cluster2.${aws_route53_zone.k8s_zone.name}"
  route53_zone_id           = "${aws_route53_zone.k8s_zone.id}"
  kops_s3_bucket_arn        = "${aws_s3_bucket.kops.arn}"
  kops_s3_bucket_id         = "${aws_s3_bucket.kops.id}"
  vpc_id                    = "${aws_vpc.main_vpc.id}"
  instance_key_name         = "default-key"
  node_asg_desired          = 1
  node_asg_min              = 1
  node_asg_max              = 1
  master_instance_type      = "t2.small"
  node_instance_type        = "t2.small"
  internet_gateway_id       = "${aws_internet_gateway.public.id}"
  public_subnet_cidr_blocks = ["${local.cluster2_public_subnet_cidr_blocks}"]
  private_subnet_ids        = ["${aws_subnet.nat_private.*.id}"]
  kops_dns_mode             = "private"
  kubernetes_networking     = "flannel"
}

resource "random_id" "s3_suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "kops" {
  bucket        = "kops-state-store-${random_id.s3_suffix.dec}"
  acl           = "private"
  force_destroy = true

  versioning {
    enabled = true
  }
}
