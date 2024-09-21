# Домашнее задание к занятию 11 «Teamcity»



## Подготовка к выполнению


> 1. В Yandex Cloud создайте новый инстанс (4CPU4RAM) на основе образа `jetbrains/teamcity-server`.
> 2. Дождитесь запуска teamcity, выполните первоначальную настройку.


https://hub.docker.com/r/jetbrains/teamcity-server

* Teamcity Server UI: http://<teamcity_url>:8111
* admin / admin123


> 3. Создайте ещё один инстанс (2CPU4RAM) на основе образа `jetbrains/teamcity-agent`. Пропишите к нему переменную окружения `SERVER_URL: "http://<teamcity_url>:8111"`.


https://hub.docker.com/r/jetbrains/teamcity-agent/

Переменную окружения указываем при создании ВМ, когда указываем образ.

В Temacity Server UI через некоторое время (~4 мин.) после старта ВМ агента в разделе `Unauthorized Agents` появится этот агент.
Там его и авторизуем.


> 6. Создайте VM (2CPU4RAM) и запустите [playbook](./infrastructure).


На `CentOS 7` playbook отрабатывает нормально.

Если используется `Fedora`, то нужны дополнения.

* Нужно установить ACL, иначе завалится шаг "Download Nexus":

    ```yml
        - name: Install ACL
          become: true
          package:
            name: [acl]
            state: present
    ```

* Отключаем SELinux, иначе не стартует Nexus:

    ```yml
        - name: Disable SELinux
          become: true
          shell: setenforce 0
    ```

* Nexus UI: http://<nexus_url>:8081
* admin / admin123


> 5. Сделайте fork [репозитория](https://github.com/aragastmatb/example-teamcity).


* Github: https://github.com/tundravarg/netology-example-teamcity
