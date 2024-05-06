resource "yandex_compute_disk" "storage" {
    count = 3

    name = "storage-${count.index}"
    type = "network-hdd"
    size = 1
}


resource "yandex_compute_instance" "storage" {
    name = "storage"
    platform_id = "standard-v1"
    resources {
        cores = 2
        memory = 1
        core_fraction = 20
    }
    boot_disk {
        initialize_params {
            image_id = data.yandex_compute_image.default_image.image_id
        }
    }
    dynamic "secondary_disk" {
        for_each = yandex_compute_disk.storage
        content {
            disk_id = lookup(secondary_disk.value, "id")
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
