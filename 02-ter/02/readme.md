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