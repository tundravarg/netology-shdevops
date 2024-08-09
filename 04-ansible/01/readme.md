# Домашнее задание к занятию 1 «Введение в Ansible»



## Подготовка к выполнению


### Установка Ansible


* https://www.ansible.com
* https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#intro-installation-guide


Если нет прав на установку пакетов глобально, нужно воспользоваться venv.

```shell
python3 -m pip -V
python3 -m venv .local
source .local/bin/activate
python3 -m pip install ansible
ansible --version
```



## Основная часть


### Task 1


> 1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте значение, которое имеет факт `some_fact` для указанного хоста при выполнении playbook.


```shell
ansible-playbook site.yml -i inventory/test.yml
```

```
Tuman $ ansible-playbook site.yml -i inventory/test.yml 

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
[WARNING]: Platform darwin on host localhost is using the discovered Python interpreter at
/Users/20154398/.local/myvenv/bin/python3.12, but future installation of another Python interpreter could change the
meaning of that path. See https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html
for more information.
ok: [localhost]

TASK [Print OS] ********************************************************************************************************
ok: [localhost] => {
    "msg": "MacOSX"
}

TASK [Print fact] ******************************************************************************************************
ok: [localhost] => {
    "msg": 12
}

PLAY RECAP *************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```


### Task 2


> 2. Найдите файл с переменными (group_vars), в котором задаётся найденное в первом пункте значение, и поменяйте его на all default fact.


`04-ansible/01/playbook/group_vars/all/examp.yml`:

```yml
---
  some_fact: all default fact
```

```
Tuman $ ansible-playbook site.yml -i inventory/test.yml 

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
[WARNING]: Platform darwin on host localhost is using the discovered Python interpreter at
/Users/20154398/.local/myvenv/bin/python3.12, but future installation of another Python interpreter could change the
meaning of that path. See https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html
for more information.
ok: [localhost]

TASK [Print OS] ********************************************************************************************************
ok: [localhost] => {
    "msg": "MacOSX"
}

TASK [Print fact] ******************************************************************************************************
ok: [localhost] => {
    "msg": "all default fact"
}

PLAY RECAP *************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


### Task 3


> 3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.


NOTE: В каталоге `ansible-ssh` - вариант развёртывания стенда, где Ansible Control Node и Managed Nodes разворачиваются каждый в своём контейнере и Ansible взаимодействует с ними посредством SSH. Здесь работаем через подключение `docker`.

Установленный через `pip install ansible` ansible-10.2.0 (ansible-core 2.17.2) не работает с python-3.6, который устанавливается в CentOS 7.
Поэтому, понижаем версию Ansible до версии, которая работает нормально (ansible-9.8.0):

```shell
pip uninstall ansible ansible-core
pip install ansible==9.8.0
```

Делаем это в venv:

```shell
venv .venv
source .venv/bin/activate
# Работаем с ansible здесь
deactivate
```


### Task 4


> 4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.


Результат запуска playbook:

```
Tuman $ ansible-playbook site.yml -i inventory/prod.yml 

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ********************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP *************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```


### Task 5, 6


> 5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились значения: для `deb` — `deb default fact`, для `el` — `el default fact`.
> 6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.


```diff
diff --git a/04-ansible/01/playbook/group_vars/deb/examp.yml b/04-ansible/01/playbook/group_vars/deb/examp.yml
@@ -1,2 +1,3 @@
 ---
-  some_fact: "deb"
+  some_fact: "deb default fact"

diff --git a/04-ansible/01/playbook/group_vars/el/examp.yml b/04-ansible/01/playbook/group_vars/el/examp.yml
@@ -1,2 +1,3 @@
 ---
-  some_fact: "el"
+  some_fact: "el default fact"
```

```
Tuman $ ansible-playbook site.yml -i inventory/prod.yml 

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ********************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


### Task 7, 8


> 7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
> 8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.


```shell
ansible-vault encrypt group_vars/deb/examp.yml group_vars/el/examp.yml
# New Vault password: netology
```

```shell
Tuman $ ansible-playbook site.yml -i inventory/prod.yml

PLAY [Print os facts] **************************************************************************************************
ERROR! Attempting to decrypt but no vault secrets found
```

Без ключа `--ask-vault-pass` почему-то пароль не спрашивает и выдаёт ошибку.
С ключём всё работает, как надо.

```shell
Tuman $ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: # netology

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ********************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


### Task 9, 10, 11


> 9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
> 10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
> 11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь, что факты `some_fact` для каждого из хостов определены из верных `group_vars`.


```
Tuman $ ansible-doc -t connection -l
ansible.builtin.local          execute on controller
...
```

```diff
diff --git a/04-ansible/01/playbook/inventory/prod.yml b/04-ansible/01/playbook/inventory/prod.yml
@@ -1,4 +1,8 @@
 ---
