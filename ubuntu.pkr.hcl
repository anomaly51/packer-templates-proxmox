variable "target_node" {
  type = string
}

variable "template_vmid" {
  type = number
}

packer {
  required_plugins {
    proxmox = {
      version = "~> 1"
      source  = "github.com/hashicorp/proxmox"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

source "proxmox-iso" "ubuntu" {
  proxmox_url              = "https://10.99.1.35:8006/api2/json"
  username                 = "root@pam"
  password                 = "4355"
  insecure_skip_tls_verify = true

  node                 = var.target_node
  vm_id                = var.template_vmid
  vm_name              = "ubuntu-server-template"
  template_description = "Ubuntu Server Template on ${var.target_node}"

  cores      = 4
  memory     = 2048
  os         = "l26"
  qemu_agent = true

  scsi_controller = "virtio-scsi-pci"

  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
  }

  disks {
    disk_size    = "20G"
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "scsi"
  }

  additional_iso_files {
    cd_files         = ["http/meta-data", "http/user-data"]
    cd_label         = "cidata"
    iso_storage_pool = "local"
    unmount          = true
  }

  boot_iso {
    type     = "ide"
    iso_file = "local:iso/ubuntu-22.04.5-live-server-amd64.iso"
    unmount  = true
  }

  boot_wait = "5s"
  boot_command = [
    "c<wait>",
    "linux /casper/vmlinuz --- autoinstall ds=nocloud<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]

  ssh_username         = "nekoneki"
  ssh_private_key_file = "~/.ssh/id_ed25519_proxmox-vm"
  ssh_timeout          = "20m"

  ssh_bastion_host             = "10.99.1.105"
  ssh_bastion_username         = "nekoneki"
  ssh_bastion_private_key_file = "~/.ssh/id_ed25519_proxmox-vm"
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "ansible" {
    playbook_file = "./playbook.yaml"
    user          = "nekoneki"
    use_proxy     = false

    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False"
    ]

    extra_arguments = [
      "--ssh-common-args",
      "-o ProxyCommand=\"ssh -W %h:%p -q -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519_proxmox-vm nekoneki@10.99.1.105\""
    ]
  }
}
