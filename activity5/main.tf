resource "azurerm_resource_group" "rg" {
  name     = var.names.resource_group
  location = var.location
  tags = {
    Env       = "Dev"
    CreatedBy = "Terraform"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.names.vnet
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_range
  depends_on = [
    azurerm_resource_group.rg
  ]
  tags = {
    Env       = "Dev"
    CreatedBy = "Terraform"
  }
}
resource "azurerm_subnet" "subnets" {
  count                = length(var.subnet_names)
  name                 = var.subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.vnet_range[0], 8, count.index)]
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}

resource "azurerm_network_interface" "azurenic" {
  name                = var.names.network_interface
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_configuration {
    name                          = "ipconfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnets
  }
}

resource "azurerm_virtual_machine" "azurevm" {

  name                = var.names.virtual_machine
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  size                = "standard_B1ls"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.azurenic,
  ]
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  depends_on = [
    azurerm_resource_group.rg
  ]
  tags = {
    Env       = "Dev"
    CreatedBy = "Terraform"
  }
