# Main Variables File

# General Variables
variable "project_prefix" {
  description = "Prefix for all resource names (e.g., myproject, dev, prod)"
  type        = string
  default     = "myproject"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "Korea Central"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "Production"
    Project     = "PLATFORM"
    ManagedBy   = "Terraform"
    Owner       = "Platform Team"
  }
}

# Resource Group Variables
variable "hub_resource_group_name" {
  description = "Name of the Hub resource group"
  type        = string
  default     = null
}

variable "spoke_resource_group_name" {
  description = "Name of the Spoke resource group"
  type        = string
  default     = null
}

# Hub Network Variables
variable "hub_vnet_name" {
  description = "Name of the Hub VNet"
  type        = string
  default     = null
}

variable "hub_vnet_address_space" {
  description = "Address space for Hub VNet"
  type        = list(string)
  default     = ["10.220.0.0/16"]
}

variable "hub_subnets" {
  description = "Subnets for Hub VNet"
  type = map(object({
    address_prefix    = string
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
  default = {
    "GatewaySubnet" = {
      address_prefix = "10.220.1.0/24"
    }
    "jumpbox-subnet" = {
      address_prefix    = "10.220.10.0/24"
      service_endpoints = ["Microsoft.KeyVault"]
    }
  }
}

# Spoke Network Variables
variable "spoke_vnet_name" {
  description = "Name of the Spoke VNet"
  type        = string
  default     = null
}

variable "spoke_vnet_address_space" {
  description = "Address space for Spoke VNet"
  type        = list(string)
  default     = ["10.221.0.0/16"]
}

variable "spoke_subnets" {
  description = "Subnets for Spoke VNet"
  type = map(object({
    address_prefix    = string
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
  default = {
    "app-subnet" = {
      address_prefix    = "10.221.0.0/24"
      service_endpoints = ["Microsoft.Sql", "Microsoft.KeyVault"]
    }
    "aks-subnet" = {
      address_prefix    = "10.221.2.0/22"
      service_endpoints = ["Microsoft.Sql", "Microsoft.ContainerRegistry"]
    }
    "private-endpoint-subnet" = {
      address_prefix    = "10.221.6.0/24"
      service_endpoints = []
    }
    "database-subnet" = {
      address_prefix    = "10.221.7.0/24"
      service_endpoints = ["Microsoft.Sql"]
      delegation = {
        name = "postgresql-delegation"
        service_delegation = {
          name = "Microsoft.DBforPostgreSQL/flexibleServers"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action"
          ]
        }
      }
    }
  }
}

# NAT Gateway Variables
variable "nat_gateway_name" {
  description = "Name of the NAT Gateway"
  type        = string
  default     = null
}

# VPN Gateway Variables
variable "vpn_gateway_name" {
  description = "Name of the VPN Gateway"
  type        = string
  default     = null
}

variable "vpn_gateway_sku" {
  description = "SKU of the VPN Gateway"
  type        = string
  default     = "VpnGw2"
}

# NSG Variables
variable "network_security_groups" {
  description = "Network Security Groups configuration"
  type = map(object({
    rules = optional(map(object({
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_range           = optional(string)
      source_port_ranges          = optional(list(string))
      destination_port_range      = optional(string)
      destination_port_ranges     = optional(list(string))
      source_address_prefix       = optional(string)
      source_address_prefixes     = optional(list(string))
      destination_address_prefix  = optional(string)
      destination_address_prefixes = optional(list(string))
      description                 = optional(string)
    })), {})
  }))
  default = {
    "app-nsg" = {
      rules = {
        "AllowSSH" = {
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range         = "*"
          destination_port_range    = "22"
          source_address_prefix     = "10.220.10.0/24"
          destination_address_prefix = "*"
          description               = "Allow SSH from jumpbox subnet"
        }
        "AllowHTTPS" = {
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range         = "*"
          destination_port_range    = "443"
          source_address_prefix     = "10.221.1.0/24"
          destination_address_prefix = "*"
          description               = "Allow HTTPS from APIM subnet"
        }
      }
    }
  }
}

# Virtual Machine Variables
variable "virtual_machines" {
  description = "Virtual Machines configuration"
  type = map(object({
    os_type                        = string
    size                           = string
    admin_username                 = string
    admin_password                 = optional(string)
    ssh_key_name                   = optional(string)
    subnet_name                    = string
    private_ip_address             = optional(string)
    network_security_group_name    = optional(string)
    enable_accelerated_networking  = optional(bool, false)
    enable_monitoring              = optional(bool, true)
    os_disk_type                   = optional(string, "Premium_LRS")
    os_disk_size_gb               = optional(number)
    source_image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
  }))
  default = {
    "app" = {
      os_type        = "Linux"
      size           = "Standard_D4s_v3"
      admin_username = "azureuser"
      ssh_key_name   = "app_key"
      subnet_name    = "app-subnet"
      network_security_group_name = "app-nsg"
      enable_accelerated_networking = true
      os_disk_size_gb = 128
      source_image = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }
    }
  }
}

# AKS Variables
variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.9"
}

variable "aks_default_node_pool" {
  description = "AKS default node pool configuration"
  type = object({
    name                = string
    node_count          = number
    vm_size             = string
    availability_zones  = list(string)
    enable_auto_scaling = bool
    min_count          = number
    max_count          = number
    max_pods           = number
    os_disk_size_gb    = number
    os_disk_type       = string
    type               = string
    node_labels        = map(string)
    node_taints        = list(string)
  })
  default = {
    name                = "system"
    node_count          = 3
    vm_size             = "Standard_D4s_v3"
    availability_zones  = ["1", "2", "3"]
    enable_auto_scaling = true
    min_count          = 3
    max_count          = 10
    max_pods           = 30
    os_disk_size_gb    = 128
    os_disk_type       = "Managed"
    type               = "VirtualMachineScaleSets"
    node_labels        = {}
    node_taints        = []
  }
}

# ACR Variables
variable "acr_name" {
  description = "Name of the Container Registry"
  type        = string
  default     = null
}

variable "acr_sku" {
  description = "SKU of the Container Registry"
  type        = string
  default     = "Premium"
}

# Database Variables - PostgreSQL
variable "postgresql_server_name" {
  description = "Name of the PostgreSQL server"
  type        = string
  default     = null
}

variable "postgresql_admin_username" {
  description = "Administrator username for PostgreSQL"
  type        = string
  default     = "psqladmin"
  sensitive   = true
}

variable "postgresql_admin_password" {
  description = "Administrator password for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "postgresql_sku" {
  description = "SKU for PostgreSQL Flexible Server"
  type        = string
  default     = "GP_Standard_D4s_v3"
}

variable "postgresql_storage_mb" {
  description = "Storage size in MB for PostgreSQL"
  type        = number
  default     = 32768
}

variable "postgresql_version" {
  description = "PostgreSQL version"
  type        = string
  default     = "14"
}

# Redis Cache Variables
variable "redis_cache_name" {
  description = "Name of the Redis Cache"
  type        = string
  default     = null
}

variable "redis_capacity" {
  description = "Redis Cache capacity"
  type        = number
  default     = 1
}

variable "redis_family" {
  description = "Redis Cache family"
  type        = string
  default     = "P"
}

variable "redis_sku" {
  description = "Redis Cache SKU"
  type        = string
  default     = "Premium"
}
