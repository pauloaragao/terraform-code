locals {
  workspace_suffix = lower(terraform.workspace)
  cluster_name     = "${var.cluster_name}-${local.workspace_suffix}"
  node_group_name  = "${var.node_group_name}-${local.workspace_suffix}"

  tags = {
    Project     = local.cluster_name
    ManagedBy   = "Terraform"
    CostControl = "apply-destroy"
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "${local.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json
  tags               = local.tags

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

resource "aws_eks_cluster" "main" {
  name     = local.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    public_access_cidrs     = var.public_access_cidrs
    subnet_ids              = data.aws_subnets.default.ids
  }

  enabled_cluster_log_types = []

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]

  tags = local.tags

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

resource "aws_iam_role" "eks_node" {
  name               = "${local.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
  tags               = local.tags

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

resource "aws_iam_role_policy_attachment" "ecr_read_only" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = local.node_group_name
  node_role_arn   = aws_iam_role.eks_node.arn
  subnet_ids      = data.aws_subnets.default.ids

  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_types
  disk_size      = var.node_disk_size

  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

  lifecycle {
    prevent_destroy = var.prevent_destroy
    ignore_changes = [scaling_config[0].desired_size]
  }

  depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_read_only
  ]

  tags = local.tags
}

resource "aws_budgets_budget" "monthly" {
  count = var.create_cost_budget ? 1 : 0

  name              = "${local.cluster_name}-monthly-budget"
  budget_type       = "COST"
  limit_amount      = var.monthly_budget_limit_usd
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  time_period_start = "2026-01-01_00:00"

  cost_filter {
    name   = "Service"
    values = ["Amazon Elastic Kubernetes Service", "Amazon Elastic Compute Cloud - Compute"]
  }

  dynamic "notification" {
    for_each = var.budget_alert_email != "" ? [1] : []
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = 80
      threshold_type             = "PERCENTAGE"
      notification_type          = "ACTUAL"
      subscriber_email_addresses = [var.budget_alert_email]
    }
  }

  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
}
