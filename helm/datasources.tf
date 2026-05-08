# Le os dados do cluster EKS existente para autenticar o provider Helm
data "aws_eks_cluster" "main" {
  name = local.cluster_name
}
