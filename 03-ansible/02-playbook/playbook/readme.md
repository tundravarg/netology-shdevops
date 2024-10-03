# Учебный playbook для настройки Vector и Clickhouse


Данный playbook производит установку, настройку и запуск Clickhouse и Vector в запущенных docker-контейнерах.


## Конфигурация


### Clickhouse


Параметры Clickhouse находятся в файле `group_vars/clickhouse/vars.yml`.

```yml
clickhouse_version: "22.3.3.44"
clickhouse_packages:
  - clickhouse-client
  - clickhouse-server
  - clickhouse-common-static
```


### Vector


Параметры Vector находятся в файле `group_vars/vector/vars.yml`.

```yml
vector_version: "0.40.0"
```

Также в `templates/vector.yaml` находится конфигурация ввода-вывода Vector.

В частности его интеграция с Clickhouse:

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

В рамках среды учебного стенда Vector читает файл `/var/vector_input.txt`
и производит вывод в `stdout`, в файл `/var/vector_output.txt` и в Clickhouse, который работает на другом хосте.


## Теги


* `test` - проверить доступ до хостов и вывести информацию по ним
* `clickhouse` - установка, настрой и запуск Clickhouse
* `vector` - установка, настрой и запуск Мector
