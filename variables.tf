variable "resource_group_name" {
  default = "Gass_test"
}

variable "location" {
  default = "North Europe"
}

variable "ssh_public_key" {
  description = "SSH public key for authentication"
  type        = string
  default     = "ssh-rsa ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQD05MGGlh1Rz7bqETKs7o14YcXbqwyqUlVpemeM4UMV7td0XRFOmGzvzH/LXCxujGUO+bXM2fzilvCnzD0wD8JV6hP7qLAAcJvabhZGan2xWpRlGnXGXvD3bfw+9L/ike/RsAfgEe+1flrfl0VvfcBJEWCI3vh3LTjJaQbA9WwI/uplPnR8MLG3FFM46BnzCZNSpuqqmkDcabjYSlOHiIaHGpB+wLLgHS6NeWwfMFAH96YwYlDjLdNLkFPEWaSQkxUlBR4d+k71HHSNEOvqjhn0xqh7DqibXXeR02jqVkRw0dRFiCrifjwrN2rrnp0oX8YZZbr1jQdXajGxVS+pVXyVtqbHp6GUk3gr8OWUGLFEkzO0wxovKaKSFqAob+rW5hppsdDDqIHkAUTUWIDuhrzKO+3/bCYSIfqtxScvAtd7gt8mqtgG2GaUZHqYp0z7RHXRIbJ/XYQPRmWRjz4ucyJfZsmsmj62IM2CxYAzVhoa8T08gINl1bL9RYDPtgnqXvE= generated-by-azure"
}