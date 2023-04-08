resource "azurerm_public_ip" "lb_ip" {
  name                = "lb_ip"
  resource_group_name = azurerm_resource_group.aseentierrg.name
  location            = azurerm_resource_group.aseentierrg.location
  allocation_method   = "Static"
  sku                 = "Standard"

}

resource "azurerm_lb" "ntierbalancer" {
  name                = "aseeBalancer"
  location            = azurerm_resource_group.aseentierrg.location
  resource_group_name = azurerm_resource_group.aseentierrg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb_ip.id
  }
  depends_on = [
    azurerm_public_ip.ntierippub,
    azurerm_subnet.app
  ]
}

resource "azurerm_lb_backend_address_pool" "backpool" {
  loadbalancer_id = azurerm_lb.ntierbalancer.id
  name            = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "lbprobe" {
  loadbalancer_id = azurerm_lb.ntierbalancer.id
  name            = "ssh-running-probe"
  port            = 80
}

resource "azurerm_lb_rule" "lbnatrule" {
  loadbalancer_id = azurerm_lb.ntierbalancer.id
  name            = "http-nat-rule"
  protocol        = "Tcp"
  frontend_port   = 80
  backend_port    = 80
  backend_address_pool_ids = [
    azurerm_lb_backend_address_pool.backpool.id
  ]
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.lbprobe.id
}



