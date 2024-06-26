resource "yandex_vpc_network" "develop" {
  name = var.vpc_name
}

resource "yandex_vpc_subnet" "develop" {
  name           = var.default_subnet_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.default_cidr
  route_table_id = yandex_vpc_route_table.rt.id
}
resource "yandex_vpc_subnet" "develop-2" {
  name           = var.develop-2_subnet_name
  zone           = var.develop-2_zone
  network_id     = yandex_vpc_network.develop.id
  v4_cidr_blocks = var.develop-2_cidr
  route_table_id = yandex_vpc_route_table.rt.id
}


resource "yandex_vpc_gateway" "nat_gateway" {
  name = "test-gateway"
  shared_egress_gateway {}
}
resource "yandex_vpc_route_table" "rt" {
  name       = "test-route-table"
  network_id = yandex_vpc_network.develop.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}


data "yandex_compute_image" "image-web" {
  family = "${var.vm_web_family}"
}

resource "yandex_compute_instance" "platform-web" {
  name        = "${local.vm_web_name}"
  platform_id = "${var.vm_web_platform_id}"
  resources {
    cores         = var.vms_resources.web.cores
    memory        = var.vms_resources.web.memory
    core_fraction = var.vms_resources.web.core_fraction
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
  metadata = var.vms_metadata
}


data "yandex_compute_image" "image-db" {
  family = "${var.vm_db_family}"
}

resource "yandex_compute_instance" "platform-db" {
  name        = "${local.vm_db_name}"
  platform_id = "${var.vm_db_platform_id}"
  zone        = "${var.vm_db_zone}"
  resources {
    cores         = var.vms_resources.db.cores
    memory        = var.vms_resources.db.memory
    core_fraction = var.vms_resources.db.core_fraction
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
  metadata = var.vms_metadata
}
