# Security Module - Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

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
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
