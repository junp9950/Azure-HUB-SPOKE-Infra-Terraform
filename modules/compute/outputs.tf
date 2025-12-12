# Compute Module - Outputs

output "linux_vm_ids" {
  description = "Map of Linux VM IDs"
  value       = { for k, v in azurerm_linux_virtual_machine.main : k => v.id }
}

output "windows_vm_ids" {
  description = "Map of Windows VM IDs"
  value       = { for k, v in azurerm_windows_virtual_machine.main : k => v.id }
}

output "vm_private_ips" {
  description = "Map of VM private IP addresses"
  value       = { for k, v in azurerm_network_interface.main : k => v.private_ip_address }
}

output "vm_network_interface_ids" {
  description = "Map of VM network interface IDs"
  value       = { for k, v in azurerm_network_interface.main : k => v.id }
}

output "ssh_key_ids" {
  description = "Map of SSH public key IDs"
  value       = { for k, v in azurerm_ssh_public_key.main : k => v.id }
}

output "managed_disk_ids" {
  description = "Map of managed disk IDs"
  value       = { for k, v in azurerm_managed_disk.main : k => v.id }
}

output "availability_set_ids" {
  description = "Map of availability set IDs"
  value       = { for k, v in azurerm_availability_set.main : k => v.id }
}