# Ansible Control Node and Managed Nodes via SSH


> NOTE: Это вариант развёртывания Control Node и Managed Nodes в отдельных Docker-контейнерах и организация взаимодействия между ними через SSH.

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

* Используем secrets в Docker:
    * Прописываем глобальную секцию `secrets`:
        ```yml
        secrets:
            ansible_pwd:
                file: secrets/ansible-pwd.txt
        ```
    * Используем секрет в runtime или build;
        ```yml
        secrets:
            - ansible_pwd
        ```
    * Секрет будет примонтирован в `/run/secrets/<secret-name>`
    * В Dockerfile монтируем так: `RUN --mount=type=secret,id=<secret-name>` и считываем в переменную так: `export SECRET_ENV="$(cat /run/secrets/<secret-name>)".`


Test:

```shell
docker compose up --build
#
docker exec -it ctrl bash
#
cd playbook
ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass # pass: vp
```

```
ansible-playbook site.yml -i inventory/prod.yml --ask-vault-pass
Vault password: 

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
