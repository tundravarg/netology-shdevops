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


### Vector


См. [Role description](roles/vector/README.md).


### LightHouse


См. [Role description](roles/lighthouse/README.md).


## Теги


* `test` - проверить доступ до хостов и вывести информацию по ним
* `clickhouse` - установка, настрой и запуск ClickHouse
* `lighthouse` - установка, настрой и запуск LightHouse
* `vector` - установка, настрой и запуск Мector
