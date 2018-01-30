resource "aws_iam_instance_profile" "nodes" {
  name = "k8s_nodes_${var.cluster_name}"
  role = "${aws_iam_role.nodes.name}"
}

resource "aws_iam_role" "nodes" {
  name               = "k8s_nodes_${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy_nodes.json}"
}

data "aws_iam_policy_document" "assume_role_policy_nodes" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy_attachment" "nodes" {
  name       = "k8s_cluster_${var.cluster_name}_nodes"
  roles      = ["${aws_iam_role.nodes.name}"]
  policy_arn = "${aws_iam_policy.nodes.arn}"
}

resource "aws_iam_policy" "nodes" {
  name        = "k8s_cluster_${var.cluster_name}_nodes"
  description = "Kubernetes cluster ${var.cluster_name} nodes instances"
  policy      = "${data.aws_iam_policy_document.nodes.json}"
}

data "aws_iam_policy_document" "nodes" {
  statement {
    sid       = "kopsK8sEC2NodePerms"
    effect    = "Allow"
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }

  statement {
    sid    = "kopsK8sS3GetListBucket"
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = ["${var.kops_s3_bucket_arn}"]
  }

  statement {
    sid    = "kopsK8sS3NodeBucketSelectiveGet"
    effect = "Allow"

    actions = [
      "s3:Get*",
    ]

    resources = [
      "${var.kops_s3_bucket_arn}",
      "${var.kops_s3_bucket_arn}/${local.cluster_fqdn}/addons/*",
      "${var.kops_s3_bucket_arn}/${local.cluster_fqdn}/cluster.spec",
      "${var.kops_s3_bucket_arn}/${local.cluster_fqdn}/config",
      "${var.kops_s3_bucket_arn}/${local.cluster_fqdn}/instancegroup/*",
      "${var.kops_s3_bucket_arn}/${local.cluster_fqdn}/pki/issued/*",
      "${var.kops_s3_bucket_arn}/${local.cluster_fqdn}/pki/private/kube-proxy/*",
      "${var.kops_s3_bucket_arn}/${local.cluster_fqdn}/pki/private/kubelet/*",
      "${var.kops_s3_bucket_arn}/${local.cluster_fqdn}/pki/ssh/*",
      "${var.kops_s3_bucket_arn}/${local.cluster_fqdn}/secrets/dockerconfig",
    ]
  }

  statement {
    sid    = "kopsK8sECR"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:ListImages",
      "ecr:BatchGetImage",
    ]

    resources = ["*"]
  }
}
