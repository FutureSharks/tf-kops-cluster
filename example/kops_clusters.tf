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

module "cluster1" {
  source                      = "../modules/kubernetes_cluster"
  sg_allow_ssh                = "${aws_security_group.allow_ssh.id}"
  sg_allow_http_s             = "${aws_security_group.allow_http.id}"
  cluster_name                = "cluster1"
  cluster_fqdn                = "cluster1.${aws_route53_zone.k8s_zone.name}"
  route53_zone_id             = "${aws_route53_zone.k8s_zone.id}"
  kops_s3_bucket_arn          = "${aws_s3_bucket.kops.arn}"
  kops_s3_bucket_id           = "${aws_s3_bucket.kops.id}"
  vpc_id                      = "${aws_vpc.main_vpc.id}"
  instance_key_name           = "default-key"
  node_asg_desired            = 1
  node_asg_min                = 1
  node_asg_max                = 1
  master_instance_type        = "t2.small"
  node_instance_type          = "t2.small"
  master_iam_instance_profile = "${aws_iam_instance_profile.kubernetes_masters.id}"
  node_iam_instance_profile   = "${aws_iam_instance_profile.kubernetes_nodes.id}"
  subnet_cidr_blocks          = ["${data.template_file.cluster1_cidr_blocks.*.rendered}"]
  route_table_ids             = ["${aws_route_table.public.id}"]
}

module "cluster2" {
  source                      = "../modules/kubernetes_cluster"
  sg_allow_ssh                = "${aws_security_group.allow_ssh.id}"
  sg_allow_http_s             = "${aws_security_group.allow_http.id}"
  cluster_name                = "cluster2"
  cluster_fqdn                = "cluster2.${aws_route53_zone.k8s_zone.name}"
  route53_zone_id             = "${aws_route53_zone.k8s_zone.id}"
  kops_s3_bucket_arn          = "${aws_s3_bucket.kops.arn}"
  kops_s3_bucket_id           = "${aws_s3_bucket.kops.id}"
  vpc_id                      = "${aws_vpc.main_vpc.id}"
  instance_key_name           = "default-key"
  subnet_cidr_blocks          = ["${data.template_file.cluster2_cidr_blocks.*.rendered}"]
  node_asg_desired            = 1
  node_asg_min                = 1
  node_asg_max                = 1
  master_instance_type        = "t2.small"
  node_instance_type          = "t2.small"
  master_iam_instance_profile = "${aws_iam_instance_profile.kubernetes_masters.id}"
  node_iam_instance_profile   = "${aws_iam_instance_profile.kubernetes_nodes.id}"
  route_table_ids             = ["${aws_route_table.nat_private.*.id}"]
  use_public_subnets          = false
  public_subnet_ids           = ["${aws_subnet.public.*.id}"]
}
