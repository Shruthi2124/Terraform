resource "azurerm_resource_group" "aseentierrg" {
  name     = "aseerg"
  location = "eastus"
  tags = {
    Env       = "Dev"
    CreatedBy = "Terraform"
  }
}

resource "azurerm_virtual_network" "ntiervnet" {
  name                = "aseevnet"
  resource_group_name = azurerm_resource_group.aseentierrg.name
  location            = azurerm_resource_group.aseentierrg.location
  address_space       = ["10.0.0.0/16"]
  tags = {
    Env       = "Dev"
    CreatedBy = "Terraform"
  }
  depends_on = [
    azurerm_resource_group.aseentierrg
  ]
}

resource "azurerm_subnet" "app" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.aseentierrg.name
  virtual_network_name = azurerm_virtual_network.ntiervnet.name
  address_prefixes     = ["10.0.0.0/24"]
  depends_on = [
    azurerm_virtual_network.ntiervnet
  ]
}
resource "azurerm_network_security_group" "ntiernsg" {
  name                = "aseensg"
  location            = azurerm_resource_group.aseentierrg.location
  resource_group_name = azurerm_resource_group.aseentierrg.name
  security_rule {
    name                       = "ssh"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "22"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  depends_on = [
    azurerm_virtual_network.ntiervnet,
    azurerm_subnet.app
  ]
  tags = {
    Env       = "Dev"
    CreatedBy = "Terraform"
  }
}

resource "azurerm_network_security_rule" "securityrule" {
  name                        = "securityrule"
  resource_group_name         = azurerm_resource_group.aseentierrg.name
  network_security_group_name = azurerm_network_security_group.ntiernsg.name
  priority                    = 350
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_public_ip" "ntierippub" {
  name                = "ntierippub"
  resource_group_name = azurerm_resource_group.aseentierrg.name
  location            = azurerm_resource_group.aseentierrg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    CreatedBy = "Terraform"
    Env       = "Dev"
  }
  depends_on = [
    azurerm_virtual_network.ntiervnet,
    azurerm_subnet.app

  ]
}

resource "azurerm_network_interface" "ntiernic" {
  name                = "aseenic"
  resource_group_name = azurerm_resource_group.aseentierrg.name
  location            = azurerm_resource_group.aseentierrg.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.app.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ntierippub.id
  }
  depends_on = [
    azurerm_public_ip.ntierippub,
    azurerm_virtual_network.ntiervnet,
    azurerm_network_security_group.ntiernsg
  ]
}
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.ntiernsg.id
}

resource "azurerm_network_interface_backend_address_pool_association" "nicpool" {
  network_interface_id    = azurerm_network_interface.ntiernic.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.backpool.id
  depends_on = [
    azurerm_lb_backend_address_pool.backpool
  ]
}

resource "azurerm_linux_virtual_machine" "ntiervm" {
  name                   = "aseevm"
  location               = azurerm_resource_group.aseentierrg.location
  resource_group_name    = azurerm_resource_group.aseentierrg.name
  network_interface_ids = [
    azurerm_network_interface.ntiernic.id
  ]
  admin_username                  = "aseedevops"
  admin_password                  = "Asee@1234567"
  disable_password_authentication = false
  size                            = "Standard_B1s"
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

  user_data = filebase64("script.sh")

  tags = {
    CreatedBy = "Terraform"
    Env       = "Dev"
  }
  depends_on = [
    azurerm_network_interface.ntiernic,
    azurerm_network_security_group.ntiernsg,
    azurerm_virtual_network.ntiervnet,
    azurerm_subnet.app
  ]
}

