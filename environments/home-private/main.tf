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

data "terraform_remote_state" "global" {
  backend = "local"

  config = {
    path = "../home-global/terraform.tfstate"
  }
}

locals {
  gigabyte = 1000000000
}

module "k3s" {
  count  = 2
  source = "../../modules/libvirt-domain"

  name           = "k3s${count.index + 1}"
  ip             = "${var.ip_prefix}${count.index + 1}"
  gateway        = var.gateway
  disk_size      = 40 * local.gigabyte
  memory_mb      = "8192"
  vcpu           = 4
  base_volume_id = data.terraform_remote_state.global.outputs.volume_ubuntu_2204_id
  pool_name      = data.terraform_remote_state.global.outputs.pool_disks_name
  bridge         = data.terraform_remote_state.global.outputs.network_bridge

  user_data = templatefile("${path.module}/cloud-init.default.yaml", {
    hostname = "k3s${count.index + 1}"
    user        = var.user
    user_github = var.user_github
    user_id     = var.user_id
  })
}

output "k3s_ip" {
  value = module.k3s.*.ip
}