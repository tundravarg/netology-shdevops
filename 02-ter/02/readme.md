# Домашнее задание к занятию «Основы Terraform. Yandex Cloud»



## Задание 1


> 2. Создайте сервисный аккаунт и ключ.

1. Настроить `yc`: https://yandex.cloud/en/docs/cli/quickstart#install
2. Создать сервисный аккаунт с ролью `admin` в Yandex Cloud (через UI).
3. Получить IAM-токен: `yc iam key create --service-account-name <имя_сервисного_аккаунта> -o key.json`.


> 3. Сгенерируйте новый или используйте свой текущий ssh-ключ. Запишите его открытую(public) часть в переменную vms_ssh_public_root_key.

```diff
--- a/02-ter/02/src/variables.tf
+++ b/02-ter/02/src/variables.tf
@@ -36,6 +36,5 @@ variable "vpc_name" {
 
 variable "vms_ssh_root_key" {
   type        = string
-  default     = "<your_ssh_ed25519_key>"
   description = "ssh-keygen -t ed25519"
 }
```

И добавил его в `target.auto.tfvars`, как и другие параметры, требующие ручного ввода.
А сам `target.auto.tfvars` - в игнор.


> 4. Инициализируйте проект, выполните код. Исправьте намеренно допущенные синтаксические ошибки. Ищите внимательно, посимвольно. Ответьте, в чём заключается их суть.

