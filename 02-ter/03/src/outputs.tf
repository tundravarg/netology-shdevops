output "VMs" {

    description = "Created VMs"

    value = [
        for vm in concat(
            yandex_compute_instance.web,
            values(yandex_compute_instance.db),
            [yandex_compute_instance.storage]
        ): {
            name = vm.name
            id = vm.id
            fqdn = vm.fqdn
        }
    ]
    
}