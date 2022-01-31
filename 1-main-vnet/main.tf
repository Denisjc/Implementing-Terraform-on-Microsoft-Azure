#############################################################################
# TERRAFORM CONFIG
#############################################################################

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.93.0"
    }
  }
}

#############################################################################
# VARIABLES
#############################################################################

variable "resource_group_name" {
  type = string
  default = "vnet-main"
}

variable "location" {
  type    = string
  default = "northeurope"
}

variable "vnet_cidr_range" {
  type = list(string)
  default = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  type    = list(string)
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "subnet_names" {
  type    = list(string)
  default = ["web", "database"]
}

variable "project_name" {
  type    = string
  default = ""
}

variable "environment" {
  type    = string
  default = ""
}


#############################################################################
# DATA
#############################################################################

data "azurerm_resource_group" "example" {
  name = "${var.project_name}-${var.environment}-rg"
}


#############################################################################
# PROVIDERS
#############################################################################

provider "azurerm" {
  # version = "~> 1.0"
  tenant_id       = "260097cb-a66d-4caa-b2e7-b713da0789ea"
  features {}
}

#############################################################################
# RESOURCES
#############################################################################

resource "azurerm_resource_group" "vnet_main" {
  name     = var.resource_group_name
  location = var.location
}

module "vnet-main" {
  source              = "Azure/vnet/azurerm"
  version             = "~> 2.0"
  resource_group_name = var.resource_group_name
  #location            = var.location
  vnet_name           = var.resource_group_name
  address_space       = var.vnet_cidr_range
  subnet_prefixes     = var.subnet_prefixes
  subnet_names        = var.subnet_names
  nsg_ids             = {}

  tags = {
    environment = "dev"
    costcenter  = "it"

  }

  depends_on = [azurerm_resource_group.vnet_main]
}

#############################################################################
# OUTPUTS
#############################################################################

output "vnet_id" {
  value = module.vnet-main.vnet_id
}
