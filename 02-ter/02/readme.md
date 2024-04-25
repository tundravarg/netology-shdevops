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