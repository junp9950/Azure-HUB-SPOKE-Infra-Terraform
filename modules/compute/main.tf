# Compute Module - Main Configuration

# SSH Keys
resource "azurerm_ssh_public_key" "main" {
  for_each = var.ssh_keys

  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  public_key          = each.value.public_key

  tags = var.tags
}

# Network Interfaces for VMs
resource "azurerm_network_interface" "main" {
  for_each = var.vms

  name                = "${each.key}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_ids[each.value.subnet_name]
    private_ip_address_allocation = lookup(each.value, "private_ip_address", null) != null ? "Static" : "Dynamic"
    private_ip_address            = lookup(each.value, "private_ip_address", null)
  }

  enable_accelerated_networking = lookup(each.value, "enable_accelerated_networking", false)

  tags = var.tags
}

# Network Security Group Associations
resource "azurerm_network_interface_security_group_association" "main" {
  for_each = { for k, v in var.vms : k => v if lookup(v, "network_security_group_name", null) != null }

  network_interface_id      = azurerm_network_interface.main[each.key].id
  network_security_group_id = var.network_security_group_ids[each.value.network_security_group_name]
}

# Virtual Machines
resource "azurerm_linux_virtual_machine" "main" {
  for_each = { for k, v in var.vms : k => v if v.os_type == "Linux" }

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = each.value.size
  admin_username      = each.value.admin_username
  zone                = lookup(each.value, "availability_zone", null)

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.main[each.key].id,
  ]

  admin_ssh_key {
    username   = each.value.admin_username
    public_key = lookup(each.value, "ssh_key_data", azurerm_ssh_public_key.main[each.value.ssh_key_name].public_key)
  }

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = lookup(each.value, "os_disk_caching", "ReadWrite")
    storage_account_type = lookup(each.value, "os_disk_type", "Premium_LRS")
    disk_size_gb        = lookup(each.value, "os_disk_size_gb", 30)
  }

  source_image_reference {
    publisher = each.value.source_image.publisher
    offer     = each.value.source_image.offer
    sku       = each.value.source_image.sku
    version   = each.value.source_image.version
  }

  identity {
    type = lookup(each.value, "identity_type", "SystemAssigned")
  }

  tags = var.tags
}

resource "azurerm_windows_virtual_machine" "main" {
  for_each = { for k, v in var.vms : k => v if v.os_type == "Windows" }

  name                = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = each.value.size
  admin_username      = each.value.admin_username
  admin_password      = each.value.admin_password
  zone                = lookup(each.value, "availability_zone", null)

  network_interface_ids = [
    azurerm_network_interface.main[each.key].id,
  ]

  os_disk {
    name                 = "${each.key}-osdisk"
    caching              = lookup(each.value, "os_disk_caching", "ReadWrite")
    storage_account_type = lookup(each.value, "os_disk_type", "Premium_LRS")
    disk_size_gb        = lookup(each.value, "os_disk_size_gb", 127)
  }

  source_image_reference {
    publisher = each.value.source_image.publisher
    offer     = each.value.source_image.offer
    sku       = each.value.source_image.sku
    version   = each.value.source_image.version
  }

  identity {
    type = lookup(each.value, "identity_type", "SystemAssigned")
  }

  tags = var.tags
}

# Managed Disks
resource "azurerm_managed_disk" "main" {
  for_each = var.data_disks

  name                 = each.key
  location             = var.location
  resource_group_name  = var.resource_group_name
  storage_account_type = each.value.storage_account_type
  create_option       = "Empty"
  disk_size_gb        = each.value.disk_size_gb
  zone                = lookup(each.value, "availability_zone", null)

  tags = var.tags
}

# Attach Data Disks to VMs
resource "azurerm_virtual_machine_data_disk_attachment" "main" {
  for_each = var.data_disk_attachments

  managed_disk_id    = azurerm_managed_disk.main[each.value.disk_name].id
  virtual_machine_id = try(
    azurerm_linux_virtual_machine.main[each.value.vm_name].id,
    azurerm_windows_virtual_machine.main[each.value.vm_name].id
  )
  lun                       = each.value.lun
  caching                   = lookup(each.value, "caching", "ReadWrite")
  create_option            = lookup(each.value, "create_option", "Attach")
  write_accelerator_enabled = lookup(each.value, "write_accelerator_enabled", false)
}

# VM Extensions
resource "azurerm_virtual_machine_extension" "custom_script_linux" {
  for_each = { for k, v in var.vm_extensions : k => v if v.type == "CustomScript" && v.os_type == "Linux" }

  name                 = each.key
  virtual_machine_id   = azurerm_linux_virtual_machine.main[each.value.vm_name].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = each.value.type_handler_version

  settings = jsonencode(each.value.settings)

  protected_settings = each.value.protected_settings != null ? jsonencode(each.value.protected_settings) : null

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "monitoring_linux" {
  for_each = { for k, v in var.vms : k => v if v.os_type == "Linux" && lookup(v, "enable_monitoring", false) }

  name                 = "${each.key}-monitoring"
  virtual_machine_id   = azurerm_linux_virtual_machine.main[each.key].id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"

  tags = var.tags
}

# Availability Sets
resource "azurerm_availability_set" "main" {
  for_each = var.availability_sets

  name                         = each.key
  location                     = var.location
  resource_group_name          = var.resource_group_name
  platform_fault_domain_count  = each.value.fault_domain_count
  platform_update_domain_count = each.value.update_domain_count
  managed                      = true

  tags = var.tags
}