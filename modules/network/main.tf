# Network Module - Main Configuration

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space

  tags = var.tags
}

# Subnets
resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [each.value.address_prefix]

  service_endpoints = lookup(each.value, "service_endpoints", [])

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = delegation.value.service_delegation.actions
      }
    }
  }
}

resource "azurerm_public_ip" "nat_gateway" {
  count = var.enable_nat_gateway ? 1 : 0

  name                = "${var.nat_gateway_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                = "Standard"
  zones              = var.availability_zones

  tags = var.tags
}

resource "azurerm_public_ip" "vpn_gateway" {
  count = var.enable_vpn_gateway ? 1 : 0

  name                = "${var.vpn_gateway_name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                = "Standard"

  tags = var.tags
}

# Azure Firewall Policy
# NAT Gateway
resource "azurerm_nat_gateway" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  name                    = var.nat_gateway_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name               = "Standard"
  idle_timeout_in_minutes = 10
  zones                  = var.availability_zones

  tags = var.tags
}

# Associate Public IP with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "main" {
  count = var.enable_nat_gateway ? 1 : 0

  nat_gateway_id       = azurerm_nat_gateway.main[0].id
  public_ip_address_id = azurerm_public_ip.nat_gateway[0].id
}

# Associate NAT Gateway with Subnets
resource "azurerm_subnet_nat_gateway_association" "main" {
  for_each = var.enable_nat_gateway ? var.nat_gateway_subnet_associations : {}

  subnet_id      = azurerm_subnet.subnets[each.value].id
  nat_gateway_id = azurerm_nat_gateway.main[0].id
}

# VPN Gateway
resource "azurerm_virtual_network_gateway" "main" {
  count = var.enable_vpn_gateway ? 1 : 0

  name                = var.vpn_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = var.enable_bgp
  sku          = var.vpn_gateway_sku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnets["GatewaySubnet"].id
  }

  dynamic "bgp_settings" {
    for_each = var.enable_bgp ? [1] : []
    content {
      asn = var.bgp_asn
    }
  }

  tags = var.tags
}

# Route Tables
resource "azurerm_route_table" "main" {
  for_each = var.route_tables

  name                          = each.key
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = lookup(each.value, "disable_bgp_route_propagation", false)

  tags = var.tags
}

# Routes
resource "azurerm_route" "main" {
  for_each = { for route in flatten([
    for rt_name, rt_config in var.route_tables : [
      for route_name, route_config in lookup(rt_config, "routes", {}) : {
        key                    = "${rt_name}-${route_name}"
        route_table_name      = rt_name
        name                  = route_name
        address_prefix        = route_config.address_prefix
        next_hop_type        = route_config.next_hop_type
        next_hop_in_ip_address = lookup(route_config, "next_hop_in_ip_address", null)
      }
    ]
  ]) : route.key => route }

  name                   = each.value.name
  resource_group_name    = var.resource_group_name
  route_table_name      = azurerm_route_table.main[each.value.route_table_name].name
  address_prefix        = each.value.address_prefix
  next_hop_type         = each.value.next_hop_type
  next_hop_in_ip_address = each.value.next_hop_in_ip_address
}

# Associate Route Tables with Subnets
resource "azurerm_subnet_route_table_association" "main" {
  for_each = var.route_table_associations

  subnet_id      = azurerm_subnet.subnets[each.value.subnet_name].id
  route_table_id = azurerm_route_table.main[each.value.route_table_name].id
}

# Private DNS Zones
resource "azurerm_private_dns_zone" "main" {
  for_each = toset(var.private_dns_zones)

  name                = each.key
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Link Private DNS Zones to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "main" {
  for_each = toset(var.private_dns_zones)

  name                  = "${azurerm_virtual_network.main.name}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.main[each.key].name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false

  tags = var.tags
}
