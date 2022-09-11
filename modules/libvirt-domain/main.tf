terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.6.14"
    }
  }
}
# Bastion

resource "libvirt_volume" "vm" {
  name           = "${var.name}.img"
  base_volume_id = var.base_volume_id
  pool           = var.pool_name
  size           = var.disk_size
}

data "template_file" "vm_network" {
  template = file("${path.module}/network_config.cfg")
  vars = {
    net_1_address = "${var.ip}/23"
    net_1_gateway = var.gateway
  }
}

resource "libvirt_cloudinit_disk" "vm" {
  name           = "${var.name}-cloudinit.iso"
  user_data      = var.user_data
  network_config = data.template_file.vm_network.rendered
  pool           = var.pool_name
}

resource "libvirt_domain" "vm" {
  name      = var.name
  memory    = var.memory_mb
  vcpu      = var.vcpu
  autostart = true

  network_interface {
    bridge = var.bridge
  }

  cloudinit = libvirt_cloudinit_disk.vm.id

  disk {
    volume_id = libvirt_volume.vm.id
    scsi      = "true"
  }

  dynamic "disk" {
    for_each = var.block_devices
    content {
      block_device = disk.value
    }
  }

  # IMPORTANT: this is a known bug on cloud images, since they expect a console
  # we need to pass it
  # https://bugs.launchpad.net/cloud-images/+bug/1573095
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  lifecycle {
    ignore_changes = [
      cloudinit
    ]
  }
}