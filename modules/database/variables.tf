# Database Module - Variables

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "server_name" {
  description = "PostgreSQL server name (set to null to skip)"
  type        = string
  default     = null
}

variable "administrator_login" {
  description = "PostgreSQL admin login"
  type        = string
  default     = null
}

variable "administrator_password" {
  description = "PostgreSQL admin password"
  type        = string
  default     = null
}

variable "sku_name" {
  description = "PostgreSQL SKU name"
  type        = string
  default     = null
}

variable "storage_mb" {
  description = "PostgreSQL storage size in MB"
  type        = number
  default     = null
}

variable "postgresql_version" {
  description = "PostgreSQL version"
  type        = string
  default     = null
}

variable "backup_retention_days" {
  description = "PostgreSQL backup retention days"
  type        = number
  default     = 7
}

variable "geo_redundant_backup_enabled" {
  description = "Enable geo redundant backup for PostgreSQL"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone for PostgreSQL"
  type        = string
  default     = "1"
}

variable "enable_ha" {
  description = "Enable HA (ZoneRedundant) for PostgreSQL"
  type        = bool
  default     = false
}

variable "standby_availability_zone" {
  description = "Standby AZ when HA is enabled"
  type        = string
  default     = null
}

variable "maintenance_window" {
  description = "PostgreSQL maintenance window"
  type = object({
    day_of_week  = number
    start_hour   = number
    start_minute = number
  })
  default = null
}

variable "postgresql_databases" {
  description = "Additional PostgreSQL databases to create"
  type = map(object({
    charset   = string
    collation = string
  }))
  default = {}
}

variable "postgresql_firewall_rules" {
  description = "PostgreSQL firewall rules"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for PostgreSQL/Redis/Mongo"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID for private endpoints"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs to link for private endpoints"
  type        = list(string)
  default     = []
}

variable "redis_name" {
  description = "Redis Cache name (set to null to skip)"
  type        = string
  default     = null
}

variable "redis_capacity" {
  description = "Redis capacity"
  type        = number
  default     = 1
}

variable "redis_family" {
  description = "Redis family"
  type        = string
  default     = "P"
}

variable "redis_sku" {
  description = "Redis SKU"
  type        = string
  default     = "Premium"
}

variable "redis_enable_non_ssl_port" {
  description = "Enable non-SSL port for Redis"
  type        = bool
  default     = false
}

variable "redis_minimum_tls_version" {
  description = "Minimum TLS version for Redis"
  type        = string
  default     = "1.2"
}

variable "redis_maxmemory_reserved" {
  description = "Redis maxmemory reserved"
  type        = number
  default     = 0
}

variable "redis_maxmemory_delta" {
  description = "Redis maxmemory delta"
  type        = number
  default     = 0
}

variable "redis_maxmemory_policy" {
  description = "Redis maxmemory policy"
  type        = string
  default     = "volatile-lru"
}

variable "redis_notify_keyspace_events" {
  description = "Redis notify keyspace events"
  type        = string
  default     = ""
}

variable "redis_enable_authentication" {
  description = "Enable Redis authentication"
  type        = bool
  default     = true
}

variable "redis_public_network_access_enabled" {
  description = "Enable public network access for Redis"
  type        = bool
  default     = false
}

variable "redis_zones" {
  description = "Availability zones for Redis"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "redis_patch_schedule" {
  description = "Redis patch schedule"
  type = list(object({
    day_of_week    = string
    start_hour_utc = number
  }))
  default = []
}

variable "mongo_cluster_name" {
  description = "Cosmos DB for Mongo cluster name (set to null to skip)"
  type        = string
  default     = null
}

variable "mongodb_consistency_level" {
  description = "MongoDB consistency level"
  type        = string
  default     = "Session"
}

variable "mongodb_max_interval_in_seconds" {
  description = "MongoDB max interval in seconds"
  type        = number
  default     = 5
}

variable "mongodb_max_staleness_prefix" {
  description = "MongoDB max staleness prefix"
  type        = number
  default     = 100
}

variable "mongodb_zone_redundant" {
  description = "Enable MongoDB zone redundancy"
  type        = bool
  default     = false
}

variable "mongodb_additional_geo_locations" {
  description = "Additional MongoDB geo locations"
  type = list(object({
    location          = string
    failover_priority = number
    zone_redundant    = bool
  }))
  default = []
}

variable "mongodb_enable_automatic_failover" {
  description = "Enable MongoDB automatic failover"
  type        = bool
  default     = false
}

variable "mongodb_public_network_access_enabled" {
  description = "Enable MongoDB public network access"
  type        = bool
  default     = false
}

variable "mongodb_is_virtual_network_filter_enabled" {
  description = "Enable VNet filter for MongoDB"
  type        = bool
  default     = false
}

variable "mongodb_virtual_network_rules" {
  description = "MongoDB VNet rules"
  type = list(object({
    subnet_id                           = string
    ignore_missing_vnet_service_endpoint = bool
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
