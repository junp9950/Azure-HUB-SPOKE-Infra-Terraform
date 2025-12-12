# Container Module - Main Configuration

# Container Registry
resource "azurerm_container_registry" "main" {
  count = var.registry_name != null ? 1 : 0

  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.acr_sku
  admin_enabled       = var.acr_admin_enabled

  public_network_access_enabled = var.acr_public_network_access_enabled
  zone_redundancy_enabled       = var.acr_zone_redundancy_enabled

  dynamic "georeplications" {
    for_each = var.acr_georeplications
    content {
      location                = georeplications.value.location
      tags                    = georeplications.value.tags
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
    }
  }

  dynamic "retention_policy" {
    for_each = var.acr_retention_policy != null ? [var.acr_retention_policy] : []
    content {
      days    = retention_policy.value.days
      enabled = retention_policy.value.enabled
    }
  }

  tags = var.tags
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "main" {
  count = var.cluster_name != null ? 1 : 0

  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix != null ? var.dns_prefix : var.cluster_name
  kubernetes_version  = var.kubernetes_version

  private_cluster_enabled = var.enable_private_cluster
  private_dns_zone_id    = var.private_dns_zone_id

  default_node_pool {
    name                = var.default_node_pool.name
    node_count          = var.default_node_pool.node_count
    vm_size             = var.default_node_pool.vm_size
    vnet_subnet_id      = var.subnet_id
    zones               = var.default_node_pool.availability_zones
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count          = var.default_node_pool.min_count
    max_count          = var.default_node_pool.max_count
    max_pods           = var.default_node_pool.max_pods
    os_disk_size_gb    = var.default_node_pool.os_disk_size_gb
    os_disk_type       = var.default_node_pool.os_disk_type
    type               = var.default_node_pool.type

    node_labels = var.default_node_pool.node_labels
    node_taints = var.default_node_pool.node_taints
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = var.network_policy
    load_balancer_sku  = var.load_balancer_sku
    service_cidr       = var.service_cidr
    dns_service_ip     = var.dns_service_ip
    outbound_type      = var.outbound_type
  }

  azure_policy_enabled = var.enable_azure_policy

  dynamic "ingress_application_gateway" {
    for_each = var.enable_ingress_application_gateway ? [1] : []
    content {
      gateway_id   = var.application_gateway_id
      gateway_name = var.application_gateway_name
      subnet_id    = var.application_gateway_subnet_id
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.enable_keyvault_secrets_provider ? [1] : []
    content {
      secret_rotation_enabled  = var.secret_rotation_enabled
      secret_rotation_interval = var.secret_rotation_interval
    }
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? [var.auto_scaler_profile] : []
    content {
      balance_similar_node_groups      = auto_scaler_profile.value.balance_similar_node_groups
      expander                         = auto_scaler_profile.value.expander
      max_graceful_termination_sec     = auto_scaler_profile.value.max_graceful_termination_sec
      max_node_provisioning_time       = auto_scaler_profile.value.max_node_provisioning_time
      max_unready_nodes                = auto_scaler_profile.value.max_unready_nodes
      max_unready_percentage           = auto_scaler_profile.value.max_unready_percentage
      new_pod_scale_up_delay           = auto_scaler_profile.value.new_pod_scale_up_delay
      scan_interval                    = auto_scaler_profile.value.scan_interval
      scale_down_delay_after_add       = auto_scaler_profile.value.scale_down_delay_after_add
      scale_down_delay_after_delete    = auto_scaler_profile.value.scale_down_delay_after_delete
      scale_down_delay_after_failure   = auto_scaler_profile.value.scale_down_delay_after_failure
      scale_down_unneeded              = auto_scaler_profile.value.scale_down_unneeded
      scale_down_unready               = auto_scaler_profile.value.scale_down_unready
      scale_down_utilization_threshold = auto_scaler_profile.value.scale_down_utilization_threshold
      skip_nodes_with_local_storage    = auto_scaler_profile.value.skip_nodes_with_local_storage
      skip_nodes_with_system_pods      = auto_scaler_profile.value.skip_nodes_with_system_pods
    }
  }

  role_based_access_control_enabled = var.enable_rbac

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_azure_ad ? [1] : []
    content {
      managed                = true
      admin_group_object_ids = var.admin_group_object_ids
      azure_rbac_enabled     = var.azure_rbac_enabled
    }
  }

  tags = var.tags
}

# Additional Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each = var.additional_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main[0].id
  vm_size              = each.value.vm_size
  node_count           = each.value.node_count
  vnet_subnet_id       = var.subnet_id
  zones                = each.value.availability_zones
  enable_auto_scaling  = each.value.enable_auto_scaling
  min_count           = each.value.min_count
  max_count           = each.value.max_count
  max_pods            = each.value.max_pods
  os_disk_size_gb     = each.value.os_disk_size_gb
  os_type             = each.value.os_type
  priority            = each.value.priority
  spot_max_price      = each.value.spot_max_price
  eviction_policy     = each.value.eviction_policy

  node_labels = each.value.node_labels
  node_taints = each.value.node_taints

  tags = var.tags
}

# Private Endpoints for ACR
resource "azurerm_private_endpoint" "acr" {
  count = var.registry_name != null && var.enable_private_endpoint ? 1 : 0

  name                = "${var.registry_name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.registry_name}-pe-connection"
    private_connection_resource_id = azurerm_container_registry.main[0].id
    subresource_names             = ["registry"]
    is_manual_connection          = false
  }

  private_dns_zone_group {
    name                 = "${var.registry_name}-pe-dns-zone-group"
    private_dns_zone_ids = var.private_dns_zone_ids
  }

  tags = var.tags
}

# ACR Scope Maps
resource "azurerm_container_registry_scope_map" "main" {
  for_each = var.acr_scope_maps

  name                    = each.key
  container_registry_name = azurerm_container_registry.main[0].name
  resource_group_name     = var.resource_group_name
  actions                 = each.value.actions
}

# ACR Tokens
resource "azurerm_container_registry_token" "main" {
  for_each = var.acr_tokens

  name                    = each.key
  container_registry_name = azurerm_container_registry.main[0].name
  resource_group_name     = var.resource_group_name
  scope_map_id           = azurerm_container_registry_scope_map.main[each.value.scope_map_name].id
}
