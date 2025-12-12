# Security Module - Main Configuration

# Network Security Groups
resource "azurerm_network_security_group" "main" {
  for_each = var.network_security_groups

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

# Network Security Rules
resource "azurerm_network_security_rule" "main" {
  for_each = { for rule in flatten([
    for nsg_name, nsg_config in var.network_security_groups : [
      for rule_name, rule_config in lookup(nsg_config, "rules", {}) : {
        key                         = "${nsg_name}-${rule_name}"
        nsg_name                   = nsg_name
        name                       = rule_name
        priority                   = rule_config.priority
        direction                  = rule_config.direction
        access                     = rule_config.access
        protocol                   = rule_config.protocol
        source_port_range          = lookup(rule_config, "source_port_range", null)
        source_port_ranges         = lookup(rule_config, "source_port_ranges", null)
        destination_port_range     = lookup(rule_config, "destination_port_range", null)
        destination_port_ranges    = lookup(rule_config, "destination_port_ranges", null)
        source_address_prefix      = lookup(rule_config, "source_address_prefix", null)
        source_address_prefixes    = lookup(rule_config, "source_address_prefixes", null)
        destination_address_prefix = lookup(rule_config, "destination_address_prefix", null)
        destination_address_prefixes = lookup(rule_config, "destination_address_prefixes", null)
        description                = lookup(rule_config, "description", null)
      }
    ]
  ]) : rule.key => rule }

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range           = each.value.source_port_range
  source_port_ranges          = each.value.source_port_ranges
  destination_port_range      = each.value.destination_port_range
  destination_port_ranges     = each.value.destination_port_ranges
  source_address_prefix       = each.value.source_address_prefix
  source_address_prefixes     = each.value.source_address_prefixes
  destination_address_prefix  = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
  description                 = each.value.description
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.main[each.value.nsg_name].name
}

