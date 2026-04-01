## Proxmox Ubuntu Template Builder (Packer)

This project builds a Ubuntu Server 22.04 template for a Proxmox cluster using Packer and Ansible.

## Requirements
* [Packer](https://www.packer.io/) (v1.0+)
* [Ansible](https://www.ansible.com/)
* SSH Key: `~/.ssh/id_ed25519_proxmox-vm` (for SSH/Bastion access)
* Proxmox API access

## Project Structure
* `ubuntu.pkr.hcl` - Main Packer build configuration.
* `playbook.yaml` - Ansible playbook for provisioning.
* `tasks/` - Ansible roles/tasks (Zsh setup, template cleanup).
* `http/` - Cloud-init auto-install files (`user-data`, `meta-data`).

## How to Build

Because Proxmox cluster nodes use local storage (`local-lvm`), you must build a template for each node with a unique VM ID.

### Build on Node 1
```bash
packer init ubuntu.pkr.hcl
packer build \
  -var="target_node=machine-1" \
  -var="template_vmid=20000" \
  ubuntu.pkr.hcl
```

### Build on Node 2
```bash
packer build \
  -var="target_node=machine-2" \
  -var="template_vmid=20001" \
  ubuntu.pkr.hcl
```

### Build Both at the Same Time (Parallel)
```bash
packer build -var="target_node=machine-1" -var="template_vmid=20000" ubuntu.pkr.hcl & \
packer build -var="target_node=machine-2" -var="template_vmid=20001" ubuntu.pkr.hcl & \
wait
```
