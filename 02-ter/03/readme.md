# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»



## Задание 1


> 2. Заполните файл personal.auto.tfvars.

Поля `cloud_id` и `folder_id` заполняются значениями из UI Yandex Cloud.

Получение токена:
* Если профиль не создан и ключ не добавлен:
    * https://yandex.cloud/ru/docs/iam/operations/iam-token/create-for-sa
    * Создание профиля: `yc config profile create <account-name>`
    * Создание авторизационного ключа сервисного аккаунта: `yc iam key create --service-account-name <account-name> --output key.json`
    * Указание ключа для профиля: `yc config set service-account-key key.json`
* Получение IAM-токена: `yc iam create-token`


> 3. Инициализируйте проект, выполните код.

```shell
terraform init
terraform apply
```

![Result](files/ter-03-1-1.jpg)



## Задание 2


> 1. Создайте файл count-vm.tf. Опишите в нём создание двух **одинаковых** ВМ  web-1 и web-2 (не web-0 и web-1) с минимальными параметрами, используя мета-аргумент **count loop**. Назначьте ВМ созданную в первом задании группу безопасности.

https://docs.comcloud.xyz/providers/yandex-cloud/yandex/latest/docs

```conf
variable "default_metadata" {
  description = "Metadata of VM"
  type        = map
}

data "yandex_compute_image" "default_image" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "count" {
    count = 2

    name = "web-${count.index + 1}"
    platform_id = "standard-v3"
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
    metadata = var.default_metadata
}
```

**NOTE:** Комментарий к коду:
Артефакты в разных файлах. 
Здесь - хардкод значений, т.к., считаю, нет смысла усложнять на данном этапе, суть задания не в этом.

![Result](files/ter-03-2-1-1.jpg)

![Result](files/ter-03-2-1-2.jpg)


> 2. Создайте файл for_each-vm.tf. Опишите в нём создание двух ВМ для баз данных с именами "main" и "replica" **разных** по cpu/ram/disk_volume , используя мета-аргумент **for_each loop**.

```conf
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

resource "yandex_compute_instance" "foreach" {
    for_each = var.each_vm

    name = "${each.key}"
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
    metadata = var.default_metadata
}
```

**NOTE:**
    Использовать предложенный в задании тип переменной не получилось по причине ошибки
    `"for_each" supports maps and sets of strings, but you have provided a set containing type object.`.
    Поэтому тип был заменён на `map(object)`.

![Result](files/ter-03-2-2-1.jpg)


> 4. ВМ из пункта 2.1 должны создаваться после создания ВМ из пункта 2.2.

Без указания `depends_on`:

```log
yandex_compute_instance.count[0]: Creating...
yandex_compute_instance.foreach["replica"]: Creating...
yandex_compute_instance.count[1]: Creating...
yandex_compute_instance.foreach["main"]: Creating...
...
```

```diff
--- a/02-ter/03/src/count-vm.tf
+++ b/02-ter/03/src/count-vm.tf
@@ -1,5 +1,6 @@
 resource "yandex_compute_instance" "count" {
     count = 2
+    depends_on = [ yandex_compute_instance.foreach ]
 
     name = "web-${count.index + 1}"
     platform_id = "standard-v3"
```

После указания `depends_on`:

```log
yandex_compute_instance.foreach["main"]: Creating...
yandex_compute_instance.foreach["replica"]: Creating...
yandex_compute_instance.foreach["replica"]: Still creating... [10s elapsed]
yandex_compute_instance.foreach["main"]: Still creating... [10s elapsed]
yandex_compute_instance.foreach["main"]: Still creating... [20s elapsed]
yandex_compute_instance.foreach["replica"]: Still creating... [20s elapsed]
yandex_compute_instance.foreach["main"]: Still creating... [30s elapsed]
yandex_compute_instance.foreach["replica"]: Still creating... [30s elapsed]
yandex_compute_instance.foreach["main"]: Creation complete after 40s [id=fhmrs33mfrt9qi3qm3b9]
yandex_compute_instance.foreach["replica"]: Still creating... [40s elapsed]
yandex_compute_instance.foreach["replica"]: Creation complete after 40s [id=fhmo9ejok1ceg3r1ejoq]
yandex_compute_instance.count[0]: Creating...
yandex_compute_instance.count[1]: Creating...
...
```

