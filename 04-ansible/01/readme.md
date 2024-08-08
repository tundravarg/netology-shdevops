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


Control node:

* SSH Client
    * Alpine: `apk add openssh`
    * Export env: `ANSIBLE_HOST_KEY_CHECKING: false`
* Ansible
    * Alpine: `apk add ansible`
        * Python will be automaticaly installed as a dependency.
    * Specific version:
        ```shell
        apk add python3 pipx
        pipx install --include-deps ansible==9.8.0
        pipx ensurepath
        source ~/.bashrc
        ```
        * NOTE: Текущая на данный момент версия Ansible Core 2.17 (Ansible 10.2.0) не поддерживает Python 3.6, который устанавливается в CentOS 7.
            Поэтому понижаем версию до 9.8.0, где эта проблема не воспроизводится.

Managed node:

* Python
    * Debian: `apt install -y python3`
    * CentOS: `yum install -y python3`
* SSH Server
    * Debian: `apt install -y openssh-server`
    * CentOS: `yum install -y openssh-server`
* User, is used to connect via ssh
    * Debian: `apt install -y sudo`
    * CentOS: `yum install -y sudo`
    * Create user for Ansible (see: "Cheat sheet" / "Add Ansible user")

Inventory:

* Прописываем переменные для SSH-доступа к управляемым хостам:
    * ansible_connection: ssh
    * ansible_user: ansbl
    * ansible_ssh_pass: password

* Зашифруем пароль:
    * `ansible-vault decrypt_string`
        * Потом при применении дешифруем через ключ `--ask-vault-pass` (пароль "vp")





## Cheat sheet


### Alpine

```shell
apk update
apk add <pkg-name>
```


### Debian

```shell
apt update -y
apt dist-upgrade -y
apt install -y <pkg-name>
```


### CentOS

> Репозитории и зеркала CentOS 7 теперь отключены, поэтому при запуске команд YUM возникают ошибки, связанные с Mirrorlist.centos.org. 

```shell
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
```


### Add Ansible user

```shell
useradd ansbl
printf "<password>\n<password>" | passwd ansbl
usermod -aG sudo ansbl
mkdir -p /home/ansbl && \
chown ansbl:ansbl /home/ansbl && \
```

NOTE: "sudo" group in Debian, "wheel" group in "CentOS".


### Docker

```shell
docker build --label ctrl-node --progress plain -f Dockerfile.ctrl .
docker compose up --build
docker compose rm -f
```
