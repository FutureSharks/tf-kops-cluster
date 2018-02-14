resource "aws_iam_instance_profile" "masters" {
  name = "k8s_masters_${var.cluster_name}"
  role = "${aws_iam_role.masters.name}"
}

resource "aws_iam_role" "masters" {
  name               = "k8s_masters_${var.cluster_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy_masters.json}"
}

data "aws_iam_policy_document" "assume_role_policy_masters" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy_attachment" "masters" {
  name = "k8s_masters_${var.cluster_name}_attachment"

  roles = [
    "${aws_iam_role.masters.name}",
  ]

  policy_arn = "${aws_iam_policy.masters.arn}"
}

resource "aws_iam_policy" "masters" {
  name        = "k8s_masters_${var.cluster_name}"
  description = "Kubernetes cluster ${var.cluster_name} masters instances"
  policy      = "${data.aws_iam_policy_document.masters.json}"
}

data "aws_iam_policy_document" "masters" {
  statement {
    sid    = "kopsK8sEC2MasterPermsDescribeResources"
    effect = "Allow"

    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVolumes",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "kopsK8sEC2MasterPermsAllResources"
    effect = "Allow"

    actions = [
      "ec2:CreateRoute",
      "ec2:CreateSecurityGroup",
      "ec2:CreateTags",
      "ec2:CreateVolume",
      "ec2:ModifyInstanceAttribute",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "kopsK8sEC2MasterPermsTaggedResources"
    effect = "Allow"

    actions = [
      "ec2:AttachVolume",
      "ec2:AuthorizeSecurityGroupIngress",
      "ec2:DeleteRoute",
      "ec2:DeleteSecurityGroup",
      "ec2:DeleteVolume",
      "ec2:DetachVolume",
      "ec2:RevokeSecurityGroupIngress",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:ResourceTag/KubernetesCluster"
      values   = ["${local.cluster_fqdn}"]
    }
  }

  statement {
    sid    = "kopsK8sASMasterPermsAllResources"
    effect = "Allow"

    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:GetAsgForInstance",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "kopsK8sASMasterPermsTaggedResources"
    effect = "Allow"

    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "autoscaling:UpdateAutoScalingGroup",
    ]

    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "autoscaling:ResourceTag/KubernetesCluster"
      values   = ["${local.cluster_fqdn}"]
    }
  }

  statement {
    sid    = "kopsK8sELBMasterPermsRestrictive"
    effect = "Allow"

    actions = [
      "elasticloadbalancing:AttachLoadBalancerToSubnets",
      "elasticloadbalancing:ApplySecurityGroupsToLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancer",
      "elasticloadbalancing:CreateLoadBalancerPolicy",
      "elasticloadbalancing:CreateLoadBalancerListeners",
      "elasticloadbalancing:ConfigureHealthCheck",
      "elasticloadbalancing:DeleteLoadBalancer",
      "elasticloadbalancing:DeleteLoadBalancerListeners",
      "elasticloadbalancing:DescribeLoadBalancers",
      "elasticloadbalancing:DescribeLoadBalancerAttributes",
      "elasticloadbalancing:DetachLoadBalancerFromSubnets",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:ModifyLoadBalancerAttributes",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:SetLoadBalancerPoliciesForBackendServer",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "kopsMasterCertIAMPerms"
    effect = "Allow"

    actions = [
      "iam:ListServerCertificates",
      "iam:GetServerCertificate",
    ]

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
    sid    = "kopsK8sS3MasterBucketFullGet"
    effect = "Allow"

    actions = [
      "s3:Get*",
    ]

    resources = ["${var.kops_s3_bucket_arn}/${local.cluster_fqdn}/*"]
  }

  statement {
    sid    = "kopsK8sRoute53Change"
    effect = "Allow"

    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListResourceRecordSets",
      "route53:GetHostedZone",
    ]

    resources = ["arn:aws:route53:::hostedzone/${var.route53_zone_id}"]
  }

  statement {
    sid    = "kopsK8sRoute53GetChanges"
    effect = "Allow"

    actions = [
      "route53:GetChange",
    ]

    resources = ["arn:aws:route53:::change/*"]
  }

  statement {
    sid    = "kopsK8sRoute53ListZones"
    effect = "Allow"

    actions = [
      "route53:ListHostedZones",
    ]

    resources = ["*"]
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
