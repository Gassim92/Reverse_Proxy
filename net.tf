# Définition des variables
variable "subscription_id" {
  default = "ec907711-acd7-4191-9983-9577afbe3ce1"
}

variable "naming_suffix" {
  default = "brief16mgk"
}

data "azurerm_resource_group" "rg" {
  name     = "rg-brief16mgk"
}

# Création du réseau virtuel (RP Servers)
resource "azurerm_virtual_network" "vnet" {
  name                = "VNET--${var.naming_suffix}"
  address_space       = ["10.120.0.0/24"]
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}


# Création du sous-réseaux virtuel (Servers)
resource "azurerm_subnet" "srv" {
  name                      = "srv--${var.naming_suffix}"
  resource_group_name       = data.azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  address_prefixes          = ["10.120.0.0/28"]
}

# Définition des règles de sécurité pour le sous-réseau SNET-srv
resource "azurerm_network_security_group" "srv_nsg" {
  name                = "srv-nsg-${var.naming_suffix}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_http_inbound" {
  name                        = "Allow_HTTP_Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = azurerm_virtual_network.vnet.address_space[0]
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.srv_nsg.name
}

resource "azurerm_network_security_rule" "deny_https_inbound" {
  name                        = "Deny_HTTPS_Inbound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = azurerm_virtual_network.vnet.address_space[0]
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.srv_nsg.name
}

# Création du sous-réseau virtuel (Reverse Proxy)
resource "azurerm_subnet" "RP" {
  name                      = "RP--${var.naming_suffix}"
  resource_group_name       = data.azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet.name
  address_prefixes          = ["10.120.0.16/28"]
}

# Définition des règles de sécurité pour le sous-réseau SNET-RP
resource "azurerm_network_security_group" "rp_nsg" {
  name                = "rp-nsg-${var.naming_suffix}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "http_inbound" {
  name                        = "Allow_HTTP_Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.rp_nsg.name
}

resource "azurerm_network_security_rule" "https_inbound" {
  name                        = "Allow_HTTPS_Inbound"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.rp_nsg.name
}

resource "azurerm_network_security_rule" "http_outbound" {
  name                        = "Allow_HTTP_Outbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.rp_nsg.name
}

resource "azurerm_network_security_rule" "https_outbound" {
  name                        = "Allow_HTTPS_Outbound"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = data.azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.rp_nsg.name
}

resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.120.0.32/28"] 
}

# Création de l'adresse IP publique pour le Bastion
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "bastion-public-ip-${var.naming_suffix}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method  = "Static"
  sku                = "Standard"
}

# Création de l'instance Bastion
resource "azurerm_bastion_host" "mgk" {
  name                = "bastion-host--${var.naming_suffix}"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
    
    ip_configuration {
    name                          = "srv-ipconfig"
    subnet_id                     = azurerm_subnet.bastion.id
    public_ip_address_id          =  azurerm_public_ip.bastion_public_ip.id
  }
}
