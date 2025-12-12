# Compute Module - Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "ssh_keys" {
  description = "Map of SSH public keys"
  type = map(object({
    public_key = string
  }))
  default = {}
}

variable "vms" {
  description = "Map of virtual machine configurations"
  type = map(object({
    os_type                        = string # "Linux" or "Windows"
    size                           = string
    admin_username                 = string
    admin_password                 = optional(string) # Required for Windows
    ssh_key_name                   = optional(string) # Required for Linux
    ssh_key_data                   = optional(string) # Direct SSH key data, overrides ssh_key_name
    subnet_name                    = string
    private_ip_address             = optional(string)
    availability_zone              = optional(string)
    network_security_group_name    = optional(string)
    enable_accelerated_networking  = optional(bool, false)
    enable_monitoring              = optional(bool, false)
    identity_type                  = optional(string, "SystemAssigned")
    os_disk_type                   = optional(string, "Premium_LRS")
    os_disk_size_gb               = optional(number)
    os_disk_caching               = optional(string, "ReadWrite")
    source_image = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
  }))
  default = {}
}

variable "data_disks" {
  description = "Map of managed data disk configurations"
  type = map(object({
    storage_account_type = string
    disk_size_gb        = number
    availability_zone   = optional(string)
  }))
  default = {}
}

variable "data_disk_attachments" {
  description = "Map of data disk attachment configurations"
  type = map(object({
    disk_name                 = string
    vm_name                   = string
    lun                       = number
    caching                   = optional(string, "ReadWrite")
    create_option            = optional(string, "Attach")
    write_accelerator_enabled = optional(bool, false)
  }))
  default = {}
}

variable "vm_extensions" {
  description = "Map of VM extension configurations"
  type = map(object({
    vm_name              = string
    type                 = string
    os_type             = string
    type_handler_version = string
    settings            = map(any)
    protected_settings  = optional(map(any))
  }))
  default = {}
}

variable "availability_sets" {
  description = "Map of availability set configurations"
  type = map(object({
    fault_domain_count  = number
    update_domain_count = number
  }))
  default = {}
}

variable "subnet_ids" {
  description = "Map of subnet IDs"
  type        = map(string)
  default     = {}
}

variable "network_security_group_ids" {
  description = "Map of network security group IDs"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}