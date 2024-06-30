# file: vars/fedora-40-x86_64.pkrvars.hcl
boot_command    = [
    "<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/fedora-40-x86_64.ks<enter><wait>"
]

iso_checksum    = "sha256:4d1c0a7dda6c1d21a1483acb6c7914193158921113f947c5a0519d26bcc548b2"
iso_urls        = "https://download.fedoraproject.org/pub/fedora/linux/releases/40/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-40-1.14.iso"

name            = "fedora-40"
version         = "40"
