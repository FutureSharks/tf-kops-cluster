resource "aws_security_group_rule" "all_master_to_master" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.master.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all_master_to_node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.master.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "all_node_to_node" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.node.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
}

resource "aws_security_group_rule" "node_to_master_internal_elb" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master_internal_elb.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node_to_master_tcp_1-4000" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  from_port                = 1
  to_port                  = 4000
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node_to_master_tcp_4003-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  from_port                = 4003
  to_port                  = 65535
  protocol                 = "tcp"
}

resource "aws_security_group_rule" "node_to_master_udp_1-65535" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  from_port                = 1
  to_port                  = 65535
  protocol                 = "udp"
}
