variable "location" {
  type        = string
  default     = "East US"
  description = "location to create resource"
}

variable "vnet_range" {
  type        = list(string)
  default     = ["192.168.0.0/16"]
  description = "cidr range of vnet"
}

variable "subnet_names" {
  type    = list(string)
  default = ["web", "app", "db"]

}

variable "names" {
  type = object({
    resource_group    = string
    vnet              = string
    sql_server        = string
    virtual_machine   = string
    network_interface = string
  })


  default = {
    resource_group    = "rg"
    vnet              = "vnet"
    sql_server        = "sbdatabase"
    virtual_machine   = "vm1"
    network_interface = "azurenic"
  }
}