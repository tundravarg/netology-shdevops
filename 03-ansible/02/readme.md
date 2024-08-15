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


### Vector


> 1. Подготовьте свой inventory-файл `prod.yml`.
> 2. Допишите playbook: нужно сделать ещё один play, который устанавливает и настраивает [vector](https://vector.dev). Конфигурация vector должна деплоиться через template файл jinja2. От вас не требуется использовать все возможности шаблонизатора, просто вставьте стандартный конфиг в template файл. Информация по шаблонам по [ссылке](https://www.dmosk.ru/instruktions.php?object=ansible-nginx-install). не забудьте сделать handler на перезапуск vector в случае изменения конфигурации!
> 3. При создании tasks рекомендую использовать модули: `get_url`, `template`, `unarchive`, `file`.
> 4. Tasks должны: скачать дистрибутив нужной версии, выполнить распаковку в выбранную директорию, установить vector.


#### Установка Vector


`site.yml`:

```yml
- name: Install Vector
  tags:
    - vector
  hosts: vector
  tasks:
    - name: Download Vector
      ansible.builtin.get_url:
        url: https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-x86_64-unknown-linux-gnu.tar.gz
        dest: ./vector-{{ vector_version }}.tar.gz
    - name: Unarchive
      block:
        - ansible.builtin.unarchive:
            src: ./vector-{{ vector_version }}.tar.gz
            remote_src: true
            dest: "/opt"
        - ansible.builtin.file:
            src: /opt/vector-x86_64-unknown-linux-gnu
            dest: /opt/vector
            state: link
        - ansible.builtin.file:
            path: /etc/vector
            state: directory
        - ansible.builtin.file:
            path: /var/lib/vector
            state: directory
        - ansible.builtin.template:
            src: ./templates/vector.yaml
            dest: /etc/vector/vector.yaml
```

Переменные `group_vars/vector/vars.yml`:

```yml
vector_version: "0.40.0"
```

Inventory:

```yml
vector:
  hosts:
    ntlg-vector:
      ansible_connection: docker
```

Шаблон конфига `vector.yaml`:

```yml
sources:
  in:
    type: "stdin"

sinks:
  out:
    inputs:
      - "in"
    type: "console"
    encoding:
      codec: "text"
```

Запускаем Ansible:

```
Tuman $ ansible-playbook site.yml -i inventory/prod.yml -t vector

PLAY [Print OS facts] **************************************************************************************************

PLAY [Install Clickhouse] **********************************************************************************************

PLAY [Install Vector] **************************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [ntlg-vector]

TASK [Download Vector] *************************************************************************************************
changed: [ntlg-vector]

TASK [ansible.builtin.unarchive] ***************************************************************************************
changed: [ntlg-vector]

TASK [ansible.builtin.file] ********************************************************************************************
changed: [ntlg-vector]

TASK [ansible.builtin.file] ********************************************************************************************
changed: [ntlg-vector]

TASK [ansible.builtin.file] ********************************************************************************************
changed: [ntlg-vector]

TASK [ansible.builtin.template] ****************************************************************************************
changed: [ntlg-vector]

PLAY RECAP *************************************************************************************************************
ntlg-vector                : ok=7    changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Тестируем через подключение к контейнеру: `docker exec -it ntlg-vector bash`:

```
[root@0a28588645b4 ~]# cd /opt/vector/bin/
[root@0a28588645b4 bin]# ./vector 
2024-08-13T05:31:09.001394Z  INFO vector::app: Log level is enabled. level="info"
2024-08-13T05:31:09.002342Z  INFO vector::app: Loading configs. paths=["/etc/vector/vector.yaml"]
2024-08-13T05:31:09.003473Z  INFO vector::topology::running: Running healthchecks.
2024-08-13T05:31:09.003469Z  INFO vector::sources::file_descriptors: Capturing stdin.
2024-08-13T05:31:09.003527Z  INFO vector::topology::builder: Healthcheck passed.
2024-08-13T05:31:09.003536Z  INFO vector: Vector has started. debug="false" version="0.40.0" arch="x86_64" revision="1167aa9 2024-07-29 15:08:44.028365803"
2024-08-13T05:31:09.003552Z  INFO vector::app: API is disabled, enable by setting `api.enabled` to `true` and use commands like `vector top`.
Ololo
Ololo
Rerere
Rerere
```


#### Настройка ввода-вывода Vector


Будем вычитывать локальный файл и писать в другой локальный файл.

```yml
  vector:
    container_name: ntlg-vector
    ...
    volumes:
      - ${PWD}/vector_input.txt:/var/vector_input.txt
      - ${PWD}/vector_output.txt:/var/vector_output.txt
```

`vector.yaml`:

```yml
sources:
  filein:
    type: file
    include:
      - /var/vector_input.txt

sinks:
  stdout:
    inputs:
      - filein
    type: console
    encoding:
      codec: text
  fileout:
    inputs:
      - filein
    type: file
    path: /var/vector_output.txt
    encoding:
      codec: text
```

Запускаем/перезапускаем Vector при изменениях в ходе выполнения play:

```ymp
- name: Install Vector
  ...
  tasks:
    ...
    - name: Install
      ...
      notify: Start Vector service
  handlers:
    - name: Start Vector service
      become: true
      ansible.builtin.shell:
        cmd: |
          pkill -9 vector;
          nohup /opt/vector/bin/vector --watch-config &
```

После `pkill` стоит `;`, т.к. эта команда возвращает `1`, если ни одного процесса не убито.
Это не должно влиять на последующий запуск Vector.
Vector запускается через `nohup` и `&`, чтобы запуститься в фоне и отвязаться от родительского процесса (чтобы не подвешивать Ansible).

NOTE: В итоге сделан запуск Vector через обычную `task` (см. раздел ["Перезапуск Vector при каждом запуске playbook"](#restart-vector))

Проверяем:

```
Tuman$ cat vector_input.txt 
111
222
333
Tuman$ cat vector_output.txt 
---
111
222
333
Tuman$ echo hello >> vector_input.txt 
Tuman$ cat vector_input.txt 
111
222
333
hello
Tuman$ cat vector_output.txt 
---
111
222
333
hello
```


#### Интеграция Vector и Clichhouse


Создаём таблицу в Clickhouse для хранения логов от Vector:

```yml
- name: Create table
  ansible.builtin.command: "clickhouse-client -q 'CREATE TABLE IF NOT EXISTS logs.file_log(message String) ENGINE = MergeTree() ORDER BY tuple();'"
  register: create_db
  failed_when: create_db.rc != 0 and create_db.rc !=82
  changed_when: create_db.rc == 0
```

Включаем доступ к Clickhouse из-вне:

```yml
- name: Configure clickhouse
  become: true
  ansible.builtin.shell: |
    sed -i 's/<!-- <listen_host>0.0.0.0<\/listen_host> -->/<listen_host>0.0.0.0<\/listen_host>/g' /etc/clickhouse-server/config.xml
  notify: Start clickhouse service
```

Запускаем Clickhouse правильно: с конфигом и от имени пользователя `clickhouse`:

```yml
handlers:
  - name: Start clickhouse service
    become: true
    ansible.builtin.shell: |
      chown -R clickhouse:clickhouse /var/lib/clickhouse /var/log/clickhouse-server /etc/clickhouse-server /etc/clickhouse-client
      sudo -u clickhouse clickhouse server -C /etc/clickhouse-server/config.xml --daemon
```

Добавляем output в конфигурации Vector:

```yml
sinks:
  clickhouse:
    inputs:
      - filein
    type: clickhouse
    endpoint: http://ntlg-clickhouse:8123
    database: logs
    table: file_log
    skip_unknown_fields: true
```

Заупскаем и тестируем:

```
Tuman$ cat vector_output.txt 
---

Tuman$ docker exec ntlg-clickhouse clickhouse client --query 'SELECT * FROM logs.file_log'

Tuman$ echo "Hello, Clickhouse! I'm Vector." >> vector_input.txt 

Tuman$ cat vector_output.txt 
---
Hello, Clickhouse! I'm Vector.

Tuman$ docker exec ntlg-clickhouse clickhouse client --query 'SELECT * FROM logs.file_log'
Hello, Clickhouse! I\'m Vector.
```


#### Перезапуск Vector при каждом запуске playbook      <a id="restart-vector"></a>


При перезапуске Docker-контейнера, когда никаких изменений в конфигах не происходило, Vector никто не стартует.
Systemd в контейнере мы не запускаем.

В итоге, секция `handlers` была заменена на обычный `task`, чтобы перезапуск Vector происходил при каждом запуске Ansible.


```yml
block:
  ...
  - ansible.builtin.shell:
      cmd: |
        pkill -9 vector;
        nohup /opt/vector/bin/vector --watch-config 2>> /var/log/vector.log &
```
