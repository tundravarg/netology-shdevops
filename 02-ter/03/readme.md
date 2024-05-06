# Домашнее задание к занятию «Управляющие конструкции в коде Terraform»



## Задание 1


> 2. Заполните файл personal.auto.tfvars.

Поля `cloud_id` и `folder_id` заполнил значениями из UI Yandex Cloud.

Вместо заполнения поля `token`, сгенерировал IAM-ключ,
скопировал его куда-то в домашний каталог и
прописал его в `providers.tf`.

Создание токена:

```shell
yc iam key create --service-account-name <имя_сервисного_аккаунта> -o key.json
```

providers.tf:

```conf
provider "yandex" {
#  token     = var.token
  service_account_key_file = file("~/.config/yandex-cloud/.iam_key.json")
```

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