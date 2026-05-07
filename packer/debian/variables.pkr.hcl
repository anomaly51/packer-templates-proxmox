variable "proxmox_api_url" {
  type = string
}

variable "proxmox_api_id" {
  type = string
}

variable "proxmox_api_secret" {
  type      = string
  sensitive = true
}

variable "target_node" {
  type = string
}

variable "vm_name" {
  type = string
}

variable "vm_id" {
  type = number
}

variable "disk_size" {
  type    = string
  default = "20G"
}

variable "playbook_file" {
  type = string
}

variable "http_port" {
  type = number
}
