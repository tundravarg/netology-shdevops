### SSH

locals {
    default_metadata = {
        serial-port-enable = 1
        ssh-keys = file(var.default_ssh_pub_key_file)
    }
}
