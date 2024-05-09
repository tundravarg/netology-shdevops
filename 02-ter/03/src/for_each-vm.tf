variable "each_vm" {
    type = map(object({ 
        cpu = number, 
        ram = number,
        disk_volume = number
    }))
    default = {
        "main" = {
            cpu = 4
            ram = 4
            disk_volume = 16
        },
        "replica" = {
            cpu = 2
            ram = 2
            disk_volume = 8
        }
    }
}


resource "yandex_compute_instance" "db" {
    for_each = var.each_vm

    name = "${each.key}"
    hostname = "db-${each.key}"
    platform_id = "standard-v3"
    resources {
        cores = each.value.cpu
        memory = each.value.ram
        core_fraction = 20
    }
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.default_image.image_id
            size = each.value.disk_volume
        }
    }
    scheduling_policy {
        preemptible = true
    }
    network_interface {
        subnet_id = yandex_vpc_subnet.develop.id
        security_group_ids = [
            yandex_vpc_security_group.example.id
        ]
        nat = true
    }
    metadata = local.default_metadata
}