> 5. Используйте функцию file в local-переменной для считывания ключа ~/.ssh/id_rsa.pub и его последующего использования в блоке metadata, взятому из ДЗ 2.

```diff
diff --git a/02-ter/03/src/count-vm.tf b/02-ter/03/src/count-vm.tf
index 69e357c..319d13a 100644
--- a/02-ter/03/src/count-vm.tf
+++ b/02-ter/03/src/count-vm.tf
@@ -24,5 +24,5 @@ resource "yandex_compute_instance" "count" {
         ]
         nat = true
     }
-    metadata = var.default_metadata
+    metadata = local.default_metadata
 }

diff --git a/02-ter/03/src/for_each-vm.tf b/02-ter/03/src/for_each-vm.tf
index 12ea33f..fb77db2 100644
--- a/02-ter/03/src/for_each-vm.tf
+++ b/02-ter/03/src/for_each-vm.tf
@@ -45,5 +45,5 @@ resource "yandex_compute_instance" "foreach" {
         ]
         nat = true
     }
-    metadata = var.default_metadata
+    metadata = local.default_metadata
 }

diff --git a/02-ter/03/src/locals.tf b/02-ter/03/src/locals.tf
new file mode 100644
index 0000000..96bbb11
--- /dev/null
+++ b/02-ter/03/src/locals.tf
@@ -0,0 +1,8 @@
+### SSH
+
+locals {
+    default_metadata = {
+        serial-port-enable = 1
+        ssh-keys = file(var.default_ssh_pub_key_file)
+    }
+}

diff --git a/02-ter/03/src/terraform.tfvars b/02-ter/03/src/terraform.tfvars
index f2e2c32..e69de29 100644
--- a/02-ter/03/src/terraform.tfvars
+++ b/02-ter/03/src/terraform.tfvars
@@ -1,4 +0,0 @@
-default_metadata = {
-  serial-port-enable = 1
-  ssh-keys           = "ubuntu:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDkF/OgffkLTOiBBsiXYEGcfHAWffmJgfJ5dF51ApukgBjtWRJtNDBKg7jlSrX26DP/mi4sN7P1A4QrMqtNlT6qIjXcx306PZ8z19EvHhzK04+ntr3hIvdm+DfzbaFi0zId07bac53UzRx0LnftMpOI+0L7ywnv4YySZFJvmbJsj3DIIjoRYAGqeOFubXx5jYDB+26GQWZXLel36H/6sY5Jye5gmnYQcwfUlMTYdLpR1Whb3O6ORRGVVbX47c28/byWdsAYjePFS9wJLywXjrEDSAjP3pvQTSYQehb80z2SQ53zxEh97xsG+tyS7ipoI6r/XtFhhBrLizRchMIiAQQpggmWnBzpdot+iwGKeuBp9p34QIwKoWFVm/Y9mh6IZGWV9H2xi/RznLHjHwsZU77HwA4+uN2uN/Z6zmBasqONfac0hH7OXmSB2jG3ae2AFTLx/yFqPObyg+HDcz2IrhqREhbV9JRVBhzB2PMu5DahoM0QKa82qjjqbk8ochmObRs= sergey@tundravarg-dt"
-}
\ No newline at end of file

diff --git a/02-ter/03/src/variables.tf b/02-ter/03/src/variables.tf
index f8d83a2..b387cb1 100644
--- a/02-ter/03/src/variables.tf
+++ b/02-ter/03/src/variables.tf
@@ -32,10 +32,10 @@ variable "vpc_name" {
 }
 
 
-
 ### SSH
 
-variable "default_metadata" {
-  description = "Metadata of VM"
-  type        = map
-}
\ No newline at end of file
+variable "default_ssh_pub_key_file" {
+    description = "Path to pub key"
+    type = string
+    default = "~/.ssh/id_rsa.pub"
+}

```

