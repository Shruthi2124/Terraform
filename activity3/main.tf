resource "azurerm_resource_group" "resgrp1" {
  name     = "resgrp1"
  location = "West Europe"
}

resource "azurerm_virtual_network" "Virtualnetwork" {
  name                = "Virtualnetwork"
  location            = "West Europe"
  resource_group_name = "resgrp1"
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

depends_on = [
  azurerm_resource_group.resgrp1
]
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = "resgrp1"
  virtual_network_name = "Virtualnetwork"
  address_prefixes     = ["10.0.1.0/24"]
}


