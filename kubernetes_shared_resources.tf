resource "random_id" "s3_suffix" {
  byte_length = 6
}

resource "aws_s3_bucket" "kops" {
  bucket        = "kops-state-store-${random_id.s3_suffix.dec}"
  acl           = "private"
  versioning {
    enabled = true
  }
}

resource "aws_iam_instance_profile" "kubernetes_masters" {
  name = "kubernetes_masters"
  role = "${aws_iam_role.kubernetes_masters.name}"
}

resource "aws_iam_instance_profile" "kubernetes_nodes" {
  name = "kubernetes_nodes"
  role = "${aws_iam_role.kubernetes_nodes.name}"
}

resource "aws_iam_role" "kubernetes_masters" {
  name               = "kubernetes_masters"
  assume_role_policy = "${data.aws_iam_policy_document.kubernetes_assume_role_policy.json}"
}

resource "aws_iam_role" "kubernetes_nodes" {
  name               = "kubernetes_nodes"
  assume_role_policy = "${data.aws_iam_policy_document.kubernetes_assume_role_policy.json}"
}

data "aws_iam_policy_document" "kubernetes_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy_attachment" "kubernetes_nodes_and_master" {
  name       = "kubernetes_nodes_attachment"
  roles      = [
    "${aws_iam_role.kubernetes_nodes.name}",
    "${aws_iam_role.kubernetes_masters.name}"
  ]
  policy_arn = "${aws_iam_policy.kubernetes_nodes_and_master.arn}"
}

resource "aws_iam_policy_attachment" "kubernetes_masters" {
  name       = "kubernetes_masters_attachment"
  roles      = [
    "${aws_iam_role.kubernetes_masters.name}"
  ]
  policy_arn = "${aws_iam_policy.kubernetes_masters.arn}"
}

resource "aws_iam_policy" "kubernetes_masters" {
  name        = "kubernetes_masters"
  description = "Policy for Kubernetes master instances"
  policy      =  "${data.aws_iam_policy_document.kubernetes_masters_aws_iam_role_policy.json}"
}

resource "aws_iam_policy" "kubernetes_nodes_and_master" {
  name        = "kubernetes_nodes_and_master"
  description = "Policy for Kubernetes node and master instances"
  policy      = "${data.aws_iam_policy_document.kubernetes_nodes_aws_iam_role_policy.json}"
}

data "aws_iam_policy_document" "kubernetes_nodes_aws_iam_role_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect  = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:DescribeTags",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = ["*"]
  }

  statement {
    effect  = "Allow"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:GetHostedZone"
    ]
    resources = ["arn:aws:route53:::hostedzone/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["route53:GetChange"]
    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["route53:ListHostedZones"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = [
      "${aws_s3_bucket.kops.arn}",
      "${aws_s3_bucket.kops.arn}/*"
    ]
  }

  statement {
    effect  = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket"
    ]
    resources = ["${aws_s3_bucket.kops.arn}"]
  }

  statement {
    effect  = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = ["*"]
  }

}

data "aws_iam_policy_document" "kubernetes_masters_aws_iam_role_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:*"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["elasticloadbalancing:*"]
    resources = ["*"]
  }
}
