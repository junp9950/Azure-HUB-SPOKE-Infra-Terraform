# Platform Infrastructure - Main Configuration
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }

  # Backend configuration for state management
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstate"
  #   container_name      = "tfstate"
  #   key                 = "platform.terraform.tfstate"
  # }
}

# Configure Azure Provider
provider "azurerm" {
  skip_provider_registration = true

  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}

# Local values for resource naming
locals {
  prefix_upper = upper(var.project_prefix)
  prefix_lower = lower(var.project_prefix)

  # Resource naming convention:
  # - Upper level (RG, VNet): UPPERCASE (PREFIX-HUB-RG, PREFIX-SPOKE-VNET)
  # - Lower level (Subnet and below): lowercase (prefix-hub-nat, prefix-spoke-aks)

  # Upper level resources (RG, VNet)
  hub_rg_name     = coalesce(var.hub_resource_group_name, "${local.prefix_upper}-HUB-RG")
  spoke_rg_name   = coalesce(var.spoke_resource_group_name, "${local.prefix_upper}-SPOKE-RG")
  hub_vnet_name   = coalesce(var.hub_vnet_name, "${local.prefix_upper}-HUB-VNET")
  spoke_vnet_name = coalesce(var.spoke_vnet_name, "${local.prefix_upper}-SPOKE-VNET")

  # Lower level resources (Subnet and below)
  nat_gw_name  = coalesce(var.nat_gateway_name, "${local.prefix_lower}-hub-nat")
  vpn_gw_name  = coalesce(var.vpn_gateway_name, "${local.prefix_lower}-hub-vgw")
  aks_name     = coalesce(var.aks_cluster_name, "${local.prefix_lower}-spoke-aks")
  acr_name     = coalesce(var.acr_name, replace("${local.prefix_lower}spokeacr", "-", ""))
  psql_name    = coalesce(var.postgresql_server_name, "${local.prefix_lower}-spoke-postgresql")
  redis_name   = coalesce(var.redis_cache_name, "${local.prefix_lower}-spoke-redis")
}

# Resource Groups
resource "azurerm_resource_group" "hub" {
  name     = local.hub_rg_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "spoke" {
  name     = local.spoke_rg_name
  location = var.location
  tags     = var.tags
}

# Network Module - Hub
module "hub_network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.hub.name
  location           = var.location

  vnet_name          = local.hub_vnet_name
  vnet_address_space = var.hub_vnet_address_space

  subnets = var.hub_subnets

  enable_nat_gateway = true
  nat_gateway_name   = local.nat_gw_name

  enable_vpn_gateway = true
  vpn_gateway_name   = local.vpn_gw_name
  vpn_gateway_sku    = var.vpn_gateway_sku

  tags = var.tags
}

# Network Module - Spoke
module "spoke_network" {
  source = "./modules/network"

  resource_group_name = azurerm_resource_group.spoke.name
  location           = var.location

  vnet_name          = local.spoke_vnet_name
  vnet_address_space = var.spoke_vnet_address_space

  subnets = var.spoke_subnets

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.tags
}

# Virtual Network Peering
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "${local.hub_vnet_name}-to-${local.spoke_vnet_name}"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = module.hub_network.vnet_name
  remote_virtual_network_id = module.spoke_network.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways         = false
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "${local.spoke_vnet_name}-to-${local.hub_vnet_name}"
  resource_group_name       = azurerm_resource_group.spoke.name
  virtual_network_name      = module.spoke_network.vnet_name
  remote_virtual_network_id = module.hub_network.vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways         = true

  depends_on = [module.hub_network.vpn_gateway_id]
}

# Security Module
module "security" {
  source = "./modules/security"

  resource_group_name = azurerm_resource_group.spoke.name
  location           = var.location

  network_security_groups = var.network_security_groups

  tags = var.tags
}

# Compute Module - Virtual Machines
module "compute" {
  source = "./modules/compute"

  resource_group_name = azurerm_resource_group.spoke.name
  location           = var.location

  vms = var.virtual_machines

  subnet_ids = module.spoke_network.subnet_ids

  tags = var.tags
}

# Container Module - AKS
module "aks" {
  source = "./modules/container"

  resource_group_name = azurerm_resource_group.spoke.name
  location           = var.location

  cluster_name       = local.aks_name
  kubernetes_version = var.kubernetes_version

  default_node_pool = var.aks_default_node_pool

  subnet_id = module.spoke_network.subnet_ids["aks-subnet"]

  enable_private_cluster = true

  tags = var.tags
}

# Container Module - ACR
module "acr" {
  source = "./modules/container"

  resource_group_name = azurerm_resource_group.spoke.name
  location           = var.location

  registry_name = local.acr_name
  acr_sku      = var.acr_sku

  enable_private_endpoint = true
  subnet_id              = module.spoke_network.subnet_ids["private-endpoint-subnet"]

  tags = var.tags
}

# Database Module - PostgreSQL
module "postgresql" {
  source = "./modules/database"

  resource_group_name = azurerm_resource_group.spoke.name
  location           = var.location

  server_name = local.psql_name

  administrator_login    = var.postgresql_admin_username
  administrator_password = var.postgresql_admin_password

  sku_name   = var.postgresql_sku
  storage_mb = var.postgresql_storage_mb
  postgresql_version = var.postgresql_version

  enable_private_endpoint = true
  subnet_id              = module.spoke_network.subnet_ids["private-endpoint-subnet"]

  tags = var.tags
}

# Database Module - Redis Cache
module "redis" {
  source = "./modules/database"

  resource_group_name = azurerm_resource_group.spoke.name
  location           = var.location

  redis_name = local.redis_name

  redis_capacity = var.redis_capacity
  redis_family   = var.redis_family
  redis_sku = var.redis_sku

  redis_enable_non_ssl_port = false
  redis_minimum_tls_version = "1.2"

  enable_private_endpoint = true
  subnet_id              = module.spoke_network.subnet_ids["private-endpoint-subnet"]

  tags = var.tags
}

# Monitoring Module
