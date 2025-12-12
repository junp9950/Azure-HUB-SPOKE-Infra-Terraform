# Security Module - Outputs

output "nsg_ids" {
  description = "Map of Network Security Group IDs"
  value       = { for k, v in azurerm_network_security_group.main : k => v.id }
}

output "nsg_names" {
  description = "Map of Network Security Group names"
  value       = { for k, v in azurerm_network_security_group.main : k => v.name }
}
