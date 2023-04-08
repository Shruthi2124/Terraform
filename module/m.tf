provider "azurerm" {
  features {}
}

module "moduleex" {
  source              = "./moduleex"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network     = azurerm_virtual_network.ntier.name
  subnet              = azurerm_subnet.Subnet-1.name

}
output "apacheurl" {
  value = "http://${azurerm_linux_virtual_machine.apache.public_ip_address}"
}