```shell
$ cut -c-64 ~/.ssh/netology.pub
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDkF/OgffkLTOiBBsiXYEGcfHAW    
```
![Result](files/ter-03-2-5.jpg)



## Задание 3

> 1. Создайте 3 одинаковых виртуальных диска размером 1 Гб с помощью ресурса yandex_compute_disk и мета-аргумента count в файле **disk_vm.tf** .
> 2. Создайте в том же файле **одиночную**(использовать count или for_each запрещено из-за задания №4) ВМ c именем "storage"  . Используйте блок **dynamic secondary_disk{..}** и мета-аргумент for_each для подключения созданных вами дополнительных дисков.

```conf
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

```

![Result](files/ter-03-3.jpg)



## Задание 4


> 1. В файле ansible.tf создайте inventory-файл для ansible.
>    Используйте функцию tepmplatefile и файл-шаблон для создания ansible inventory-файла.
>    Передайте в него в качестве переменных группы виртуальных машин из задания 2.1, 2.2 и 3.2, т. е. 5 ВМ.
> 2. Инвентарь должен содержать 3 группы и быть динамическим, т. е. обработать как группу из 2-х ВМ, так и 999 ВМ.
> 3. Добавьте в инвентарь переменную  [**fqdn**](https://cloud.yandex.ru/docs/compute/concepts/network#hostname).
> 4. Выполните код. Приложите скриншот получившегося файла. 

`ansible.tfpl`:

```
[webservers]

%{~ for i in webservers ~}

${i["name"]}  ansible_host=${i["network_interface"][0]["nat_ip_address"]}  fqdn=${i["fqdn"]}
%{~ endfor ~}



[databases]

%{~ for i in databases ~}

${i["name"]}  ansible_host=${i["network_interface"][0]["nat_ip_address"]}  fqdn=${i["fqdn"]}
%{~ endfor ~}



[storage]

${storage.name}  ansible_host=${storage.network_interface[0].nat_ip_address}  fqdn=${storage.fqdn}

```

`ansible.td`:

```
resource "local_file" "hosts_templatefile" {
    content = templatefile(
        "${path.module}/ansible.tftpl",
        {
            webservers = yandex_compute_instance.web
            databases  = yandex_compute_instance.db
            storage    = yandex_compute_instance.storage
        }
    )
    filename = "${abspath(path.module)}/hosts.cfg"
}
```

\+ Добавил `hostname` к `db` и `storage`, а к `web` не добавлял.

`hosts.cfg`:

```
[webservers]

web-1  ansible_host=158.160.104.128  fqdn=fhmhk1o7svdgqg7p9jki.auto.internal
web-2  ansible_host=51.250.1.16  fqdn=fhmgogidprga56so7ujv.auto.internal


[databases]

main  ansible_host=158.160.117.166  fqdn=db-main.ru-central1.internal
replica  ansible_host=158.160.97.81  fqdn=db-replica.ru-central1.internal


[storage]

storage  ansible_host=158.160.99.231  fqdn=storage.ru-central1.internal
```



## Задание 5* (необязательное)

> 1. Напишите output, который отобразит ВМ из ваших ресурсов count и for_each в виде списка словарей.

`outputs.tf`:

```
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
```

![Result](files/ter-03-5.jpg)



## Задание 7*

```
> {network_id = local.src.network_id, subnet_ids = concat(slice(local.src.subnet_ids, 0, 2), slice(local.src.subnet_ids, 3, length(local.src.subnet_ids))), subnet_zones = concat(slice(local.src.subnet_zones, 0, 2), slice(local.src.subnet_zones, 3, length(local.src.subnet_zones)))}
{
  "network_id" = "enp7i560tb28nageq0cc"
  "subnet_ids" = [
    "e9b0le401619ngf4h68n",
    "e2lbar6u8b2ftd7f5hia",
    "fl8ner8rjsio6rcpcf0h",
  ]
  "subnet_zones" = [
    "ru-central1-a",
    "ru-central1-b",
    "ru-central1-d",
  ]
}
```
