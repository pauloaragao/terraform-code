# Sufixo do workspace garante isolamento entre DEV / HK / PROD
locals {
  workspace_suffix = lower(terraform.workspace)
  cluster_name     = "${var.cluster_name}-${local.workspace_suffix}"
}

# Guard de protecao contra destroy acidental (optional)
resource "terraform_data" "destroy_guard" {
  count = var.prevent_destroy ? 1 : 0
  input = {
    module    = "helm"
    workspace = terraform.workspace
  }

  lifecycle {
    prevent_destroy = true
  }
}

# -----------------------------------------------------------------------------
# metrics-server
# Necessario para: kubectl top nodes/pods e Horizontal Pod Autoscaler (HPA)
# -----------------------------------------------------------------------------
resource "helm_release" "metrics_server" {
  count      = var.enable_metrics_server ? 1 : 0
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = var.metrics_server_version
  namespace  = "kube-system"

  # Necessario em clusters EKS onde os nos nao tem certificado valido via kubelet
  set {
    name  = "args[0]"
    value = "--kubelet-insecure-tls"
  }
}

# -----------------------------------------------------------------------------
# ingress-nginx
# IngressClass padrao que cria um AWS Network Load Balancer automaticamente
# -----------------------------------------------------------------------------
resource "helm_release" "ingress_nginx" {
  count            = var.enable_ingress_nginx ? 1 : 0
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = var.ingress_nginx_version
  namespace        = "ingress-nginx"
  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  # Torna este IngressClass o padrao para recursos Ingress sem annotation explicita
  set {
    name  = "controller.ingressClassResource.default"
    value = "true"
  }
}

