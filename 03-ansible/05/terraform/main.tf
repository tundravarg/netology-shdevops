variable "project_name" {
    type = string
    default = "ntlg-a5"
}

variable "vm_params" {
    type = map(object({
        cpu = number,
        ram = number,
        disk_volume = number
    }))
    default = {
        "clickhouse" = {
            cpu = 2
            ram = 2
            disk_volume = 8
        },
        "vector" = {
            cpu = 2
            ram = 2
            disk_volume = 8
        },
        "lighthouse" = {
            cpu = 2
            ram = 2
            disk_volume = 8
        }
    }
}


data "yandex_compute_image" "default_image" {
  family = "debian-12"
}


resource "yandex_vpc_network" "main-network" {
  name = var.project_name
}

resource "yandex_vpc_subnet" "main-subnet" {
  name           = var.project_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.main-network.id
  v4_cidr_blocks = ["192.168.35.0/24"]
}

resource "yandex_compute_instance" "host" {
    for_each = var.vm_params

    name = "${var.project_name}-${each.key}"
    hostname = "${var.project_name}-${each.key}"
    platform_id = "standard-v3"
    resources {
        cores = each.value.cpu
        memory = each.value.ram
        core_fraction = 20
    }
    scheduling_policy {
        preemptible = true
    }
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.default_image.image_id
            size = each.value.disk_volume
        }
    }
    network_interface {
        subnet_id = yandex_vpc_subnet.main-subnet.id
        nat = true
    }
    metadata = {
        serial-port-enable = 1
        ssh-keys = "admin:${file("../ssh/admin.pub")}"
    }
}