+  local:
+    hosts:
+      localhost:
+        ansible_connection: local
   el:
     hosts:
       centos7:
```

```
Tuman $ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: # netology

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
[WARNING]: Platform darwin on host localhost is using the discovered Python interpreter at
/Users/20154398/.local/myvenv/bin/python3.12, but future installation of another Python interpreter could change the
meaning of that path. See https://docs.ansible.com/ansible-core/2.16/reference_appendices/interpreter_discovery.html
for more information.
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ********************************************************************************************************
ok: [localhost] => {
    "msg": "MacOSX"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************
ok: [localhost] => {
    "msg": 12
}
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}

PLAY RECAP *************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```



## Необязательная часть


### Extra Task 1


> 1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.


```shell
Tuman $ ansible-vault decrypt group_vars/deb/examp.yml group_vars/el/examp.yml 
Vault password: # netology
Decryption successful
```

```diff
diff --git a/04-ansible/01/playbook/group_vars/deb/examp.yml b/04-ansible/01/playbook/group_vars/deb/examp.yml
index 61f55af..0dd359b 100644
--- a/04-ansible/01/playbook/group_vars/deb/examp.yml
+++ b/04-ansible/01/playbook/group_vars/deb/examp.yml
@@ -1,7 +1,2 @@
-$ANSIBLE_VAULT;1.1;AES256
-32366336626336363437643830353436376561373763363838613631393562626237333764346563
-6264613638306266623465343363633532383530383933610a306265333039313363356561386263
-37326563636664626137666338323839336439373137616565623463343032336338663931633232
-3030646263323863320a616464343663366635633538373933363161366665323132613331393563
-34646431363839663964663366613132313163663436633138373532303034336430663663356164
-6131353938336330336231343132646439316466663635323532
+---
+  some_fact: "deb default fact"
\ No newline at end of file
diff --git a/04-ansible/01/playbook/group_vars/el/examp.yml b/04-ansible/01/playbook/group_vars/el/examp.yml
index 95585c0..dcbf0bc 100644
--- a/04-ansible/01/playbook/group_vars/el/examp.yml
+++ b/04-ansible/01/playbook/group_vars/el/examp.yml
@@ -1,7 +1,2 @@
-$ANSIBLE_VAULT;1.1;AES256
-34646330336663306561643466326263633834333065386335393739626236613839316334343665
-3436336563613064383065653231313565393430336434640a396439613863663834666565316338
-34363931356534366131646333323030336639653561666532333435383134366331633633626165
-6534643438306237620a396536653238333838333136623736303937616164363762366664396331
-65393462656564333764363836643933333731626366363866303336356165643765303961663335
-3939386134316366396534636463636461326661626261306332
+---
+  some_fact: "el default fact"
\ No newline at end of file
```


### Extra Task 2, 3


> 2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/exmp.yml`.
> 3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.


```shell
$ ansible-vault encrypt_string
New Vault password: # netology
Confirm New Vault password: # netology
Reading plaintext input from stdin. (ctrl-d to end input, twice if your content does not already have a newline)
PaSSw0rd^D
Encryption successful
!vault |
          $ANSIBLE_VAULT;1.1;AES256
          65316633613461326536303638356335303230306339396363646265373131653533376238626266
          3062643761633435336330613035366561636339313630650a366434393363366263663064653463
          37626138613163353436643866333038376565396562656136623065323938626563623962663234
          3062386339323063320a656539613331356632333864376633326662646661323637313265323833
          3837
```

```diff
diff --git a/04-ansible/01/playbook/group_vars/all/examp.yml b/04-ansible/01/playbook/group_vars/all/examp.yml
index aae0182..184ba7b 100644
--- a/04-ansible/01/playbook/group_vars/all/examp.yml
+++ b/04-ansible/01/playbook/group_vars/all/examp.yml
@@ -1,2 +1,8 @@
 ---
-  some_fact: 12
\ No newline at end of file
+  some_fact: !vault |
+    $ANSIBLE_VAULT;1.1;AES256
+    65316633613461326536303638356335303230306339396363646265373131653533376238626266
+    3062643761633435336330613035366561636339313630650a366434393363366263663064653463
+    37626138613163353436643866333038376565396562656136623065323938626563623962663234
+    3062386339323063320a656539613331356632333864376633326662646661323637313265323833
+    3837
\ No newline at end of file
```

