resource "azurerm_resource_group" "rg-environment" {
  name     = "rg-${lower(replace(var.app_name," ","-"))}-${var.environment}"
  location = var.location
  
  tags = {
    company     = var.company
    application = var.app_name
    environment = var.environment
  }
}