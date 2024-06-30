# file: templates/kickstart.pkrtpl.hcl
  eula        --agreed
  graphical
  skipx
  firstboot   --disable
  reboot      --eject
  url         --url=var.kickstart_url

  clearpart   --all --drives=vda --initlabel
  ignoredisk  --only-use=vda
  zerombr

  # partitioning
  part /boot/efi  --asprimary --ondrive=vda --size=1024     --fstype=efi    --fsoptions="umask=0077,shortname=winnt"
  part /boot      --asprimary --ondrive=vda --size=1024     --fstype=ext4   --fsoptions="noatime"
  part /tmp                                 --size=2048     --fstype=tmpfs  --fsoptions="noatime,nodev,noexec,nosuid,mode=1700"
  part pv.0       --asprimary --ondrive=vda --size 1 --grow --fstype=lvmpv

  # volume groups
  volgroup system pv.0

  # logical volumes
  logvol /              --vgname=system --name=root  --fstype=ext4  --size=8192  --fsoptions="noatime"
  logvol /home          --vgname=system --name=home  --fstype ext4  --size=2048  --fsoptions="noatime,nodev,nosuid"
  logvol /opt           --vgname=system --name=opt   --fstype ext4  --size=2048  --fsoptions="noatime,nodev,nosuid"
  logvol /srv           --vgname=system --name=srv   --fstype ext4  --size=4096  --fsoptions="noatime,nodev,noexec,nosuid"
  logvol /var           --vgname=system --name=var   --fstype ext4  --size=8192  --fsoptions="noatime"
  logvol /var/lib       --vgname=system --name=lib   --fstype ext4  --size=8192  --fsoptions="noatime"
  logvol /var/log       --vgname=system --name=log   --fstype ext4  --size=4096  --fsoptions="noatime,nodev,noexec,nosuid,"
  logvol /var/log/audit --vgname=system --name=audit --fstype ext4  --size=4096  --fsoptions="noatime,nodev,noexec,nosuid,noatime"
  logvol /var/tmp       --vgname=system --name=tmp   --fstype ext4  --size=4096  --fsoptions="noatime,nodev,noexec,nosuid,noatime"
  logvol /var/www       --vgname=system --name=www   --fstype ext4  --size=4096  --fsoptions="noatime,nodev,noexec,nosuid,noatime"
  
  # network configuration
  network     --hostname={{ inventory_hostname }}
  network     --device=enp1s0 --noipv6 --bootproto=dhcp
  
  # keyboard, language and timezone configuration
  keyboard    --vckeymap=de --xlayouts='de'
  lang        en_US.UTF-8 --addsupport=de_DE.UTF-8
  timezone    Europe/Berlin --utc
  timesource  --ntp-server=ntp.web.de
  
  # timesource  --ntp-server ntp3.fau.de
  user --name=vagrant --groups=wheel --password=vagrant --shell=/bin/bash
  
  # add ssh keys
  sshkey --username=vagrant ""
  
  selinux   --enforcing
  services  --enabled="auditd,firewalld,rsyslog"
  
  %packages --ignoremissing
  @^minimal-environment
  bash
  bash-comppletion
  dnf-automatic
  dnf-plugins-core
  firewalld
  libpwquality
  python3
  python3-dnf
  python3-libselinux
  python3-libsemanage
  python3-pwquality
  sudo
  qemu-guest-agent 
  zstd
  -iw
  -iwl*-firmware
  -libsss_*
  -nano
  -vim
  -sssd
  -sssd-*
  -zram-generator*
  %end
 
  %addon com_redhat_kdump --disable
  %end
  
  %post --interpreter /usr/bin/bash --log=/root/postinstall.log
  cat << EOF >> /etc/modprobe.d/harden.conf
  install cramfs /bin/true
  install dccp /bin/true
  install freevxfs /bin/true
  install hfs /bin/true
  install hfsplus /bin/true
  install jffs2 /bin/true
  install rds /bin/true
  install sctp /bin/true
  install squashfs /bin/true
  install tipc /bin/true
  install udf /bin/true
  install usb-storage /bin/true
  EOF
  %end