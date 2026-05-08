variable "aws_region" {
  description = "AWS region do cluster EKS"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Nome base do cluster EKS (sufixo do workspace e adicionado automaticamente)"
  type        = string
  default     = "eks-lab-min"
}

# --- Charts ---

variable "enable_metrics_server" {
  description = "Instala o metrics-server (necessario para HPA e kubectl top)"
  type        = bool
  default     = true
}

variable "enable_ingress_nginx" {
  description = "Instala o ingress-nginx como IngressClass padrao com LoadBalancer"
  type        = bool
  default     = true
}

variable "metrics_server_version" {
  description = "Versao do chart metrics-server (https://github.com/kubernetes-sigs/metrics-server)"
  type        = string
  default     = "3.12.2"
}

variable "ingress_nginx_version" {
  description = "Versao do chart ingress-nginx (https://github.com/kubernetes/ingress-nginx)"
  type        = string
  default     = "4.10.1"
}

# --- Protecao ---

variable "prevent_destroy" {
  description = "Impede destroy acidental dos recursos do modulo quando true"
  type        = bool
  default     = false
}
