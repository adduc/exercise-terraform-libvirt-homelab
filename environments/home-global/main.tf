terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.6.14"
    }
  }
}

provider "libvirt" {
  # While libvirt supports running VMs for an individual user, a bug in
  # the libvirt provider's implementation prevents everything except
  # system targets from working as intended.
  uri = var.vm_host1
}

##
# Notes
##
# # make sure libvirt is not running dnsmasq to avoid conflicts with docker
# $ virsh net-undefine default
##

##
# /etc/network/interfaces
##
# auto lo
# iface lo inet loopback
#
# auto eth0
# iface eth0 inet manual
#
# auto libvirtbr0
# iface libvirtbr0 inet static
#         address 192.168.56.11
#         netmask 255.255.254.0
#         gateway 192.168.56.1
#         bridge-ports eth0
#         bridge-stp 0
#         post-up ip -6 a flush dev libvirtbr0; sysctl -w net.ipv6.conf.libvirtbr0.disable_ipv6=1

##
# Global
##

resource "libvirt_pool" "images" {
  # Where we store our OS images
  name = "images"
  type = "dir"
  path = "/var/lib/libvirt/images"
}

resource "libvirt_pool" "disks" {
  # Where we store the disks for each VM
  name = "disks"
  type = "dir"
  path = "/var/lib/libvirt/disks"
}

resource "libvirt_volume" "ubuntu_20_04_current_img" {
  name   = "ubuntu_2004.img"
  pool   = libvirt_pool.images.name
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "ubuntu_22_04_current_img" {
  name   = "ubuntu_2204.img"
  pool   = libvirt_pool.images.name
  source = "https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_network" "default" {
  name = "default"

  mode   = "bridge"
  bridge = "libvirtbr0"
}
