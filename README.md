# tf-libvirt
# Installation
## On Arch linux
### Packman

Needed packages:

```
pacman -S ebtables bridge-utils openbsd-netcat libvirt libvirt-glib libvirt-python qemu-block-gluster qemu-block-iscsi qemu-block-rbd qemu-guest-agent qemu-headless qemu-headless-arch-extra dnsmasq ebtables virt-install nwfilter nftables openntpd wget git terraform
```

### Services

Enable following services:

```
  systemctl start libvirtd ; systemctl enable libvirtd
  systemctl start libvirt-guests ; systemctl enable libvirt-guests
```

### Terraform modules

Install terraform-provider-libvirt https://github.com/dmacvicar/terraform-provider-libvirt

### Preparations

Need to create pools for images and vms:

```
mkdir /vm/
mkdir /vm/vms
mkdir /vm/img
cd /vm/img ; wget https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img ; cd -
virsh pool-define images.xml
virsh pool-define vms.xml
virsh pool-start images
virsh pool-start vms
virsh pool-autostart images
virsh pool-autostart vms
```
