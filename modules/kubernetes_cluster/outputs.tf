output "node_sg_id" {
  value = "${aws_security_group.master.id}"
}
output "node_asg_name" {
  value = "${aws_autoscaling_group.node.name}"
}
output "master_sg_id" {
  value = "${aws_security_group.node.id}"
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
output "cloudwatch_log_group_name" {
  value = "${aws_cloudwatch_log_group.cluster.name}"
}
output "cloudwatch_log_group_arn" {
  value = "${aws_cloudwatch_log_group.cluster.arn}"
}
