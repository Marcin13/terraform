terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.7.4"
    }
  }
}

provider "proxmox" {
  # url is the hostname (FQDN if you have one) for the proxmox host you'd like to connect to to issue the commands. my proxmox host is 'prox-1u'. Add /api2/json at the end for the API
  pm_api_url = "https://10.225.1.110:8006/api2/json"
  # api token id is in the form of: <username>@pam!<tokenId>
  pm_api_token_id = "terraform-prov@pve!tokenID123"
  # this is the full secret wrapped in quotes. don't worry, I've already deleted this from my proxmox cluster by the time you read this post
  pm_api_token_secret = "7dbf26ae-b062-4ad5-b879-911e3f69152a"
  # leave tls_insecure set to true unless you have your proxmox SSL certificate situation fully sorted out (if you do, you will know)
  pm_tls_insecure = true
}
# full list of arguments with explanation
# https://registry.terraform.io/providers/Telmate/proxmox/latest/docs/resources/vm_qemu
# resource is formatted to be "[type]" "[entity_name]" so in this case
# we are looking to create a proxmox_vm_qemu entity named test_server
resource "proxmox_vm_qemu" "vm-server" {
  count = 0 # just want 1 for now, set to 0 and apply to destroy VM
  name = "Ubuntu-20.04-${count.index + 1}" #count.index starts at 0, so + 1 means this VM will be named test-vm-1 in proxmox
  # this now reaches out to the vars file. I could've also used this var above in the pm_api_url setting but wanted to spell it out up there. target_node is different than api_url. target_node is which node hosts the template and thus also which node will host the new VM. it can be different than the host you use to communicate with the API. the variable contains the contents "prox-1u"
  target_node = var.proxmox_host
  desc = "Ubuntu 20.04 clean vm from template"
  vmid = "11${count.index + 1}" #id for new created vm etc .111, 112, 113
  # oncreate = "false" # Whether to have the VM startup after the PVE node starts.
  # another variable with contents "ubuntu-20.04"
  clone = var.template_name # name of template you want to create from
  full_clone = "true" # Set to true to create a full clone, or false to create a linked clone. See the docs about cloning for more info. Only applies when clone is set.
  # basic VM settings here. agent refers to guest agent
  agent = 1
  os_type = "ubuntu" # Which provisioning method to use, based on the OS type. Options: ubuntu, centos, cloud-init
  bios = "seabios"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 4064
  balloon = "1000" # The minimum amount of memory to allocate to the VM in Megabytes, when Automatic Memory Allocation is desired. Proxmox will enable a balloon device on the guest to manage dynamic allocation.
  scsihw = "virtio-scsi-pci" # The SCSI controller to emulate. Options: lsi, lsi53c810, megasas, pvscsi, virtio-scsi-pci, virtio-scsi-single
  bootdisk = "scsi0"

  onboot = "false" # Whether to have the VM startup after the PVE node starts.

  ciuser = "ubuntu"  # Override the default cloud-init user for provisioning.
  cipassword = "password" # Override the default cloud-init user's password. Sensitive.
  # automatic_reboot = "true"

  vga{
    type = "std"
  }
  # if you want two NICs, just copy this whole network section and duplicate it
  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  disk {
    // This disk will become scsi0
    type = "scsi"
    storage = "local-lvm"
    size = "10G" # set disk size here. leave it small for testing because expanding the disk takes time.
    # slot = 0 # (not sure what this is for, seems to be deprecated, do not use).
    iothread = 1 # Whether to use iothreads for this drive. Only effective with a disk of type virtio, or scsi when the the emulated controller type (scsihw top level block argument) is virtio-scsi-single.
  }
  # not sure exactly what this is for. presumably something about MAC addresses and ignore network changes during the life of the VM
  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  # the ${count.index + 1} thing appends text to the end of the ip address
  # in this case, since we are only adding a single VM, the IP will
  # be 10.98.1.91 since count.index starts at 0. this is how you can create
  # multiple VMs and have an IP assigned to each (.91, .92, .93, etc.)
  ipconfig0 = "ip=10.225.1.11${count.index + 1}/24,gw=10.225.1.1"

  # sshkeys set using variables. the variable contains the text of the key.
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF
}
