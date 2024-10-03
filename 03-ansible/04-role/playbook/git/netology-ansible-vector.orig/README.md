Install Vector
==============


В файле `templates/vector.yaml` находится конфигурация ввода-вывода Vector.

В частности его интеграция с Clickhouse:

```yml
sinks:
  clickhouse:
    inputs:
      - filein
    type: clickhouse
    endpoint: http://{{ hostvars.clickhouse.dn }}:8123
    database: logs
    table: file_log
    skip_unknown_fields: true
    auth:
      strategy: basic
      user: vector
      password: veve
```

В рамках среды учебного стенда Vector читает файл `/var/vector_input.txt`
и производит вывод в `stdout`, в файл `/var/vector_output.txt` и в Clickhouse, который работает на другом хосте.
