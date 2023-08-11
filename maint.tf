terraform {
}

resource "azurerm_public_ip" "reverse_proxy_public_ip" {
  name                = "reverse-proxy-public-ip"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "reverse_proxy_nic" {
  name                      = "reverse-proxy-nic"
  location                  = data.azurerm_resource_group.rg.location
  resource_group_name       = data.azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.RP.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.reverse_proxy_public_ip.id
  }
}

data "template_file" "init_script" {
  template = file("cloud-init.yaml")

  vars = {
    web_server_addresses = join("\n            ", [for ip in module.webserver.websrv_ip_addresses : "server ${ip};"])
    rp_public_address    = azurerm_public_ip.reverse_proxy_public_ip.ip_address
  }
}

resource "azurerm_virtual_machine" "reverse_proxy" {
  name                  = "vm-reverse-proxy"
  location              = data.azurerm_resource_group.rg.location
  resource_group_name   = data.azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.reverse_proxy_nic.id]
  vm_size               = "Standard_B1S"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "rpadmin"
    custom_data = data.template_file.init_script.rendered
  }


  os_profile_linux_config {
  disable_password_authentication = true
  ssh_keys {
    path     = "/home/rpadmin/.ssh/authorized_keys"
    key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD05MGGlh1Rz7bqETKs7o14YcXbqwyqUlVpemeM4UMV7td0XRFOmGzvzH/LXCxujGUO+bXM2fzilvCnzD0wD8JV6hP7qLAAcJvabhZGan2xWpRlGnXGXvD3bfw+9L/ike/RsAfgEe+1flrfl0VvfcBJEWCI3vh3LTjJaQbA9WwI/uplPnR8MLG3FFM46BnzCZNSpuqqmkDcabjYSlOHiIaHGpB+wLLgHS6NeWwfMFAH96YwYlDjLdNLkFPEWaSQkxUlBR4d+k71HHSNEOvqjhn0xqh7DqibXXeR02jqVkRw0dRFiCrifjwrN2rrnp0oX8YZZbr1jQdXajGxVS+pVXyVtqbHp6GUk3gr8OWUGLFEkzO0wxovKaKSFqAob+rW5hppsdDDqIHkAUTUWIDuhrzKO+3/bCYSIfqtxScvAtd7gt8mqtgG2GaUZHqYp0z7RHXRIbJ/XYQPRmWRjz4ucyJfZsmsmj62IM2CxYAzVhoa8T08gINl1bL9RYDPtgnqXvE= generated-by-azure"
  }
}

  storage_os_disk {
    name              = "osdiskRP"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
}