```
Tuman $ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: # netology

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
[WARNING]: Platform darwin on host localhost is using the discovered Python interpreter at
/Users/20154398/.local/myvenv/bin/python3.12, but future installation of another Python interpreter could change the
meaning of that path. See https://docs.ansible.com/ansible-core/2.16/reference_appendices/interpreter_discovery.html
for more information.
ok: [localhost]
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ********************************************************************************************************
ok: [localhost] => {
    "msg": "MacOSX"
}
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "PaSSw0rd"
}

PLAY RECAP *************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


### Extra Task 4


> 4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот вариант](https://hub.docker.com/r/pycontribs/fedora).


```diff
diff --git a/04-ansible/01/fedora.Dockerfile b/04-ansible/01/fedora.Dockerfile
new file mode 100644
index 0000000..dca03b2
--- /dev/null
+++ b/04-ansible/01/fedora.Dockerfile
@@ -0,0 +1,9 @@
+FROM fedora:40
+
+RUN yum install -y python3
+
+WORKDIR /init
+
+COPY init.sh ./
+
+CMD [ "bash", "init.sh" ]

diff --git a/04-ansible/01/docker-compose.yml b/04-ansible/01/docker-compose.yml
index 2d8d8a9..8ad8773 100644
--- a/04-ansible/01/docker-compose.yml
+++ b/04-ansible/01/docker-compose.yml
@@ -17,3 +17,12 @@ services:
       dockerfile: centos7.Dockerfile
     environment:
       MSG: "centos7"
+
+  fedora:
+    container_name: fedora
+    image: fedora:0.0.1
+    build:
+      context: .
+      dockerfile: fedora.Dockerfile
+    environment:
+      MSG: "fedora"

diff --git a/04-ansible/01/playbook/inventory/prod.yml b/04-ansible/01/playbook/inventory/prod.yml
index 3b64a2b..d3397db 100644
--- a/04-ansible/01/playbook/inventory/prod.yml
+++ b/04-ansible/01/playbook/inventory/prod.yml
@@ -10,4 +10,8 @@
   deb:
     hosts:
       ubuntu:
+        ansible_connection: docker
+  fedora:
+    hosts:
+      fedora:
         ansible_connection: docker
\ No newline at end of file

diff --git a/04-ansible/01/playbook/group_vars/fedora/examp.yml b/04-ansible/01/playbook/group_vars/fedora/examp.yml
new file mode 100644
index 0000000..db4e425
--- /dev/null
+++ b/04-ansible/01/playbook/group_vars/fedora/examp.yml
@@ -0,0 +1,2 @@
+---
+  some_fact: "fedora default fact"
\ No newline at end of file

diff --git a/04-ansible/01/playbook/site.yml b/04-ansible/01/playbook/site.yml
index 2f9930d..ffbd6d3 100644
--- a/04-ansible/01/playbook/site.yml
+++ b/04-ansible/01/playbook/site.yml
@@ -4,7 +4,7 @@
     tasks:
       - name: Print OS
         debug:
-          msg: "{{ ansible_distribution }}"
+          msg: "{{ ansible_distribution }} {{ ansible_distribution_version }} {{ ansible_architecture }}"
       - name: Print fact
         debug:
           msg: "{{ some_fact }}"
\ No newline at end of file
```

```
$ Tuman $ ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: 
[WARNING]: Found both group and host with same name: fedora

PLAY [Print os facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
[WARNING]: Platform darwin on host localhost is using the discovered Python interpreter at
/Users/20154398/.local/myvenv/bin/python3.12, but future installation of another Python interpreter could change the
meaning of that path. See https://docs.ansible.com/ansible-core/2.16/reference_appendices/interpreter_discovery.html
for more information.
ok: [localhost]
ok: [ubuntu]
ok: [fedora]
ok: [centos7]

TASK [Print OS] ********************************************************************************************************
ok: [localhost] => {
    "msg": "MacOSX 14.5 arm64"
}
ok: [centos7] => {
    "msg": "CentOS 7.9 aarch64"
}
ok: [ubuntu] => {
    "msg": "Ubuntu 24.10 aarch64"
}
ok: [fedora] => {
    "msg": "Fedora 40 aarch64"
}

TASK [Print fact] ******************************************************************************************************
ok: [centos7] => {
    "msg": "el default fact"
}
ok: [ubuntu] => {
    "msg": "deb default fact"
}
ok: [localhost] => {
    "msg": "PaSSw0rd"
}
ok: [fedora] => {
    "msg": "fedora default fact"
}

PLAY RECAP *************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
fedora                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
