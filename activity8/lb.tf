
resource "azurerm_public_ip" "publicip" {
  name                = "publicip"
  location            = azurerm_resource_group.rg3.location
  resource_group_name = azurerm_resource_group.rg3.name
  allocation_method   = "Dynamic"
}

resource "azurerm_lb" "lb" {
  name                = "lb"
  location            = "east us"
  resource_group_name = "rg3"

  frontend_ip_configuration {
    name                 = "frontip"
    public_ip_address_id = azurerm_public_ip.publicip.id
  }
  depends_on = [
    azurerm_public_ip.publicip,
    azurerm_virtual_network.rg_vnet,
    azurerm_subnet.sub1
  ]
}

resource "azurerm_lb_backend_address_pool" "backendpool" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "backendpool"
}

