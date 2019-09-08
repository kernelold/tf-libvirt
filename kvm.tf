terraform {
  required_version = ">= 0.12"
}
# instance the provider
provider "libvirt" {
  uri = "qemu:///system"
}

variable "tfvm_count" {
  default = "4"
}
variable "tfvm_vcpu" {
  default = "4"
}
variable "tfvm_ram" {
  default = "8096"
}
variable "tfvm_vardisk" {
  default = "60"
}
variable "tfvm_usrdisk" {
  default = "60"
}

# We fetch the latest ubuntu release image from their mirrors
#  source = "https://cloud-images.ubuntu.com/releases/xenial/release/ubuntu-16.04-server-cloudimg-amd64-disk1.img"
resource "libvirt_volume" "tfvmqcow" {
  count = "${var.tfvm_count}"
  name = "tfvmqcow-${count.index}"
  pool = "vms"
  source = "/vm/img/ubuntu-16.04-server-cloudimg-amd64-disk1.img"
  format = "qcow2"
}

resource "libvirt_volume" "tfvmvar" {
  count = "${var.tfvm_count}"
  name = "tfvmvar-${count.index}"
  pool = "vms"
  format = "qcow2"
  size = "${var.tfvm_vardisk * 1024 * 1024 * 1024}"
}

resource "libvirt_volume" "tfvmusr" {
  count = "${var.tfvm_count}"
  name = "tfvmusr-${count.index}"
  pool = "vms"
  format = "qcow2"
  size = "${var.tfvm_usrdisk * 1024 * 1024 * 1024}"
}

# Create a network for our VMs
resource "libvirt_network" "vm_network" {
  name = "vm_network"
  addresses = ["192.168.22.0/24"]
  mode = "nat"
  mtu = 9000
  autostart = true
# domain = "k8s.local"
}

# Use CloudInit to add our ssh-key to the instance
resource "libvirt_cloudinit_disk" "commoninit" {
          name = "commoninit.iso"
          pool = "images"
          user_data = "${data.template_file.user_data.rendered}"
          network_config = "${data.template_file.network_config.rendered}"
}

data "template_file" "user_data" {
  template = "${file("${path.module}/cloud_init.cfg")}"
}

data "template_file" "network_config" {
  template = "${file("${path.module}/network_config.cfg")}"
}

# Create the machine
resource "libvirt_domain" "tfvm" {
  count = "${var.tfvm_count}"
  name = "tfvm${count.index}"
  memory = "${var.tfvm_ram}"
  vcpu = "${var.tfvm_vcpu}"

  cloudinit = "${libvirt_cloudinit_disk.commoninit.id}"

  network_interface {
    network_name = "vm_network"
    network_id = "${libvirt_network.vm_network.id}"
    wait_for_lease = true
  }

  # IMPORTANT
  # Ubuntu can hang is a isa-serial is not present at boot time.
  # If you find your CPU 100% and never is available this is why
  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }

  console {
      type        = "pty"
      target_type = "virtio"
      target_port = "1"
  }

  disk {
       volume_id = "${element(libvirt_volume.tfvmqcow.*.id, count.index)}"
  }

  disk {
       volume_id = "${element(libvirt_volume.tfvmvar.*.id, count.index)}"
  }

  disk {
       volume_id = "${element(libvirt_volume.tfvmusr.*.id, count.index)}"
  }

  graphics {
    type = "spice"
    listen_type = "address"
    autoport = "true"
  }
}

output "ips" {
  value = "${libvirt_domain.tfvm.*.network_interface.0.addresses}"
}


