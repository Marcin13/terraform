variable "ssh_key" {
  default = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHz+yltBw5JTjA/bmUb6JkWyeoKvK6TGEARAjj0UhRsW ansible"
}
variable "proxmox_host" {
    default = "pve"
}
variable "template_name" {
    default = "VM 9000"
}
