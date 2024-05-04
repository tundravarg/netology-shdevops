resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop" {
  name           = var.default_subnet_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
}
resource "yandex_vpc_subnet" "develop-2" {
  name           = var.develop-2_subnet_name
  zone           = var.develop-2_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.develop-2_cidr
}


data "yandex_compute_image" "image-web" {
  family = "${var.vm_web_family}"
}

resource "yandex_compute_instance" "platform-web" {
  name        = "${var.vm_web_name}"
  platform_id = "${var.vm_web_platform_id}"
  resources {
    cores         = var.vm_web_cores
    memory        = var.vm_web_memory
    core_fraction = var.vm_web_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image-web.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop.id
    nat       = var.vm_web_nat
  }
  metadata = {
    serial-port-enable = var.vm_web_serial-port-enable
    ssh-keys           = "${var.vms_ssh_root_user}:${var.vms_ssh_root_key}"
  }
}


data "yandex_compute_image" "image-db" {
  family = "${var.vm_db_family}"
}

resource "yandex_compute_instance" "platform-db" {
  name        = "${var.vm_db_name}"
  platform_id = "${var.vm_db_platform_id}"
  zone        = "${var.vm_db_zone}"
  resources {
    cores         = var.vm_db_cores
    memory        = var.vm_db_memory
    core_fraction = var.vm_db_core_fraction
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.image-db.image_id
    }
  }
  scheduling_policy {
    preemptible = var.vm_db_preemptible
  }
  network_interface {
    subnet_id = yandex_vpc_subnet.develop-2.id
    nat       = var.vm_db_nat
  }
  metadata = {
    serial-port-enable = var.vm_db_serial-port-enable
    ssh-keys           = "${var.vms_ssh_root_user}:${var.vms_ssh_root_key}"
  }
}
