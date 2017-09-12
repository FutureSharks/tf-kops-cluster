output "node_sg_id" {
  value = "${aws_security_group.node.id}"
}
output "node_asg_name" {
  value = "${aws_autoscaling_group.node.name}"
}
output "node_asg_id" {
  value = "${aws_autoscaling_group.node.id}"
}
output "node_asg_arn" {
  value = "${aws_autoscaling_group.node.arn}"
}
output "master_sg_id" {
  value = "${aws_security_group.master.id}"
}
output "master_elb_sg_id" {
  value = "${aws_security_group.master_elb.id}"
}
output "master_elb_dns_name" {
  value = "${aws_elb.master.dns_name}"
}
output "master_internal_elb_dns_name" {
  value = "${aws_elb.master_internal.dns_name}"
}
output "master_asg_name" {
  value = "${aws_autoscaling_group.master.name}"
}
output "master_asg_id" {
  value = "${aws_autoscaling_group.master.id}"
}
output "master_asg_arn" {
  value = "${aws_autoscaling_group.master.arn}"
}
output "cloudwatch_log_group_name" {
  value = "${aws_cloudwatch_log_group.cluster.name}"
}
output "cloudwatch_log_group_arn" {
  value = "${aws_cloudwatch_log_group.cluster.arn}"
}
output "cluster_fqdn" {
  value = "${data.template_file.cluster_fqdn.rendered}"
}
