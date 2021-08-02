terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.66.0"
    }
    github = {
      source = "integrations/github"
      version = "4.12.0"
    }

}
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
    client_id       = var.client_id
    client_secret   = var.client_secret
    subscription_id = var.subscription_id
    tenant_id       = var.tenant_id
    features {}
}

provider "github" {
  # Configuration options
}
