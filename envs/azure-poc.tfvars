###############################################################################
# Common
###############################################################################
company     = "corus"
app_name    = "bto"
environment = "poc"
location    = "east us 2"

###############################################################################
# Network
###############################################################################
network_vnet_cidr   = "10.0.0.0/24"
public_subnet_cidr  = "10.0.0.0/25"
private_subnet_cidr = "10.0.0.128/25"

###############################################################################
# Sql Server VM
###############################################################################
sqlserver_vm_hostname         = "patricstar"
sqlserver_vm_sku              = "2016-Datacenter"
sqlserver_vm_size             = "Standard_B2s"
sqlserver_vm_admin_username   = "btodbo"
sqlserver_disk_os_size        = 127
sqlserver_disk_sqldata_size   = 32
sqlserver_disk_sqllogs_size   = 32
sqlserver_disk_tempdb_size    = 32