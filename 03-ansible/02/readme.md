# Домашнее задание к занятию 2 «Работа с Playbook»



## Подготовка к выполнению


### Links


> 1. Изучите, что такое [ClickHouse](https://www.youtube.com/watch?v=fjTNS2zkeBs) и [Vector](https://www.youtube.com/watch?v=CgEhyffisLY).


Links:
* ClickHouse
    * [ClickHouse (Oficial Site)](https://clickhouse.com/)
    * [Чем заменить Elasticsearch? Clickhouse - альтернатива (YouTube)](https://www.youtube.com/watch?v=fjTNS2zkeBs)
* Vector
    * [Vector (Oficial Site)](https://vector.dev/)
    * [Чем заменить logstash? Vector доставит (YouTube)](https://www.youtube.com/watch?v=CgEhyffisLY)


### Prepare hosts


> 4. Подготовьте хосты в соответствии с группами из предподготовленного playbook.


Используем локально запущенный Docker-контейнер.

`Dockerfile`:

```Dockerfile
FROM fedora:40
RUN yum install -y python3
CMD [ "sleep", "1d" ]
```

`docker-compose.yml`:

```yml
services:
  clickhouse:
    container_name: clickhouse-01
    image: ntlg-clickhouse:0.0.1
    build:
      context: .
```

Подключаемся через docker вместо ssh (`prod.yml`):

```yml
---
clickhouse:
  hosts:
    clickhouse-01:
      ansible_connection: docker
```

Добавляем тестовый play:

```yml
- name: Print OS facts
  tags:
    - test
  hosts: clickhouse
  tasks:
    - name: Print OS
      debug:
        msg: "{{ ansible_distribution }} {{ ansible_distribution_version }} {{ ansible_architecture }}"
```

Тестируем:

```
Tuman $ ansible-playbook site.yml -i inventory/prod.yml -t test

PLAY [Print OS facts] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [clickhouse-01]

TASK [Print OS] ********************************************************************************************************
ok: [clickhouse-01] => {
    "msg": "Fedora 40 x86_64"
}

PLAY [Install Clickhouse] **********************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [clickhouse-01]

PLAY RECAP *************************************************************************************************************
clickhouse-01              : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
