# Домашнее задание к занятию 7 «Жизненный цикл ПО»



## Установка Jira


Jira запущена посредством docker-compose, приведённым в каталоге `jira`.

Из особенностей:
* Через 90 дней триал протухнет, а он привязан к личному e-mail.
* Для того, чтобы данные в Jira не потерялись от запуска к запуску, был примонтирован volume.
    Но при старте контейнера он получил владельца, группу и права, отличные от моего пользовательского аккаунта.
    Т.о. пото придётся удалять его через `sudo`. А если бы админских прав не было...

![Screenshot](files/ci-01-jira.jpg)



## Создать доски Kanban и Scrum


![Screenshot](files/ci-01-kanban-board.jpg)

![Screenshot](files/ci-01-scrum-backlog.jpg)



## Workflow


![Screenshot](files/ci-01-bugflow.jpg)

[Bug flow.xml](files/Bug%20flow.xml)

![Screenshot](files/ci-01-simpleflow.jpg)

[Simple.xml](files/Simple.xml)

![Screenshot](files/ci-01-flow-assignment.jpg)

![Screenshot](files/ci-01-kanban-struct.jpg)

![Screenshot](files/ci-01-scrum-struct.jpg)


