vms_metadata = {
  serial-port-enable = 1
  ssh-keys           = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDkF/OgffkLTOiBBsiXYEGcfHAWffmJgfJ5dF51ApukgBjtWRJtNDBKg7jlSrX26DP/mi4sN7P1A4QrMqtNlT6qIjXcx306PZ8z19EvHhzK04+ntr3hIvdm+DfzbaFi0zId07bac53UzRx0LnftMpOI+0L7ywnv4YySZFJvmbJsj3DIIjoRYAGqeOFubXx5jYDB+26GQWZXLel36H/6sY5Jye5gmnYQcwfUlMTYdLpR1Whb3O6ORRGVVbX47c28/byWdsAYjePFS9wJLywXjrEDSAjP3pvQTSYQehb80z2SQ53zxEh97xsG+tyS7ipoI6r/XtFhhBrLizRchMIiAQQpggmWnBzpdot+iwGKeuBp9p34QIwKoWFVm/Y9mh6IZGWV9H2xi/RznLHjHwsZU77HwA4+uN2uN/Z6zmBasqONfac0hH7OXmSB2jG3ae2AFTLx/yFqPObyg+HDcz2IrhqREhbV9JRVBhzB2PMu5DahoM0QKa82qjjqbk8ochmObRs= sergey@tundravarg-dt"
}

vms_resources = {
    web = {
        cores         = 2
        memory        = 1
        core_fraction = 20
    }
    db = {
        cores         = 2
        memory        = 2
        core_fraction = 20
    }
}
