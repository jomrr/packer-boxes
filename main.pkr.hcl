# file: main.pkr.hcl

packer {
  required_version = ">= 1.11"
  required_plugins {
    ansible = {
      version = ">= 1.1"
      source  = "github.com/hashicorp/ansible"
    }
    qemu = {
      version = ">= 1.1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "architecture" {
  type = string
  default = "x86_64"
}

variable "boot_command" {
  type = list(string)
  default = [
    "<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora-40-x86_64.ks<enter><wait>"
  ]
}

variable "cpus" {
  type = number
  default = 4
}

variable "disk_size" {
  type = number
  default = 65536
}

variable "efi_firmware_code" {
    type = string
    default = "/usr/share/OVMF/OVMF_CODE.secboot.fd"
}

variable "efi_firmware_vars" {
    type = string
    default = "/usr/share/OVMF/OVMF_VARS.secboot.fd"
}

variable "iso_checksum" {
  type = string
  default = "sha256:4d1c0a7dda6c1d21a1483acb6c7914193158921113f947c5a0519d26bcc548b2"
}

variable "iso_url" {
  type = string
  default = "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-40-1.14.iso"
}

variable "memory" {
  type = number
  default = 8192
}

variable "name" {
  type = string
  default = "fedora-40-x86_64"
}

variable "ssh_username" {
  type = string
  default = "vagrant"
}

variable "ssh_password" {
  type = string
  default = "vagrant"
}

variable "templatefile" {
  type = string
  default = "templates/fedora.pkrtpl.hcl"
}

variable "version" {
  type = string
  default = "40"
}

source "qemu" "generic" {
  accelerator = "kvm"
  boot_command = var.boot_command
  boot_wait = "10s"
  communicator = "ssh"
  cpus = var.cpus
  cpu_model = "host"
  memory = var.memory
  disk_interface = "virtio"
  disk_size = var.disk_size
  disk_discard = "unmap"
  disk_detect_zeroes = "unmap"
  efi_boot = true
  efi_firmware_code = var.efi_firmware_code
  efi_firmware_vars = var.efi_firmware_vars
  format = "qcow2"
  headless = false
  http_content = {
    "/ks.cfg" = templatefile("${var.templatefile}", { var = var })
  }
  http_port_min = 8000
  http_port_max = 9000
  iso_checksum = var.iso_checksum
  iso_url = var.iso_url
  machine_type = "q35"
  net_device = "virtio-net"
  output_directory = "dist/${var.name}"
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout = "15m"
  vm_name = var.name
}

build {
  sources = [
    "source.qemu.generic"
  ]
}
