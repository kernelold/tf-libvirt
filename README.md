# tf-libvirt
## On Arch linux
### Packman
`
pacman -S ebtables bridge-utils openbsd-netcat libvirt libvirt-glib libvirt-python qemu-block-gluster qemu-block-iscsi qemu-block-rbd qemu-guest-agent qemu-headless qemu-headless-arch-extra dnsmasq ebtables virt-install nwfilter nftables openntpd 
`
### Services
`
  systemctl start libvirtd ; systemctl enable libvirtd
  systemctl start libvirt-guests ; systemctl enable libvirt-guests
`

