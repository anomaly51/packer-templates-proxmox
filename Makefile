PACKER = packer

GLOBAL_VARS = global-vars/proxmox-creds.pkrvars.hcl
T_DEBIAN = packer/debian

PACKER_OPTS = -var-file="../../$(GLOBAL_VARS)"

SSH_KEY = ~/.ssh/id_ed25519_proxmox-vm

.PHONY: init build-all build-parallel \
	node1-debian node2-debian \
	node1-debian-k3s node2-debian-k3s \
	node1-debian-omv node2-debian-omv \
	build-template

init:
	cd $(T_DEBIAN) && $(PACKER) init .

build-template:
	cd $(BUILD_DIR) && $(PACKER) build $(PACKER_OPTS) \
		-var="target_node=$(TARGET_NODE)" \
		-var="vm_name=$(VM_NAME)" \
		-var="vm_id=$(VM_ID)" \
		-var="playbook_file=$(PLAYBOOK)" \
		-var="http_port=$(HTTP_PORT)" \
		-var="disk_size=$(DISK_SIZE)" \
		.

node1-debian:
	$(MAKE) build-template BUILD_DIR=$(T_DEBIAN) TARGET_NODE=machine-1 VM_NAME=debian-base VM_ID=20004 PLAYBOOK=../../ansible/entrypoint-debian-base.yaml HTTP_PORT=8885 DISK_SIZE=20G

node2-debian:
	$(MAKE) build-template BUILD_DIR=$(T_DEBIAN) TARGET_NODE=machine-2 VM_NAME=debian-base VM_ID=20005 PLAYBOOK=../../ansible/entrypoint-debian-base.yaml HTTP_PORT=8886 DISK_SIZE=20G

node1-debian-k3s:
	$(MAKE) build-template BUILD_DIR=$(T_DEBIAN) TARGET_NODE=machine-1 VM_NAME=debian-k3s VM_ID=20006 PLAYBOOK=../../ansible/entrypoint-debian-k3s.yaml HTTP_PORT=8887 DISK_SIZE=20G

node2-debian-k3s:
	$(MAKE) build-template BUILD_DIR=$(T_DEBIAN) TARGET_NODE=machine-2 VM_NAME=debian-k3s VM_ID=20007 PLAYBOOK=../../ansible/entrypoint-debian-k3s.yaml HTTP_PORT=8888 DISK_SIZE=20G

node1-debian-omv:
	$(MAKE) build-template BUILD_DIR=$(T_DEBIAN) TARGET_NODE=machine-1 VM_NAME=debian-omv VM_ID=20008 PLAYBOOK=../../ansible/entrypoint-debian-omv.yaml HTTP_PORT=8889 DISK_SIZE=200G

node2-debian-omv:
	$(MAKE) build-template BUILD_DIR=$(T_DEBIAN) TARGET_NODE=machine-2 VM_NAME=debian-omv VM_ID=20009 PLAYBOOK=../../ansible/entrypoint-debian-omv.yaml HTTP_PORT=8890 DISK_SIZE=200G

build-all: node1-ubuntu node2-ubuntu node1-ubuntu-k3s node2-ubuntu-k3s node1-debian node2-debian node1-debian-k3s node2-debian-k3s node1-debian-omv node2-debian-omv

build-parallel:
	$(MAKE) -j 6 node1-debian node2-debian node1-debian-k3s node2-debian-k3s node1-debian-omv node2-debian-omv
