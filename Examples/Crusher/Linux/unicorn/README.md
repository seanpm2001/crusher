## Установка

Необходимо дополнительно установить поддержку qiling/unicorn в python фаззера, см. пункт _Частичная
эмуляция с помощью Unicorn/Qiling_ в документации к Crusher.

Также нужно запустить скрипт установки - `build.sh`

## Фаззинг с помощью unicorn

Инструментация работает ровно как статическая инструментация с форк сервером - запускается программа "обертка" (harness),
которая работает с измененным unicorn, который перед запуском включает форк сервер и таким образом общается
с фаззером.

Фундаментальной разницы нет на каком языке написана обертка, важно лишь то что она использует API, в котором реализован
протокол форк сервера.

## unicorn/c

Пример показывает как работает API unicorn-mode для языка c.

## unicorn/compcov_x64

Пример показывает как работает API unicorn-mode для языка Python 3.

## Замечание

Данный пример взят из [репозитория AFLplusplus](https://github.com/AFLplusplus/AFLplusplus/tree/stable/unicorn_mode)
