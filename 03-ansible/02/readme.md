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


## Основная часть


### Доработка playbook


При установке пакетов ClickHouse возникает ошибка: "Failed to validate GPG signature for clickhouse-common-static-22.3.3.44-1.x86_64: Package clickhouse-common-static-22.3.3.44.rpm is not signed".
Для её обхода добавляем параметр `disable_gpg_check: True`.

```diff
diff --git a/03-ansible/02/playbook/site.yml b/03-ansible/02/playbook/site.yml
@@ -30,6 +31,7 @@
     - name: Install clickhouse packages
       become: true
       ansible.builtin.yum:
+        disable_gpg_check: True
         name:
           - clickhouse-common-static-{{ clickhouse_version }}.rpm
           - clickhouse-client-{{ clickhouse_version }}.rpm
```

Т.к. запускается простой Docker-контейнер на базе Fedora, то в нём отсуствует systemd.
Поэтому запускаем ClickHouse как обычное приложение.

```diff
diff --git a/03-ansible/02/playbook/site.yml b/03-ansible/02/playbook/site.yml
@@ -12,9 +12,10 @@
   handlers:
     - name: Start clickhouse service
       become: true
-      ansible.builtin.service:
-        name: clickhouse-server
-        state: restarted
+      ansible.builtin.command:
+        argv:
+          - clickhouse-server
+          - --daemon
   tasks:
     - block:
         - name: Get clickhouse distrib
```

Запускае playbook:

```
Tuman $ ansible-playbook site.yml -i inventory/prod.yml

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

TASK [Get clickhouse distrib] ******************************************************************************************
changed: [clickhouse-01] => (item=clickhouse-client)
changed: [clickhouse-01] => (item=clickhouse-server)
failed: [clickhouse-01] (item=clickhouse-common-static) => {"ansible_loop_var": "item", "changed": false, "dest": "./clickhouse-common-static-22.3.3.44.rpm", "elapsed": 0, "item": "clickhouse-common-static", "msg": "Request failed", "response": "HTTP Error 404: Not Found", "status_code": 404, "url": "https://packages.clickhouse.com/rpm/stable/clickhouse-common-static-22.3.3.44.noarch.rpm"}

TASK [Get clickhouse distrib] ******************************************************************************************
changed: [clickhouse-01]

TASK [Install clickhouse packages] *************************************************************************************
changed: [clickhouse-01]

TASK [Flush handlers] **************************************************************************************************

RUNNING HANDLER [Start clickhouse service] *****************************************************************************
changed: [clickhouse-01]

TASK [Create database] *************************************************************************************************
changed: [clickhouse-01]

PLAY RECAP *************************************************************************************************************
clickhouse-01              : ok=7    changed=4    unreachable=0    failed=0    skipped=0    rescued=1    ignored=0
```

Проверяем:

```
[root@d61a45292699 ~]# ps ax
    PID TTY      STAT   TIME COMMAND
      1 ?        Ss     0:00 sleep 1d
      7 pts/0    Ss     0:00 bash
    462 ?        Ss     0:00 clickhouse-watchd --daemon
    463 ?        Sl     0:00 clickhouse-server --daemon
    701 pts/0    R+     0:00 ps ax
```
