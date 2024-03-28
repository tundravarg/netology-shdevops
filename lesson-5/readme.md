# Домашнее задание к занятию 5. «Практическое применение Docker»



## Задача 0


> Убедитесь что у вас НЕ(!) установлен `docker-compose`.
> Убедитесь что у вас УСТАНОВЛЕН `docker compose` (без тире) версии не менее `v2.24.X`.

![Результат](img/task-0.jpg "Результат")



## Задача 1


> Сделайте в своем github пространстве fork репозитория ```https://github.com/netology-code/shvirtd-example-python/blob/main/README.md```.

Клон репозиториядобавлен, как подмодуль:
https://github.com/tundravarg/netology-shvirtd-example-python.git .

```shell
git submodule update
```

> Создайте файл с именем Dockerfile.python для сборки данного проекта(для 3 задания изучите https://docs.docker.com/compose/compose-file/build/ ). Используйте базовый образ python:3.9-slim. Протестируйте корректность сборки. Не забудьте dockerignore.

```shell
docker build -f Dockerfile.python -t py-service .
docker run --name mysql -it --rm --env-file .env -p 3306:3306 mysql
docker run --name py-service -it --rm --env-file .env --net host py-service
docker rm -f mysql
```

![Результат](img/task-1.jpg "Результат")

### venv

```shell
python3 -m venv ./venv/
. ./venv/bin/activate
pip install -r requirements.txt
set -a; . ./.env; set +a
python3 main.py
```

### .env

При использовании `--env-file .env` из значений не удаляются каыфчки.
Поэтому пользователи и пароли в Mysql прописываются, как есть - с кавычками.
И при запуске python приложения они тоже начинают использоваться с кавычками, в результате происходит ошибка синтаксиса SQL-запроса.
Поэтому кавычки были убраны из этого файла.
Кроме того были прописаны пременные для python, чтобы использовать один `.env` файл.

```diff
diff --git a/.env b/.env
index 0406ce6..5fb71a6 100644
--- a/.env
+++ b/.env
@@ -1,5 +1,9 @@
-MYSQL_ROOT_PASSWORD="YtReWq4321"
+MYSQL_ROOT_PASSWORD=YtReWq4321
+MYSQL_DATABASE=virtd
+MYSQL_USER=app
+MYSQL_PASSWORD=QwErTy1234
 
-MYSQL_DATABASE="virtd"
-MYSQL_USER="app"
-MYSQL_PASSWORD="QwErTy1234"
+DB_HOST=127.0.0.1
+DB_NAME=virtd
+DB_USER=app
+DB_PASSWORD=QwErTy1234
```
