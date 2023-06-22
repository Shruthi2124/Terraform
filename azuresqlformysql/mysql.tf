resource "azurerm_private_dns_zone" "privatednszone" {
  name                     = "privatednszone"
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dnszonevlink" {
  name                  = "dnszonevlink"
  private_dns_zone_name = azurerm_private_dns_zone.privatednszone.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  resource_group_name   = azurerm_resource_group.rg1.name
}

resource "azurerm_mysql_flexible_server" "mysqlserver1" {
  name                   = "mysqlserver1"
  resource_group_name    = azurerm_resource_group.rg1.name
  location               = azurerm_resource_group.rg1.location
  administrator_login    = "mysqlserver1"
  administrator_password = "Su@9876!5"
  backup_retention_days  = 7
  delegated_subnet_id    = azurerm_subnet.dbsubnet.id
  private_dns_zone_id    = azurerm_private_dns_zone.privatednszone.id
  sku_name               = "Standard_E2ds_v4"
  version = "5.7"

  storage {
    storage_mb = 51200
    backup_retention_days = 7
    geo_redundant_backup = "Disabled"
    auto_grow = "Enabled"
  }

  depends_on = [
    azurerm_private_dns_zone_virtual_network_link.dnszonevlink
  ]
}

resource "azurerm_private_endpoint" "pep" {
  name = "pep"
  location = azurerm_resource_group.rg1.location
  resouresource_group_name = azurerm_resource_group.rg1.name
  subnet_id = azurerm_subnet.dbsubnet.id

  private_service_connection {
    name = private

    
  }  
}

