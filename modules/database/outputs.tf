# Database Module - Outputs

output "postgresql_server_id" {
  description = "PostgreSQL server ID"
  value       = length(azurerm_postgresql_flexible_server.main) > 0 ? azurerm_postgresql_flexible_server.main[0].id : null
}

output "postgresql_fqdn" {
  description = "PostgreSQL server FQDN"
  value       = length(azurerm_postgresql_flexible_server.main) > 0 ? azurerm_postgresql_flexible_server.main[0].fqdn : null
}

output "redis_id" {
  description = "Redis Cache ID"
  value       = length(azurerm_redis_cache.main) > 0 ? azurerm_redis_cache.main[0].id : null
}

output "redis_hostname" {
  description = "Redis Cache hostname"
  value       = length(azurerm_redis_cache.main) > 0 ? azurerm_redis_cache.main[0].hostname : null
}

output "redis_ssl_port" {
  description = "Redis Cache SSL port"
  value       = length(azurerm_redis_cache.main) > 0 ? azurerm_redis_cache.main[0].ssl_port : null
}

output "redis_primary_key" {
  description = "Redis Cache primary access key"
  value       = length(azurerm_redis_cache.main) > 0 ? azurerm_redis_cache.main[0].primary_access_key : null
  sensitive   = true
}

output "redis_primary_connection_string" {
  description = "Redis primary connection string"
  value       = length(azurerm_redis_cache.main) > 0 ? azurerm_redis_cache.main[0].primary_connection_string : null
  sensitive   = true
}
