resource "azurerm_resource_group" "rg3" {
  name     = "rg3"
  location = "east us"
}

resource "azurerm_virtual_network" "rg_vnet" {
  name                = "rg_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg3.location
  resource_group_name = azurerm_resource_group.rg3.name
  depends_on = [
    azurerm_resource_group.rg3
  ]
}


resource "azurerm_subnet" "sub1" {
  name                 = "sub1"
  resource_group_name  = "rg3"
  virtual_network_name = "rg_vnet"
  address_prefixes     = ["10.0.2.0/24"]
  depends_on = [
    azurerm_virtual_network.rg_vnet
  ]
}


resource "azurerm_network_interface" "nic1" {
  name                = "nic1"
  location            = "east us"
  resource_group_name = "rg3"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.sub1.id
    private_ip_address_allocation = "Dynamic"

  }
  depends_on = [
    azurerm_virtual_network.rg_vnet,
    azurerm_subnet.sub1
  ]

}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  resource_group_name = azurerm_resource_group.rg3.name
  location            = azurerm_resource_group.rg3.location
  security_rule {
    name                       = "securityrule"
    protocol                   = "Tcp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [
    azurerm_virtual_network.rg_vnet,
    azurerm_subnet.sub1
  ]
}

resource "azurerm_network_interface_security_group_association" "nicsg" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "ntier_vm" {
  name                  = "vmachine"
  resource_group_name   = azurerm_resource_group.rg3.name
  location              = azurerm_resource_group.rg3.location
  size                  = "Standard_B1s"
  admin_username        = "azureuser1"
  network_interface_ids = [azurerm_network_interface.nic1.id]
  admin_ssh_key {
    username   = "azureuser1"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
  custom_data = filebase64("apache.sh")
  depends_on = [
    azurerm_network_interface.nic1,
    azurerm_network_security_group.nsg,
    azurerm_virtual_network.rg_vnet,
    azurerm_subnet.sub1,
    azurerm_resource_group.rg3
  ]
}



