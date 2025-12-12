# Main Outputs File

# Resource Group Outputs
output "hub_resource_group_id" {
  description = "ID of the Hub resource group"
  value       = azurerm_resource_group.hub.id
}

output "spoke_resource_group_id" {
  description = "ID of the Spoke resource group"
  value       = azurerm_resource_group.spoke.id
}

# Network Outputs - Hub
output "hub_vnet_id" {
  description = "ID of the Hub VNet"
  value       = module.hub_network.vnet_id
}

output "hub_vnet_name" {
  description = "Name of the Hub VNet"
  value       = module.hub_network.vnet_name
}

output "hub_subnet_ids" {
  description = "Map of Hub subnet IDs"
  value       = module.hub_network.subnet_ids
  sensitive   = false
}

# Network Outputs - Spoke
output "spoke_vnet_id" {
  description = "ID of the Spoke VNet"
  value       = module.spoke_network.vnet_id
}

output "spoke_vnet_name" {
  description = "Name of the Spoke VNet"
  value       = module.spoke_network.vnet_name
}

output "spoke_subnet_ids" {
  description = "Map of Spoke subnet IDs"
  value       = module.spoke_network.subnet_ids
  sensitive   = false
}

# NAT Gateway Outputs
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = module.hub_network.nat_gateway_id
}

# VPN Gateway Outputs
output "vpn_gateway_id" {
  description = "ID of the VPN Gateway"
  value       = module.hub_network.vpn_gateway_id
}

output "vpn_gateway_public_ip" {
  description = "Public IP of the VPN Gateway"
  value       = module.hub_network.vpn_gateway_public_ip
}

# Virtual Machine Outputs
output "vm_private_ips" {
  description = "Map of VM private IP addresses"
  value       = module.compute.vm_private_ips
}

output "linux_vm_ids" {
  description = "Map of Linux VM IDs"
  value       = module.compute.linux_vm_ids
}

# AKS Outputs
output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = module.aks.aks_id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.aks_name
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks.aks_fqdn
}

output "aks_kube_config" {
  description = "Kube config for the AKS cluster"
  value       = module.aks.aks_kube_config
  sensitive   = true
}

# ACR Outputs
output "acr_id" {
  description = "ID of the Container Registry"
  value       = module.acr.acr_id
}

output "acr_name" {
  description = "Name of the Container Registry"
  value       = module.acr.acr_name
}

output "acr_login_server" {
  description = "Login server of the Container Registry"
  value       = module.acr.acr_login_server
}

output "acr_admin_username" {
  description = "Admin username of the Container Registry"
  value       = module.acr.acr_admin_username
  sensitive   = true
}

output "acr_admin_password" {
  description = "Admin password of the Container Registry"
  value       = module.acr.acr_admin_password
  sensitive   = true
}

# Database Outputs - PostgreSQL
output "postgresql_server_id" {
  description = "ID of the PostgreSQL server"
  value       = module.postgresql.postgresql_server_id
}

output "postgresql_fqdn" {
  description = "FQDN of the PostgreSQL server"
  value       = module.postgresql.postgresql_fqdn
}

# Redis Cache Outputs
output "redis_id" {
  description = "ID of the Redis Cache"
  value       = module.redis.redis_id
}

output "redis_hostname" {
  description = "Hostname of the Redis Cache"
  value       = module.redis.redis_hostname
}

output "redis_ssl_port" {
  description = "SSL port of the Redis Cache"
  value       = module.redis.redis_ssl_port
}

output "redis_primary_key" {
  description = "Primary access key for Redis Cache"
  value       = module.redis.redis_primary_key
  sensitive   = true
}

output "redis_primary_connection_string" {
  description = "Primary connection string for Redis Cache"
  value       = module.redis.redis_primary_connection_string
  sensitive   = true
}
