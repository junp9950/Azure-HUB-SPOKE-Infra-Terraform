# Network Module - Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "subnets" {
  description = "Map of subnet configurations"
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
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  type        = bool
  default     = false
}

variable "nat_gateway_name" {
  description = "Name of the NAT Gateway"
  type        = string
  default     = ""
}

variable "nat_gateway_subnet_associations" {
  description = "Map of NAT Gateway subnet associations"
  type        = map(string)
  default     = {}
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  type        = bool
  default     = false
}

variable "vpn_gateway_name" {
  description = "Name of the VPN Gateway"
  type        = string
  default     = ""
}

variable "vpn_gateway_sku" {
  description = "SKU of the VPN Gateway"
  type        = string
  default     = "VpnGw1"
}

variable "enable_bgp" {
  description = "Enable BGP for VPN Gateway"
  type        = bool
  default     = false
}

variable "bgp_asn" {
  description = "BGP ASN for VPN Gateway"
  type        = number
  default     = 65515
}

variable "route_tables" {
  description = "Map of route table configurations"
  type = map(object({
    disable_bgp_route_propagation = optional(bool, false)
    routes = optional(map(object({
      address_prefix         = string
      next_hop_type         = string
      next_hop_in_ip_address = optional(string)
    })), {})
  }))
  default = {}
}

variable "route_table_associations" {
  description = "Map of route table associations to subnets"
  type = map(object({
    subnet_name      = string
    route_table_name = string
  }))
  default = {}
}

variable "private_dns_zones" {
  description = "List of private DNS zones"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "Availability zones for resources"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
