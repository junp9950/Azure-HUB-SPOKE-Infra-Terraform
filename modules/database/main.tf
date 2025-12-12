# Database Module - Main Configuration

# PostgreSQL Flexible Server
resource "azurerm_postgresql_flexible_server" "main" {
  count = var.server_name != null ? 1 : 0

  name                = var.server_name
  resource_group_name = var.resource_group_name
  location            = var.location

  administrator_login    = var.administrator_login
  administrator_password = var.administrator_password

  sku_name   = var.sku_name
  storage_mb = var.storage_mb
  version    = var.postgresql_version

  backup_retention_days        = var.backup_retention_days
  geo_redundant_backup_enabled = var.geo_redundant_backup_enabled
  zone                         = var.availability_zone

  dynamic "high_availability" {
    for_each = var.enable_ha ? [1] : []
    content {
      mode                      = "ZoneRedundant"
      standby_availability_zone = var.standby_availability_zone
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [var.maintenance_window] : []
    content {
      day_of_week  = maintenance_window.value.day_of_week
      start_hour   = maintenance_window.value.start_hour
      start_minute = maintenance_window.value.start_minute
    }
  }

  tags = var.tags
}

# PostgreSQL Databases
resource "azurerm_postgresql_flexible_server_database" "main" {
  for_each = var.postgresql_databases

  name      = each.key
  server_id = azurerm_postgresql_flexible_server.main[0].id
  charset   = each.value.charset
  collation = each.value.collation
}

# PostgreSQL Firewall Rules
resource "azurerm_postgresql_flexible_server_firewall_rule" "main" {
  for_each = var.postgresql_firewall_rules

  name             = each.key
  server_id        = azurerm_postgresql_flexible_server.main[0].id
  start_ip_address = each.value.start_ip_address
  end_ip_address   = each.value.end_ip_address
}

# Redis Cache
resource "azurerm_redis_cache" "main" {
  count = var.redis_name != null ? 1 : 0

  name                = var.redis_name
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.redis_capacity
  family              = var.redis_family
  sku_name            = var.redis_sku
  enable_non_ssl_port = var.redis_enable_non_ssl_port
  minimum_tls_version = var.redis_minimum_tls_version

  redis_configuration {
    maxmemory_reserved              = var.redis_maxmemory_reserved
    maxmemory_delta                 = var.redis_maxmemory_delta
    maxmemory_policy                = var.redis_maxmemory_policy
    notify_keyspace_events          = var.redis_notify_keyspace_events
    enable_authentication           = var.redis_enable_authentication
  }

  public_network_access_enabled = var.redis_public_network_access_enabled
  zones                         = var.redis_zones

  dynamic "patch_schedule" {
    for_each = var.redis_patch_schedule
    content {
      day_of_week    = patch_schedule.value.day_of_week
      start_hour_utc = patch_schedule.value.start_hour_utc
    }
  }

  tags = var.tags
}

# MongoDB Cluster (Azure Cosmos DB for MongoDB vCore)
resource "azurerm_cosmosdb_account" "mongodb" {
  count = var.mongo_cluster_name != null ? 1 : 0

  name                = var.mongo_cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = "Standard"
  kind                = "MongoDB"

  capabilities {
    name = "EnableMongo"
  }

  capabilities {
    name = "MongoDBv3.4"
  }

  capabilities {
    name = "EnableServerless"
  }

  consistency_policy {
    consistency_level       = var.mongodb_consistency_level
    max_interval_in_seconds = var.mongodb_max_interval_in_seconds
    max_staleness_prefix    = var.mongodb_max_staleness_prefix
  }

  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = var.mongodb_zone_redundant
  }

  dynamic "geo_location" {
    for_each = var.mongodb_additional_geo_locations
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = geo_location.value.zone_redundant
    }
  }

  enable_automatic_failover       = var.mongodb_enable_automatic_failover
  enable_free_tier                = false
  public_network_access_enabled   = var.mongodb_public_network_access_enabled
  is_virtual_network_filter_enabled = var.mongodb_is_virtual_network_filter_enabled

  dynamic "virtual_network_rule" {
    for_each = var.mongodb_virtual_network_rules
    content {
      id                                   = virtual_network_rule.value.subnet_id
      ignore_missing_vnet_service_endpoint = virtual_network_rule.value.ignore_missing_vnet_service_endpoint
    }
  }

  tags = var.tags
}

# Private Endpoints for PostgreSQL
resource "azurerm_private_endpoint" "postgresql" {
  count = var.server_name != null && var.enable_private_endpoint && length(var.private_dns_zone_ids) > 0 ? 1 : 0

  name                = "${var.server_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.server_name}-pe-connection"
    private_connection_resource_id = azurerm_postgresql_flexible_server.main[0].id
    subresource_names             = ["postgresqlServer"]
    is_manual_connection          = false
  }

  private_dns_zone_group {
    name                 = "${var.server_name}-pe-dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

# Private Endpoints for Redis
resource "azurerm_private_endpoint" "redis" {
  count = var.redis_name != null && var.enable_private_endpoint && length(var.private_dns_zone_ids) > 0 ? 1 : 0

  name                = "${var.redis_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.redis_name}-pe-connection"
    private_connection_resource_id = azurerm_redis_cache.main[0].id
    subresource_names             = ["redisCache"]
    is_manual_connection          = false
  }

  private_dns_zone_group {
    name                 = "${var.redis_name}-pe-dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

# Private Endpoints for MongoDB
resource "azurerm_private_endpoint" "mongodb" {
  count = var.mongo_cluster_name != null && var.enable_private_endpoint ? 1 : 0

  name                = "${var.mongo_cluster_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.mongo_cluster_name}-pe-connection"
    private_connection_resource_id = azurerm_cosmosdb_account.mongodb[0].id
    subresource_names             = ["MongoDB"]
    is_manual_connection          = false
  }

  private_dns_zone_group {
    name                 = "${var.mongo_cluster_name}-pe-dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}
