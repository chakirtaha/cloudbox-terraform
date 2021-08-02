
resource "azurerm_resource_group" "main" {
    name     = "${var.prefix}-rg"
    location = var.location
}

resource "azurerm_virtual_network" "main" {
    name                 = "${var.prefix}-network"
    address_space        = ["10.0.0.0/16"]
    location             = var.location
    resource_group_name  = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
    name                 = "${var.prefix}-subnet"
    resource_group_name  = azurerm_resource_group.main.name
    virtual_network_name = azurerm_virtual_network.main.name
    address_prefix       = "10.0.2.0/24"
}


resource "azurerm_public_ip" "main" {
    name                    = "${var.prefix}-ip"
    location                = var.location
    resource_group_name     = azurerm_resource_group.main.name
    allocation_method       = "Dynamic"
    domain_name_label       = "portailcloudbox"
}


resource "azurerm_network_security_group" "main" {
    name             = "${var.prefix}-sg"
    location         = var.location
    resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix    = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "JENKINS"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix    = "*"
    destination_address_prefix = "*"



  }
  security_rule {
    name                       = "Gitlab"
    priority                   = 1010
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix    = "*"
    destination_address_prefix = "*"



  }
  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix    = "*"
    destination_address_prefix = "*"



  }
}

resource "azurerm_network_interface" "main" {
    name                = "${var.prefix}-nic"
    location            = var.location
    resource_group_name = azurerm_resource_group.main.name
    ip_configuration {
        name                       = "testconfiguration1"
        subnet_id                  =  azurerm_subnet.internal.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.main.id
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_storage_account" "main" {

  name                     = "${var.prefix}storage"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = var.location
  account_replication_type = "LRS"
  account_tier             = "Standard"

}


resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "tls_private_key" {
  value     = tls_private_key.example_ssh.private_key_pem
  sensitive = true
}