```shell
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

1. `FailedPrecondition desc = Platform "standart-v4" not found`

    * Опечатка.
        Нет платформы `standard-v4`, есть `standard-v4` (Intel® Xeon® Gold 6338).
        Платформы перечислены на странице https://yandex.cloud/en/docs/compute/concepts/vm-platforms.
    * `platform_id = "standart-v4"` -> `platform_id = "standard-v3"`

2. `InvalidArgument desc = the specified core fraction is not available on platform "standard-v3"; allowed core fractions: 20, 50, 100`

    * Нет "Гарантированная доля vCPU" `5%`, самая близкая к этому - `20%`.
    * `core_fraction = 5` -> `core_fraction = 20`

3. `InvalidArgument desc = the specified number of cores is not available on platform "standard-v3"; allowed core number: 2, 4`

    * То же самое про количество ядер.
    * `cores = 1` -> `cores = 2`

4. **SUCCESS:** `yandex_compute_instance.platform: Creation complete after 41s [id=fhmg3lk338ocm8f7fho7]`

```diff
--- a/02-ter/02/src/main.tf
+++ b/02-ter/02/src/main.tf
@@ -14,11 +14,11 @@ data "yandex_compute_image" "ubuntu" {
 }
 resource "yandex_compute_instance" "platform" {
   name        = "netology-develop-platform-web"
-  platform_id = "standart-v4"
+  platform_id = "standard-v3"
   resources {
-    cores         = 1
+    cores         = 2
     memory        = 1
-    core_fraction = 5
+    core_fraction = 20
   }
   boot_disk {
     initialize_params {
```

![Result](files/ter-02-1-4.jpg)

**Заметки**
* https://docs.comcloud.xyz/providers/yandex-cloud/yandex/latest/docs
* https://yandex.cloud/en/docs/compute/concepts/vm


> 5. Подключитесь к консоли ВМ через ssh и выполните команду curl ifconfig.me.

![Result](files/ter-02-1-5.jpg)


> 6. Ответьте, как в процессе обучения могут пригодиться параметры preemptible = true и core_fraction=5 в параметрах ВМ.

Позволяют сэкономить денежные средства,
если не требуется полная вычислительная можность ВМ.
Например, если эот какой-то тестовый стенд, не требующий высокой вычислительной мощности
или, как в этих занятиях, учебная виртуалка, чтобы "поиграться" с ней.



## Задание 2


> 1. Замените все хардкод-значения для ресурсов yandex_compute_image и yandex_compute_instance на отдельные переменные. К названиям переменных ВМ добавьте в начало префикс vm_web_ . Пример: vm_web_name.
> 2. Объявите нужные переменные в файле variables.tf, обязательно указывайте тип переменной. Заполните их default прежними значениями из main.tf.
> 3. Проверьте terraform plan. Изменений быть не должно.

```shell
terraform plan > plan.orig
# changes...
terraform plan > plan.new
# diff
diff -u plan.orig plan.new
```

![Result](files/ter-02-2.jpg)


```diff
diff --git a/02-ter/02/src/main.tf b/02-ter/02/src/main.tf
index 598a404..5d841ce 100644
--- a/02-ter/02/src/main.tf
+++ b/02-ter/02/src/main.tf
@@ -10,15 +10,16 @@ resource "yandex_vpc_subnet" "develop" {
 
 
 data "yandex_compute_image" "ubuntu" {
-  family = "ubuntu-2004-lts"
+  family = "${var.vm_web_family}"
 }
+
 resource "yandex_compute_instance" "platform" {
-  name        = "netology-develop-platform-web"
-  platform_id = "standard-v3"
+  name        = "${var.vm_web_name}"
+  platform_id = "${var.vm_web_platform_id}"
   resources {
-    cores         = 2
-    memory        = 1
-    core_fraction = 20
+    cores         = var.vm_web_cores
+    memory        = var.vm_web_memory
+    core_fraction = var.vm_web_core_fraction
   }
   boot_disk {
     initialize_params {
@@ -26,16 +27,16 @@ resource "yandex_compute_instance" "platform" {
     }
   }
   scheduling_policy {
-    preemptible = true
+    preemptible = var.vm_web_preemptible
   }
   network_interface {
     subnet_id = yandex_vpc_subnet.develop.id
-    nat       = true
+    nat       = var.vm_web_nat
   }
 
   metadata = {
-    serial-port-enable = 1
-    ssh-keys           = "ubuntu:${var.vms_ssh_root_key}"
+    serial-port-enable = var.vm_web_serial-port-enable
+    ssh-keys           = "${var.vms_ssh_root_user}:${var.vms_ssh_root_key}"
   }
 
 }
diff --git a/02-ter/02/src/variables.tf b/02-ter/02/src/variables.tf
index d56fb1d..d846d57 100644
--- a/02-ter/02/src/variables.tf
+++ b/02-ter/02/src/variables.tf
@@ -34,7 +34,70 @@ variable "vpc_name" {
 
 ###ssh vars
 
+variable "vms_ssh_root_user" {
+  type        = string
+  default     = "ubuntu"
+  description = "Admin's username"
+}
+
 variable "vms_ssh_root_key" {
   type        = string
   description = "ssh-keygen -t ed25519"
 }
+
+
+### VM vars
+
+variable "vm_web_family" {
+  type        = string
+  default     = "ubuntu-2004-lts"
+}
+
+variable "vm_web_name" {
+  type        = string
+  default     = "netology-develop-platform-web"
+}
+
+variable "vm_web_platform_id" {
+  type        = string
+  default     = "standard-v3"
+}
+
+variable "vm_web_cores" {
+  type        = number
+  default     = 2
+}
+
+variable "vm_web_memory" {
+  type        = number
+  default     = 1
+}
+
+variable "vm_web_core_fraction" {
+  type        = number
+  default     = 20
+}
+
+variable "vm_web_preemptible" {
+  type        = bool
+  default     = true
+}
+
+variable "vm_web_nat" {
+  type        = bool
+  default     = true
+}
+
+variable "vm_web_serial-port-enable" {
+  type        = number
+  default     = 1
+}
```


## Задание 3


> 1. Создайте в корне проекта файл 'vms_platform.tf' . Перенесите в него все переменные первой ВМ.
> 2. Скопируйте блок ресурса и создайте с его помощью вторую ВМ в файле main.tf: **"netology-develop-platform-db"** ,  ```cores  = 2, memory = 2, core_fraction = 20```. Объявите её переменные с префиксом **vm_db_** в том же файле ('vms_platform.tf').  ВМ должна работать в зоне "ru-central1-b"
> 3. Примените изменения.

```diff
diff --git a/02-ter/02/src/main.tf b/02-ter/02/src/main.tf
index 5d841ce..7ee489e 100644
--- a/02-ter/02/src/main.tf
+++ b/02-ter/02/src/main.tf
@@ -1,19 +1,26 @@
 resource "yandex_vpc_network" "develop" {
   name = var.vpc_name
 }
+
 resource "yandex_vpc_subnet" "develop" {
-  name           = var.vpc_name
+  name           = var.default_subnet_name
   zone           = var.default_zone
   network_id     = yandex_vpc_network.develop.id
   v4_cidr_blocks = var.default_cidr
 }
+resource "yandex_vpc_subnet" "develop-2" {
+  name           = var.develop-2_subnet_name
+  zone           = var.develop-2_zone
+  network_id     = yandex_vpc_network.develop.id
+  v4_cidr_blocks = var.develop-2_cidr
+}
 
 
-data "yandex_compute_image" "ubuntu" {
+data "yandex_compute_image" "image-web" {
   family = "${var.vm_web_family}"
 }
 
-resource "yandex_compute_instance" "platform" {
+resource "yandex_compute_instance" "platform-web" {
   name        = "${var.vm_web_name}"
   platform_id = "${var.vm_web_platform_id}"
   resources {
@@ -23,7 +30,7 @@ resource "yandex_compute_instance" "platform" {
   }
   boot_disk {
     initialize_params {
-      image_id = data.yandex_compute_image.ubuntu.image_id
+      image_id = data.yandex_compute_image.image-web.image_id
     }
   }
   scheduling_policy {
@@ -33,10 +40,40 @@ resource "yandex_compute_instance" "platform" {
     subnet_id = yandex_vpc_subnet.develop.id
     nat       = var.vm_web_nat
   }
-
   metadata = {
     serial-port-enable = var.vm_web_serial-port-enable
     ssh-keys           = "${var.vms_ssh_root_user}:${var.vms_ssh_root_key}"
   }
+}
+
 
+data "yandex_compute_image" "image-db" {
+  family = "${var.vm_db_family}"
+}
+
+resource "yandex_compute_instance" "platform-db" {
+  name        = "${var.vm_db_name}"
+  platform_id = "${var.vm_db_platform_id}"
+  zone        = "${var.vm_db_zone}"
+  resources {
+    cores         = var.vm_db_cores
+    memory        = var.vm_db_memory
+    core_fraction = var.vm_db_core_fraction
+  }
+  boot_disk {
+    initialize_params {
+      image_id = data.yandex_compute_image.image-db.image_id
+    }
+  }
+  scheduling_policy {
+    preemptible = var.vm_db_preemptible
+  }
+  network_interface {
+    subnet_id = yandex_vpc_subnet.develop-2.id
+    nat       = var.vm_db_nat
+  }
+  metadata = {
+    serial-port-enable = var.vm_db_serial-port-enable
+    ssh-keys           = "${var.vms_ssh_root_user}:${var.vms_ssh_root_key}"
+  }
 }
```

![Result](files/ter-02-3-1.jpg)

![Result](files/ter-02-3-2.jpg)
