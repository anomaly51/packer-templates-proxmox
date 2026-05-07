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

source "proxmox-iso" "debian" {
  proxmox_url              = var.proxmox_api_url
  username                 = var.proxmox_api_id
  password                 = var.proxmox_api_secret
  insecure_skip_tls_verify = true

  node                 = var.target_node
  vm_name              = var.vm_name
  vm_id                = var.vm_id
  template_description = "${var.vm_name} built by Packer on ${var.target_node}"

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
    disk_size    = var.disk_size
    format       = "raw"
    storage_pool = "local-lvm"
    type         = "scsi"
  }

  boot_iso {
    type     = "ide"
    iso_file = "local:iso/debian-13.4.0-amd64-netinst.iso"
    unmount  = true
  }

  http_directory = "http"
  http_interface = "en0"
  http_port_min  = var.http_port
  http_port_max  = var.http_port

  boot_wait = "20s"
  boot_command = [
    "<esc><wait>",
    "install auto=true priority=critical ",
    "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
    "hostname=${var.vm_name} domain=local ",
    "locale=en_US.UTF-8 keyboard-configuration/xkb-keymap=us ",
    "netcfg/choose_interface=auto netcfg/link_wait_timeout=15 netcfg/dhcp_timeout=60 ",
    "vga=788 noprompt quiet ---<enter>"
  ]

  ssh_username         = "nekoneki"
  ssh_private_key_file = "~/.ssh/id_ed25519_proxmox-vm"
  ssh_timeout          = "20m"
}

build {
  sources = ["source.proxmox-iso.debian"]

  provisioner "ansible" {
    playbook_file = var.playbook_file
    user          = "nekoneki"
    use_proxy     = false
    galaxy_file   = "../../ansible/requirements.yaml"

    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False"
    ]
  }
}
