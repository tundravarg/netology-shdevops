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
