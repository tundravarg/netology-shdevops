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
