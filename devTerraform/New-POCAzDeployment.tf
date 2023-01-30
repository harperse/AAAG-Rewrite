# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "myTFResourceGroup"
  location = "westus2"
  tags = {
    "Creator" = "Terraform"
    }
}

resource "azurerm_automation_account" "aaa" {
  name  = "myTFAutomationAccount"
  location = "westus2"
  tags = {
    "Creator" = "Terraform"
  }
  sku_name = "Basic"
  resource_group_name = azurerm_resource_group.rg.name
}