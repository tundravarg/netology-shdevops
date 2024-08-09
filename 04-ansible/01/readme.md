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


### 1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте значение, которое имеет факт `some_fact` для указанного хоста при выполнении playbook.


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


### 2. Найдите файл с переменными (group_vars), в котором задаётся найденное в первом пункте значение, и поменяйте его на all default fact.

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


### 3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.


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

Результат запуска playbook:

```
Tuman $ ansible-playbook site.yml -i inventory/prod.yml 

PLAY [Print os facts] **************************************************************************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************************************************************************
ok: [ubuntu]
ok: [centos7]

TASK [Print OS] ********************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "CentOS"
}
ok: [ubuntu] => {
    "msg": "Ubuntu"
}

TASK [Print fact] ******************************************************************************************************************************************************************
ok: [centos7] => {
    "msg": "el"
}
ok: [ubuntu] => {
    "msg": "deb"
}

PLAY RECAP *************************************************************************************************************************************************************************
centos7                    : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
ubuntu                     : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```
