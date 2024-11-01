### Общее описание

Этот пример показывает фаззинг приложения для PDF-файлов (MuPDF)
при помощи нейросетей LLM (Large Language Model).
Нейросеть используется для обогащения начального корпуса входных данных
и для специальной мутации данных.

### Подготовка

Создайте docker-контейнер
(папка `<CRUSHER>` должна содержать папку с именем `crusher`,
чтобы внутри контейнера фаззер был доступен как `/home/opt/crusher`):

* `$ docker build --tag mupdf_fuzzer .`
* `$ docker run -it -v <CRUSHER>:/home/opt -v $(pwd):/fuzz --name <NAME> mupdf_fuzzer /bin/bash`

В контейнере выполните команды:

* `$ ./build.sh`
* `$ apt install ./libssl1.1_1.1.1f-1ubuntu2_amd64.deb ./libssl-dev_1.1.1f-1ubuntu2_amd64.deb`
* `$ /home/opt/crusher/bin_x86-64/python-3.9_x86_64/bin/python3 -m pip install openai pypdf`

Перед выполнением дальнейших команд запуска также нужно установить переменные окружения
`ISP_LLM_API_URL` (URL-адрес сервиса нейросетей по интерфейсу OpenAI) и
`ISP_LLM_API_KEY` (ключ для доступа к этому сервису).

### Обогащение корпуса

Выполните команду в контейнере:

`$ /home/opt/crusher/bin_x86-64/python-3.9_x86_64/bin/python3 /home/opt/crusher/bin_x86-64/Plugins/NeuralNetwork/enrich_pdf_corpus.py`

Скрипт ожидает, что в текущей директории находится папка `corpus` с PDF-файлами
и пустая папка `new_seeds`, куда будут сохранены файлы, сгенерированные нейросетью.

### Фаззинг со специальной мутацией

В контейнере в папке `/fuzz`:
    
`$ /home/opt/crusher/bin_x86-64/fuzz_manager --start 4 -i build/pdfs -o build/results --config-file config.json --eat-cores 2 --coverage-binary build_cov/pdf_fuzzer -- ./build/pdf_fuzzer __DATA__`

В конфигурационном JSON-файле указано использовать мутацию `llm_pdf_mutator`,
которая обращается к нейросети для мутирования данных.
Мутация реализована в `/home/opt/crusher/bin_x86-64/Plugins/mutation/llm_pdf_mutator.py`.

