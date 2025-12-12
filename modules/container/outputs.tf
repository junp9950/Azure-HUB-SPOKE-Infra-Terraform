# Container Module - Outputs

# ACR Outputs
output "acr_id" {
  description = "Container Registry ID"
  value       = try(azurerm_container_registry.main[0].id, null)
}

output "acr_name" {
  description = "Container Registry name"
  value       = try(azurerm_container_registry.main[0].name, null)
}

output "acr_login_server" {
  description = "Container Registry login server"
  value       = try(azurerm_container_registry.main[0].login_server, null)
}

output "acr_admin_username" {
  description = "Container Registry admin username"
  value       = try(azurerm_container_registry.main[0].admin_username, null)
  sensitive   = true
}

output "acr_admin_password" {
  description = "Container Registry admin password"
  value       = try(azurerm_container_registry.main[0].admin_password, null)
  sensitive   = true
}

# AKS Outputs
output "aks_id" {
  description = "AKS cluster ID"
  value       = try(azurerm_kubernetes_cluster.main[0].id, null)
}

output "aks_name" {
  description = "AKS cluster name"
  value       = try(azurerm_kubernetes_cluster.main[0].name, null)
}

output "aks_fqdn" {
  description = "AKS cluster FQDN"
  value       = try(azurerm_kubernetes_cluster.main[0].fqdn, null)
}

output "aks_kube_config" {
  description = "AKS kubeconfig"
  value       = try(azurerm_kubernetes_cluster.main[0].kube_config[0], null)
  sensitive   = true
}

output "aks_kubelet_identity" {
  description = "AKS kubelet identity"
  value       = try(azurerm_kubernetes_cluster.main[0].kubelet_identity[0], null)
}

output "aks_node_resource_group" {
  description = "AKS node resource group name"
  value       = try(azurerm_kubernetes_cluster.main[0].node_resource_group, null)
}
