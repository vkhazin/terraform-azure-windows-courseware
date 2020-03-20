locals {
  script_raw = <<SCRIPT
    Start-Transcript -Path 'C:/SetupLog/terraform.log' -NoClobber;
    Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -Confirm:$false;
    Set-Volume -DriveLetter ${var.disk_sqldata_letter}  -NewFileSystemLabel "${var.disk_sqldata_label}";
    Set-Volume -DriveLetter ${var.disk_sqllogs_letter}  -NewFileSystemLabel "${var.disk_sqllogs_label}";
    Set-Volume -DriveLetter ${var.disk_tempdb_letter}   -NewFileSystemLabel "${var.disk_tempdb_label}";
    Stop-Transcript;
    exit 0;
  SCRIPT

  script = "${replace(local.script_raw, "\n", "")}"
}

# Generate random password
resource "random_password" "sqlserver-vm-password" {
  length           = 16
  min_upper        = 2
  min_lower        = 2
  min_special      = 2
  number           = true
  special          = true
  override_special = "!@#$%&"
}

# Create Network Security Group to Access VM from Internet
resource "azurerm_network_security_group" "sqlserver-vm-nsg" {
  name                = "nsg-sqlserver-${var.app_name}-${var.environment}"
  location            = azurerm_resource_group.rg-environment.location
  resource_group_name = azurerm_resource_group.rg-environment.name

  security_rule {
    name                       = "AllowRDP"
    description                = "Allow RDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*" 
  }

  tags = {
    application = var.app_name
    environment = var.environment 
  }
}

# Associate the NSG with the Public Subnet
resource "azurerm_subnet_network_security_group_association" "sqlserver-nsg-association" {
  subnet_id                 = azurerm_subnet.network-public-subnet.id
  network_security_group_id = azurerm_network_security_group.sqlserver-vm-nsg.id
}

# Get a Static Public IP
resource "azurerm_public_ip" "sqlserver-ip" {
  name                = "${var.sqlserver_vm_hostname}-ip"
  location            = azurerm_resource_group.rg-environment.location
  resource_group_name = azurerm_resource_group.rg-environment.name
  allocation_method   = "Static"
  
  tags = { 
    application = var.app_name
    environment = var.environment 
  }
}

# Create Network Card for VM
resource "azurerm_network_interface" "sqlserver-vm-nic" {
  name                      = "${var.sqlserver_vm_hostname}-nic"
  location                  = azurerm_resource_group.rg-environment.location
  resource_group_name       = azurerm_resource_group.rg-environment.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.network-public-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.sqlserver-ip.id
  }

  tags = { 
    application = var.app_name
    environment = var.environment 
  }
}

resource "azurerm_windows_virtual_machine" "sqlserver-vm" {
  name                  = var.sqlserver_vm_hostname
  location              = azurerm_resource_group.rg-environment.location
  resource_group_name   = azurerm_resource_group.rg-environment.name
  size                  = var.sqlserver_vm_size
  network_interface_ids = [azurerm_network_interface.sqlserver-vm-nic.id]
  
  computer_name         = var.sqlserver_vm_hostname
  admin_username        = var.sqlserver_vm_admin_username
  admin_password        = random_password.sqlserver-vm-password.result

  os_disk {
    name                 = "sqlserver-${var.sqlserver_vm_hostname}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.sqlserver_disk_os_size
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = var.sqlserver_vm_sku
    version   = "latest"
  }

  enable_automatic_updates = true
  provision_vm_agent       = true

  tags = {
    application = var.app_name
    environment = var.environment 
  }
}

resource "azurerm_managed_disk" "disk-sqllogs" {
  name                 = "${var.sqlserver_vm_hostname}-disk-sqllogs"
  location              = azurerm_resource_group.rg-environment.location
  resource_group_name   = azurerm_resource_group.rg-environment.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.sqlserver_disk_sqllogs_size

  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk-sqllogs-attachment" {
  depends_on=[azurerm_managed_disk.disk-sqllogs]
  managed_disk_id    = azurerm_managed_disk.disk-sqllogs.id
  virtual_machine_id = azurerm_windows_virtual_machine.sqlserver-vm.id
  lun                = "10"
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "disk-sqldata" {
  name                 = "${var.sqlserver_vm_hostname}-disk-sqldata"
  location              = azurerm_resource_group.rg-environment.location
  resource_group_name   = azurerm_resource_group.rg-environment.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.sqlserver_disk_sqldata_size

  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk-sqldata-attachment" {
  depends_on=[azurerm_managed_disk.disk-sqldata]
  managed_disk_id    = azurerm_managed_disk.disk-sqldata.id
  virtual_machine_id = azurerm_windows_virtual_machine.sqlserver-vm.id
  lun                = "20"
  caching            = "ReadWrite"
}

resource "azurerm_managed_disk" "disk-tempdb" {
  name                 = "${var.sqlserver_vm_hostname}-disk-tempdb"
  location              = azurerm_resource_group.rg-environment.location
  resource_group_name   = azurerm_resource_group.rg-environment.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = var.sqlserver_disk_tempdb_size

  tags = {
    environment = var.environment
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "disk-tempdb-attachment" {
  depends_on=[azurerm_managed_disk.disk-tempdb]
  managed_disk_id    = azurerm_managed_disk.disk-tempdb.id
  virtual_machine_id = azurerm_windows_virtual_machine.sqlserver-vm.id
  lun                = "30"
  caching            = "ReadWrite"
}

# Windows VM virtual machine extenstion - Configure Disks
resource "azurerm_virtual_machine_extension" "sqlserver-vm-extension" {
  depends_on=[
    azurerm_windows_virtual_machine.sqlserver-vm,
    azurerm_managed_disk.disk-sqldata,    
    azurerm_managed_disk.disk-sqllogs,
    azurerm_managed_disk.disk-tempdb,
    azurerm_virtual_machine_data_disk_attachment.disk-sqldata-attachment,
    azurerm_virtual_machine_data_disk_attachment.disk-sqllogs-attachment,
    azurerm_virtual_machine_data_disk_attachment.disk-tempdb-attachment
  ]

  name                 = "${var.sqlserver_vm_hostname}-vm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.sqlserver-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"  
  settings = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -Command \"${local.script}\""
  }
  SETTINGS
  tags = { 
    environment = var.environment
  }
}