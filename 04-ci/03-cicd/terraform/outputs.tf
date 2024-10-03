output "VMs" {

    description = "Created VMs"

    value = [
        for vm in values(yandex_compute_instance.host): {
            name = vm.name
            id = vm.id
            fqdn = vm.fqdn
            network = [
                for i in vm.network_interface: {
                    internal_ip: i.ip_address
                    public_ip: i.nat_ip_address
                }
            ]
            # vm = vm
        }
    ]
    
}
