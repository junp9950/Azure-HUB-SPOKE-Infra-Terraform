# Container Module - Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

# ACR Variables
variable "registry_name" {
  description = "Container Registry name (set to null to skip)"
  type        = string
  default     = null
}

variable "acr_sku" {
  description = "SKU of the Container Registry"
  type        = string
  default     = "Premium"
}

variable "acr_admin_enabled" {
  description = "Enable admin user for ACR"
  type        = bool
  default     = false
}

variable "acr_public_network_access_enabled" {
  description = "Enable public network access for ACR"
  type        = bool
  default     = false
}

variable "acr_zone_redundancy_enabled" {
  description = "Enable zone redundancy for ACR"
  type        = bool
  default     = true
}

variable "acr_georeplications" {
  description = "ACR geo-replication configurations"
  type = list(object({
    location                = string
    tags                    = map(string)
    zone_redundancy_enabled = bool
  }))
  default = []
}

variable "acr_retention_policy" {
  description = "ACR retention policy"
  type = object({
    days    = number
    enabled = bool
  })
  default = null
}

variable "acr_scope_maps" {
  description = "ACR scope maps"
  type = map(object({
    actions = list(string)
  }))
  default = {}
}

variable "acr_tokens" {
  description = "ACR tokens"
  type = map(object({
    scope_map_name = string
  }))
  default = {}
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for ACR"
  type        = bool
  default     = false
}

variable "private_dns_zone_ids" {
  description = "Private DNS zone IDs for ACR private endpoint"
  type        = list(string)
  default     = []
}

# AKS Variables
variable "cluster_name" {
  description = "AKS cluster name (set to null to skip)"
  type        = string
  default     = null
}

variable "dns_prefix" {
  description = "DNS prefix for AKS cluster"
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.9"
}

variable "enable_private_cluster" {
  description = "Enable private cluster for AKS"
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "Private DNS zone ID for AKS private cluster"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID for AKS nodes"
  type        = string
  default     = null
}

variable "default_node_pool" {
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
  default = null
}

variable "network_plugin" {
  description = "Network plugin for AKS"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy for AKS"
  type        = string
  default     = "azure"
}

variable "load_balancer_sku" {
  description = "Load balancer SKU for AKS"
  type        = string
  default     = "standard"
}

variable "service_cidr" {
  description = "Service CIDR for AKS"
  type        = string
  default     = "10.0.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP for AKS"
  type        = string
  default     = "10.0.0.10"
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR for AKS"
  type        = string
  default     = "172.17.0.1/16"
}

variable "outbound_type" {
  description = "Outbound type for AKS"
  type        = string
  default     = "loadBalancer"
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy addon for AKS"
  type        = bool
  default     = false
}

variable "enable_ingress_application_gateway" {
  description = "Enable Application Gateway Ingress Controller"
  type        = bool
  default     = false
}

variable "application_gateway_id" {
  description = "Application Gateway ID for AGIC"
  type        = string
  default     = null
}

variable "application_gateway_name" {
  description = "Application Gateway name for AGIC"
  type        = string
  default     = null
}

variable "application_gateway_subnet_id" {
  description = "Application Gateway subnet ID for AGIC"
  type        = string
  default     = null
}

variable "enable_keyvault_secrets_provider" {
  description = "Enable Key Vault secrets provider"
  type        = bool
  default     = false
}

variable "secret_rotation_enabled" {
  description = "Enable secret rotation"
  type        = bool
  default     = false
}

variable "secret_rotation_interval" {
  description = "Secret rotation interval"
  type        = string
  default     = "2m"
}

variable "auto_scaler_profile" {
  description = "Auto scaler profile configuration"
  type = object({
    balance_similar_node_groups      = optional(bool)
    expander                         = optional(string)
    max_graceful_termination_sec     = optional(number)
    max_node_provisioning_time       = optional(string)
    max_unready_nodes                = optional(number)
    max_unready_percentage           = optional(number)
    new_pod_scale_up_delay           = optional(string)
    scan_interval                    = optional(string)
    scale_down_delay_after_add       = optional(string)
    scale_down_delay_after_delete    = optional(string)
    scale_down_delay_after_failure   = optional(string)
    scale_down_unneeded              = optional(string)
    scale_down_unready               = optional(string)
    scale_down_utilization_threshold = optional(number)
    skip_nodes_with_local_storage    = optional(bool)
    skip_nodes_with_system_pods      = optional(bool)
  })
  default = null
}

variable "enable_rbac" {
  description = "Enable RBAC for AKS"
  type        = bool
  default     = true
}

variable "enable_azure_ad" {
  description = "Enable Azure AD integration for AKS"
  type        = bool
  default     = false
}

variable "admin_group_object_ids" {
  description = "Azure AD admin group object IDs"
  type        = list(string)
  default     = []
}

variable "azure_rbac_enabled" {
  description = "Enable Azure RBAC for Kubernetes authorization"
  type        = bool
  default     = false
}

variable "additional_node_pools" {
  description = "Additional node pools for AKS"
  type = map(object({
    vm_size            = string
    node_count         = number
    availability_zones = list(string)
    enable_auto_scaling = bool
    min_count          = number
    max_count          = number
    max_pods           = number
    os_disk_size_gb    = number
    os_type            = string
    priority           = string
    spot_max_price     = number
    eviction_policy    = string
    node_labels        = map(string)
    node_taints        = list(string)
  }))
  default = {}
}
