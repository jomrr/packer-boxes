# file: templates/kickstart.pkrtpl.hcl

eula        --agreed
graphical
skipx
firstboot   --disable
reboot      --eject

url         --url="https://mirror.jomrr.de/almalinux/9/BaseOS/x86_64/os"

repo        --name="almalinux-base"      --baseurl="https://mirror.jomrr.de/almalinux/9/BaseOS/x86_64/os"
repo        --name="almalinux-appstream" --baseurl="https://mirror.jomrr.de/almalinux/9/AppStream/x86_64/os"
repo        --name="almalinux-extras"    --baseurl="https://mirror.jomrr.de/almalinux/9/extras/x86_64/os"
repo        --name="almalinux-epel"      --baseurl="https://mirror.jomrr.de/epel/9/x86_64"

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
logvol /var           --vgname=system --name=var   --fstype ext4  --size=8192  --fsoptions="noatime,nodev,nosuid"
logvol /var/lib       --vgname=system --name=lib   --fstype ext4  --size=8192  --fsoptions="noatime,nodev,nosuid"
logvol /var/log       --vgname=system --name=log   --fstype ext4  --size=4096  --fsoptions="noatime,nodev,noexec,nosuid,"
logvol /var/log/audit --vgname=system --name=audit --fstype ext4  --size=4096  --fsoptions="noatime,nodev,noexec,nosuid,noatime"
logvol /var/tmp       --vgname=system --name=tmp   --fstype ext4  --size=4096  --fsoptions="noatime,nodev,noexec,nosuid,noatime"
logvol /var/www       --vgname=system --name=www   --fstype ext4  --size=4096  --fsoptions="noatime,nodev,noexec,nosuid,noatime"

# network configuration
network     --hostname=vagrant --noipv6 --bootproto=dhcp

# keyboard, language and timezone configuration
keyboard    --vckeymap=de --xlayouts='de'
lang        en_US.UTF-8 --addsupport=de_DE.UTF-8
timezone    Europe/Berlin --utc
timesource  --ntp-server=ntp.web.de

# timesource  --ntp-server ntp3.fau.de
user --name=vagrant --groups=wheel --password=vagrant --shell=/bin/bash

# add ssh keys
sshkey --username=vagrant ""

# ssh access during installation
sshpw --username=vagrant vagrant

selinux   --enforcing
services  --enabled="auditd,firewalld,rsyslog"

%packages --ignoremissing
@^minimal-environment
bash
bash-completion
dnf-automatic
dnf-plugins-core
epel-release
libpwquality
neovim
python3
python3-dnf
python3-libselinux
python3-libsemanage
python3-pwquality
sudo
systemd-timesyncd
qemu-guest-agent
zstd
-chrony
-iw
-iwl*-firmware
-libsss_*
-nano
-sssd
-sssd-*
-vi
-vim
-vim-*
-zram-generator*
%end

%addon com_redhat_kdump --disable
%end

%post --interpreter /usr/bin/bash --log=/root/postinstall.log
# blacklist modules
cat << EOF >> /etc/modprobe.d/cis.conf
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
# set editor
alternatives --install /usr/bin/vi vi /usr/bin/nvim 60
alternatives --install /usr/bin/vim vim /usr/bin/nvim 60
alternatives --install /usr/bin/editor editor /usr/bin/nvim 60
alternatives --set vi /usr/bin/nvim
alternatives --set vim /usr/bin/nvim
alternatives --set editor /usr/bin/nvim
echo "export EDITOR='/usr/bin/nvim'" | tee /etc/profile.d/editor.sh
echo "export VISUAL='/usr/bin/nvim'" | tee /etc/profile.d/visual.sh
# configure and enable timesyncd
sed -i 's/#NTP=/NTP=ntp.web.de/' /etc/systemd/timesyncd.conf
systemctl enable systemd-timesyncd
%end
