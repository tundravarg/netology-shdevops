# Playbook для настройки Vector, ClickHouse и LightHouse в Yandex Cloud


Данный playbook производит установку, настройку и запуск Vector, ClickHouse и LightHouse в Yandex Cloud.


## Конфигурация


### ClickHouse


Скрипт создания БД находится в файле `files/clickhouse/db.sql`.

```sql
---- Создаётся через role
-- CREATE DATABASE IF NOT EXISTS logs;

CREATE TABLE IF NOT EXISTS logs.file_log(
    message String
)
ENGINE = MergeTree()
ORDER BY tuple()
;
```


### Clickhouse


В файле `files/lighthouse/lighthouse.conf` находится конфиг LightHouse для Nginx.
UI доступен на порту `8123`.
При входе на UI потребуется ввести URL ClickHouse.

Внимание!: URL ClickHouse будет вставлен в URL LightHouse, например: `http://89.169.132.227:8123/#http://89.169.129.127:8123`.
Вероятно в конце URL, появится завершающий слеш: `http://lighthouse-host:8123/#http://clickhouse-host:8123/`.
Это не будет работать, слеш надо удалить.

![LightHouse UI](files/lighthouse-ui.jpg)


### Vector


В файле `files/vector/vector.yaml` находится конфигурация ввода-вывода Vector.

В частности его интеграция с Clickhouse:

```yml
sinks:
  clickhouse:
    inputs:
      - filein
    type: clickhouse
    endpoint: http://ntlg-a3-clickhouse:8123
    database: logs
    table: file_log
    skip_unknown_fields: true
```

В рамках среды учебного стенда Vector читает файл `/var/vector_input.txt`
и производит вывод в `stdout`, в файл `/var/vector_output.txt` и в Clickhouse, который работает на другом хосте.


## Теги


* `test` - проверить доступ до хостов и вывести информацию по ним
* `clickhouse` - установка, настрой и запуск ClickHouse
* `lighthouse` - установка, настрой и запуск LightHouse
* `vector` - установка, настрой и запуск Мector
