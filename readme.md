# Домашнее задание к занятию 1. «Введение в виртуализацию»



## Задача 1


> Yandex Cloud

* Создать ВМ: Intel Ice Lake 2vCPU, fraction 20%, 2 Ram, 8Gb hdd, preemtible, public IP

* Создать SSH-ключ:

    ```shell
    mkdir -p ~/tmp/k
    cd ~/tmp/k

    ssh-keygen -t ed25519
    mv ./* ~/.ssh
    ```

* Подключиться к ВМ

    ```shell
    ssh -i ~/.ssh/key_name user_name@vm_public_ip
    ```

* Проверить версию docker

    ```shell
    docker --version
    ```

    > Docker version 20.10.21, build 20.10.21-0ubuntu1~22.04.3


## Задача 2


> Выберите один из вариантов платформы в зависимости от задачи. Здесь нет однозначно верного ответа так как все зависит от конкретных условий: финансирование, компетенции специалистов, удобство использования, надежность, требования ИБ и законодательства, фазы луны.

* высоконагруженная база данных MySql, критичная к отказу;

    * виртуализация уровня ОС

    Небольшие накладные расходы на виртуализацию.
    Легко масштабировать.
    В случае отказа можно легко и быстро развернуть другой образ, в т.ч. в друго ДЦ или другом регионе.
    Можно развернуть несколько (сколько угодно) реплик с репликацией.
    Стоимость ниже, чем для физических серверов.

* различные web-приложения;

    * виртуализация уровня ОС

    Всё вышеперечисленное.

* Windows-системы для использования бухгалтерским отделом;

    * паравиртуализация

    Поднимаем виртуалку/и с Windows, устанавливаем нужный софт.

* системы, выполняющие высокопроизводительные расчёты на GPU.

    * физические сервера | виртуализация уровня ОС

    Нужен доступ к "железу" с минимумом накладных расходов.
    Либо настраиваем нужный софт + драйвера на железе,
    либо настраиваем кластер с виртуализацией уровня ОС,
    где для каждой расчётной задачи или пакета задач будут выделяться расчётные узлы.
    В случае кластера можно распределять расчёты по имеющимся вычислительным узлам.



## Задача 3


> Выберите подходящую систему управления виртуализацией для предложенного сценария. Опишите ваш выбор.


* 100 виртуальных машин на базе Linux и Windows, общие задачи, нет особых требований. Преимущественно Windows based-инфраструктура, требуется реализация программных балансировщиков нагрузки, репликации данных и автоматизированного механизма создания резервных копий.

    Hyper-V

* Требуется наиболее производительное бесплатное open source-решение для виртуализации небольшой (20-30 серверов) инфраструктуры на базе Linux и Windows виртуальных машин.

    KVM, XEN

* Необходимо бесплатное, максимально совместимое и производительное решение для виртуализации Windows-инфраструктуры.

    Virtualbox, KVM, XEN


* Необходимо рабочее окружение для тестирования программного продукта на нескольких дистрибутивах Linux.

    Virtualbox, KVM, XEN



## Задача 4


> Опишите возможные проблемы и недостатки гетерогенной среды виртуализации (использования нескольких систем управления виртуализацией одновременно) и что необходимо сделать для минимизации этих рисков и проблем. Если бы у вас был выбор, создавали бы вы гетерогенную среду или нет?

В качестве основной проблемы гетерогенной среды виртуализации видится человеческий ресурс.
Для каждой среды требуются специалисты с необходимыми компетенциями и трудно найти специалиста, обладающего одновременно всеми необходимыми компетенциями.
Как следствие, требуется больше людей на настройку и сопровождение.

В такой среде больший спектр рисков и вариантов отказа.

Если говорить о большой компании, то для всех аспектов конфигурирования среды требуется документация и стандартизация.
Соответственно, чем больше разнообразия в среде, в которой развёртывается инфраструктура, тем больше аспектов нужно документировать (и держать документацию в актуальном состоянии) и стандартизировать.

> Если бы у вас был выбор, создавали бы вы гетерогенную среду или нет?

Если просто нужны СУБД, какие-то обычные web-сервисы, которые не требуют какой-то определённой платформы, Windows, напрмер, то зачем?
А если появляются такие требования, то и выбора нет:
всё что можно разворачиваем в контейнерах виртуализации уровня ОС,
что требует каких-то специфичных ОС - в системах паравиртуализации,
что имеет совсем специфичные требования, например ARM-процессора, - на железе.
