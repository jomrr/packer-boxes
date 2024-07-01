# file: vars/almalinux-9-x86_64.pkrvars.hcl

boot_command    = ["<up>e<wait><down><down><end> ipv6disable=1 inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<f10><wait>"]

iso_checksum    = "sha256:1e5d7da3d84d5d9a5a1177858a5df21b868390bfccf7f0f419b1e59acc293160"
iso_url         = "https://repo.almalinux.org/almalinux/9.4/isos/x86_64/AlmaLinux-9.4-x86_64-boot.iso"

name            = "almalinux-9"
templatefile    = "templates/almalinux.pkrtpl.hcl"
version         = "9"
vm_name         = "almalinux-9-box"
