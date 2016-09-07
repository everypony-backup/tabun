Запуск проекта
==============

Для начала необходимо установить [vagga](http://vagga.readthedocs.io/en/latest/installation.html#ubuntu) (из репозитория *testing*)

Затем — инициализировать БД

    vagga _init_db
    
Загрузить фикстуры

    vagga _load_fitures

Собрать статику

    vagga build-static

Запустить проект

    vagga run

Другое
======

* cправка по отдельным командам — `vagga` без аргументов
* данные `!Persistent` томов доступны в `.vagga/.volumes/`