resource "azurerm_resource_group" "rg1" {
  name     = "rg1"
  location = "West Europe"
}

resource "azurerm_template_deployment" "vnet-ARM" {
  name                = "vnet-ARM"
  resource_group_name = azurerm_resource_group.rg1.name

  template_body = <<DEPLOY
{
    {
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "vnetAddressSpace": {
            "type": "string",
            "metadata": {
                "description": "addressSpace of vnet"
            },
            "defaultValue": "192.168.0.0/16"
        },
        "subnetNames": {
            "type": "array",
            "metadata": {
                "description": "names of the subnets"
            },
            "defaultValue": ["web", "app", "db","mgmt"]
        },
        "subnetAddressSpace": {
            "type": "array",
            "metadata": {
                "description": "address Spaces of the subnets"
            }, 
            "defaultValue": ["192.168.0.0/24", "192.168.1.0/24", "192.168.2.0/24","19.168.3.0/24"]
        }
    },
    "variables": {
        "vnet-name": "ntier-vnet"
    },
    "resources": [
        {
            "type": "Microsoft.Network/virtualNetworks",
            "apiVersion": "2022-07-01",
            "name": "[variables('vnet-name')]",
            "location": "[resourceGroup().location]",
            "properties": {
                "addressSpace": {
                    "addressPrefixes": [ "[parameters('vnetAddressSpace')]" ]
                }
            },
            "tags": {
                "Env": "Dev",
                "CreatedBy": "ARM Templates"
            }
        },
        {
            "type": "Microsoft.Network/virtualNetworks/subnets",
            "apiVersion": "2022-07-01",
            "name": "[concat(variables('vnet-name'),'/',parameters('subnetNames')[copyIndex()])]",
            "properties": {
                "addressPrefix": "[parameters('subnetAddressSpace')[copyIndex()]]"
            },
            "copy": {
                "name": "subnetcopy",
                "count": "[length(parameters('subnetNames'))]",
                "mode": "Serial"
            },
            "dependsOn": [
                "[resourceId('Microsoft.Network/virtualNetworks', variables('vnet-name'))]"
            ]

        }
    ]
}

DEPLOY


  #

  deployment_mode = "Incremental"
}

output "vnet-name" {

  value = azurerm_template_deployment.vnet-ARM.outputs["vnet-name"]

}