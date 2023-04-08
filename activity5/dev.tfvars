names = {
  location          = "East US"
  vnet_range        = ["10.0.0.0/16"]
  subnet_names      = ["app", "db"]
  network_interface = "azurenic"
  virtual_machine   = "vm1"
}