###############################################################################
# Common Variables 
###############################################################################

variable "company" {
  description = "This variable defines the company name used to name resources"
}

variable "app_name" {
  description = "This variable defines the application name"
}

variable "environment" {
  description = "This variable defines the environment to be built"
}

# azure region
variable "location" {
  description = "Azure region where the resource group will be created"
}

###############################################################################
# Network
###############################################################################
variable "network_vnet_cidr" {
}

variable "public_subnet_cidr" {
}

variable "private_subnet_cidr" {
}

output "network_resource_group_id" {
  value = azurerm_resource_group.rg-environment.id
}

output "network_vnet_id" {
  value = azurerm_virtual_network.network-vnet.id
}

output "network_public_subnet_id" {
  value = azurerm_subnet.network-public-subnet.id
}

output "network_private_subnet_id" {
  value = azurerm_subnet.network-private-subnet.id
}

###############################################################################
# Sql Server Variables
###############################################################################
# Limited to 15 characters long
variable "sqlserver_vm_hostname" {}
variable "sqlserver_vm_size" {}
variable "sqlserver_disk_os_size" {}

# Windows assings drive letters in order, where E is allocated to a DVD drive
variable "disk_sqldata_letter" {
  default     = "F"
}

variable "disk_sqldata_label" {
  default     = "Sql Data"
}

variable "sqlserver_disk_sqldata_size" {
}

variable "disk_sqllogs_letter" {
  default     = "G"
}

variable "disk_sqllogs_label" {
  default     = "Sql Logs"
}

variable "sqlserver_disk_sqllogs_size" {}

variable "disk_tempdb_letter" {
  default     = "H"
}

variable "disk_tempdb_label" {
  default     = "Sql TempDB"
}

variable "sqlserver_disk_tempdb_size" {}

variable "sqlserver_vm_sku" {}

variable "sqlserver_vm_admin_username" {}

output "sqlserver_vm_id" {
  value = azurerm_windows_virtual_machine.sqlserver-vm.id
}

output "sqlserver_vm_username" {
  value = var.sqlserver_vm_admin_username
}

output "sqlserver_vm_password" {
  value = random_password.sqlserver-vm-password.result
}

output "sqlserver_vm_public_ip" {
  value = azurerm_public_ip.sqlserver-ip.ip_address
}

output "debug" {
  value = local.disk_config
}
