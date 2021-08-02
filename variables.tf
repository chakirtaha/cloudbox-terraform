

# Azure Credentials
variable "client_id" { default = "1b2f37dc-1cab-4197-af38-7d7dcc4b8525"}
variable "client_secret" { default = "cd5b8dd8-2a29-4f71-8f1a-891e31fac9da"}
variable "subscription_id" { default = "59d460b9-da91-449c-9c53-0f01f82b5e2f"}
variable "tenant_id" { default = "52707392-fe79-46d6-ae10-cd8e506f41f9"}

# Variables

variable "location" { default = "westeurope" }
variable "prefix" { default = "cloudbox" }
variable "hostname" { default = "tahachakir" }
variable "ssh_user" { default = "tahachakir" }
variable "ssh_password" { default = "Tahachakir1997taha" }
variable "source_address_prefix" {
}

variable "azurevm_ip" {
  default = "azurerm_public_ip.main.ip_address"
}

variable "administrator_login" {
  default = "taha"
}
variable "administrator_login_password" {
  default = "ku}6LV7_s%$z:!_H"
}
