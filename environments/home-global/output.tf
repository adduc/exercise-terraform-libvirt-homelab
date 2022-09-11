output "volume_ubuntu_2004_id" {
  value = libvirt_volume.ubuntu_20_04_current_img.id
}

output "volume_ubuntu_2204_id" {
  value = libvirt_volume.ubuntu_22_04_current_img.id
}

output "pool_disks_name" {
  value = libvirt_pool.disks.name
}

output "network_bridge" {
  value = libvirt_network.default.bridge
}
