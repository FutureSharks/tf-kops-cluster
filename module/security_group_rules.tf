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

# IPv4 encapsulation for calico
resource "aws_security_group_rule" "node_to_master_ipip" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "4"
}

resource "aws_security_group_rule" "node_to_master_tcp_1-2379" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  from_port                = 1
  to_port                  = 2379
  protocol                 = "tcp"
}

# to port 4001 for calico and flannel
resource "aws_security_group_rule" "node_to_master_tcp_2382-4001" {
  type                     = "ingress"
  security_group_id        = "${aws_security_group.master.id}"
  source_security_group_id = "${aws_security_group.node.id}"
  from_port                = 2382
  to_port                  = 4001
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
