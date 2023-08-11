data "azurerm_resource_group" "rg_websrv" {
    name              = "rg-brief16mgk"
}

data "azurerm_image" "image" {
  name                = "debian11NginxWebSrv"
  resource_group_name = "rg-brief16mgk"
}

module "webserver" {
  source = "./webSrv/nVM_private_module"
  resource_group_name            = data.azurerm_resource_group.rg_websrv.name
  location                       = data.azurerm_resource_group.rg_websrv.location
  vnet_id                        = azurerm_virtual_network.vnet.id
  vm_names                       = ["vm-brief16mgk-websrv1", "vm-brief16mgk-websrv2"]
  vm_count                       = 2
  vm_size                        = "Standard_B1S"
  subnet_id                      = azurerm_subnet.srv.id
  source_image_id                = data.azurerm_image.image.id
  ssh_public_key                 = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD05MGGlh1Rz7bqETKs7o14YcXbqwyqUlVpemeM4UMV7td0XRFOmGzvzH/LXCxujGUO+bXM2fzilvCnzD0wD8JV6hP7qLAAcJvabhZGan2xWpRlGnXGXvD3bfw+9L/ike/RsAfgEe+1flrfl0VvfcBJEWCI3vh3LTjJaQbA9WwI/uplPnR8MLG3FFM46BnzCZNSpuqqmkDcabjYSlOHiIaHGpB+wLLgHS6NeWwfMFAH96YwYlDjLdNLkFPEWaSQkxUlBR4d+k71HHSNEOvqjhn0xqh7DqibXXeR02jqVkRw0dRFiCrifjwrN2rrnp0oX8YZZbr1jQdXajGxVS+pVXyVtqbHp6GUk3gr8OWUGLFEkzO0wxovKaKSFqAob+rW5hppsdDDqIHkAUTUWIDuhrzKO+3/bCYSIfqtxScvAtd7gt8mqtgG2GaUZHqYp0z7RHXRIbJ/XYQPRmWRjz4ucyJfZsmsmj62IM2CxYAzVhoa8T08gINl1bL9RYDPtgnqXvE= generated-by-azure"
}