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
