Install LightHouse
==================


В файле `templates/lighthouse.conf` находится конфиг LightHouse для Nginx.
UI доступен на порту `8123`.
При входе на UI потребуется ввести URL ClickHouse.

Внимание!: URL ClickHouse будет вставлен в URL LightHouse, например: `http://89.169.132.227:8123/#http://89.169.129.127:8123`.
Вероятно в конце URL, появится завершающий слеш: `http://lighthouse-host:8123/#http://clickhouse-host:8123/`.
Это не будет работать, слеш надо удалить.

![LightHouse UI](files/lighthouse-ui.jpg)
