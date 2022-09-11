variable "vcpu" {
  type    = number
  default = 1
}

variable "ip" {
  type = string
}

variable "disk_size" {
  type = number
}

variable "name" {
  type = string
}

variable "memory_mb" {
  type = string
}

variable "base_volume_id" {
  type = string
}

variable "pool_name" {
  type = string
}

variable "block_devices" {
  type    = list(string)
  default = []
}

variable "bridge" {
  type = string
}

variable "user_data" {
  type = string
}

variable "gateway" {
  type = string
}
