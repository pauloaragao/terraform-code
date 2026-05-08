output "cluster_name" {
  value       = local.cluster_name
  description = "Nome do cluster EKS utilizado"
}

output "metrics_server_status" {
  value       = var.enable_metrics_server ? "instalado" : "desabilitado"
  description = "Status do metrics-server no cluster"
}

output "ingress_nginx_status" {
  value       = var.enable_ingress_nginx ? "instalado" : "desabilitado"
  description = "Status do ingress-nginx no cluster"
}

output "verify_metrics_server" {
  value       = "kubectl top nodes"
  description = "Comando para verificar se o metrics-server esta funcionando"
}

output "verify_ingress" {
  value       = "kubectl get svc -n ingress-nginx"
  description = "Comando para obter o IP/hostname do LoadBalancer do ingress-nginx"
}
