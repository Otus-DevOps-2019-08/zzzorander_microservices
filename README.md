# zzzorander_microservices
zzzorander microservices repository

# Подготовка окружения (Ubuntu 19.10)
## Docker
- Docker Engine:
    sudo apt-get update
    sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    \# для 19.10 нет готовых пакетов докера, поэтому ставим из предыдущего релиза. Это плохая практика, но не откатывать же ради этого версию дистрибьютива.
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu disco stable"
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    \# Проверим, что все работает
    sudo docker run hello-world
  
- Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    \#  Проверяем все ли работает
    sudo docker-compose version

- Docker Machine
    base=https://github.com/docker/machine/releases/download/v0.16.0 &&  curl -L $base/docker-machine-$(uname -s)-$(uname -m) >/tmp/docker-machine &&
    sudo mv /tmp/docker-machine /usr/local/bin/docker-machine && chmod +x /usr/local/bin/docker-machine
    \# Проверяем все ли работает
    docker-machine version

## Cloud SDK
- Создаем проект Docker https://console.cloud.google.com/compute
- Устанавливаем https://cloud.google.com/sdk/
 
    \# Add the Cloud SDK distribution URI as a package source
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

    \# Import the Google Cloud Platform public key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

    \# Update the package list and install the Cloud SDK
    sudo apt-get update && sudo apt-get install google-cloud-sdk

- `gcloud init`
- Авторизуемся в Google
- Выбираем нужный проект
    Do you want to configure Google Compute Engine
    (https://cloud.google.com/compute) settings (Y/n)? n

- `gcloud auth application-default login`
- Входим в аккаунт google



# Docker-2

[![Build Status](https://travis-ci.com/Otus-DevOps-2019-08/zzzorander_microservices.svg?branch=docker-2)](https://travis-ci.com/Otus-DevOps-2019-08/zzzorander_microservices)

## Полезные команды
- `docker --help`
- `docker [COMMAND] --help` 
- `docker system df` - отображает сколько дискового пространства занято контейнерами образами и томами, какие из них не используются.
- `docker rm` - удалить неработающие контейнеры (`-f` - прибить и удалить работающие том числе.)
- `docker rmi` - удалить образы, от которых не зависят работающие контейнеры.
- `docker attach` - порисоединяет терминал к работающему контейнеру.
### Получить информацию
- `docker ps -a` - отображает все контейнеры ( без ключей - только запущенные)
### Создание-Запуск-Остановка-Подключение контейнеров
- `docker run` - создает из образа и запускает контейнер. Выдает ошибку, если контейнер с таким именем существует. Если имя контейнера не указано - присваиваются случайные имена.
    `docker run -it ubuntu:16.04 /bin/bash` - запустит контейнер с убунтой, запустит на контейнере `/bin/bash`, предоставит туда консоль (`-t` - tty ) и весь вывод ( `-i` - интерактивный режим ) 
- `docker create` - создает контейнер, но н запускает.
- `docker start` - запускает контейнер.
- `docker stop` - посылает сначала `SIGTERM`, а через (default=10) секунд `SIGKILL`
- `docker kill` - посылает контейнеру SIGKILL. 
    `docker kill $(docker ps -q)` - прибить все запущенные контейнеры

## HW 
- docker-machine  - встроенный в докер инструмент для создания хостов и установкинаних docker engine. Имеет поддержку облаков и систем виртуализации (Virtualbox, GCP идр.)
- Команда создания - `docker-machine create <имя>`. Имен может быть много, переключение между ними через `eval $(docker-machine env <имя>)`. 
- Переключение на локальный докер - `eval $(docker-machine env --unset)`. 
- Удаление - `docker-machine rm <имя>`.
- docker-machine создает хост для докер демона с указываемым образом в `--google-machine-image` 
- Все докер команды, которые запускаются в той же консоли после  `eval $(docker-machine env <имя>)` работают с удаленным докер демоном в GCP.
```
    export GOOGLE_PROJECT=docker-259815
    docker-machine create --driver google   --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts   --google-machine-type n1-standard-1    --google-zone europe-west1-b  docker-host

    $ docker-machine ls
    NAME          ACTIVE   DRIVER   STATE     URL                        SWARM   DOCKER     ERRORS
    docker-host   -        google   Running   tcp://35.233.127.23:2376           v19.03.5   
```
- Создаем папку `docker-monolith` и в нем следующие файлы:
- Dockerfile - текстовое описание нашего образа
- mongod.conf - подготовленный конфиг для mongodb
- db_config - содержит переменную окружения со ссылкой на mongodb
- start.sh - скриптзапускаприложения

- Заполняем вышеуказанные файлики из гистов.

- Запускаем `docker build -t reddit:latest .` (точка - путь к текущей директории , `-t` задает контейнеру тэг), чтобы докер собрал нам образ руоводствуясь `Dockerfile`
- `docker run --name reddit -d --network=host reddit:latest` - создаем контейнер из подготовленного образа и запускаем его.
```
docker-machine ls             
    NAME          ACTIVE   DRIVER   STATE     URL                        SWARM   DOCKER     ERRORS
    docker-host   -        google   Running   tcp://35.233.127.23:2376           v19.03.5   
```

- Заходим на `http://35.233.127.23:9292` видим, что ничего не произошло - у нас нет правила фаервола.
- Создаем правило firewall:
```
    gcloud compute firewall-rules create reddit-app  --allow tcp:9292    --target-tags=docker-machine    --description="Allow PUMA connections"    --direction=INGRESS          
```

- Заходим на `http://35.233.127.23:9292` видим, что все работает.

- Регистрируемся на Docker Hub, логинимся и заливаем туда наш образ:
```
    docker login
    UserName: zedzzorander
    Password:
    Login Succeeded
    docker tag reddit:latest zedzzorander/otus-reddit:1.0
    docker push zedzzorander/otus-reddit:1.0
```

- Проверяем, что все загрузилось и работает:
    `docker run --name reddit -d -p 9292:9292 zedzzorander/otus-reddit:1.0`

- Выполняем проверки:
 ```
    docker logs reddit -f
    about to fork child process, waiting until server is ready for connections.
    forked process: 8
    child process started successfully, parent exiting
    Puma starting in single mode...
    * Version 3.10.0 (ruby 2.3.1-p112), codename: Russell's Teapot
    * Min threads: 0, max threads: 16
    * Environment: development
    /reddit/helpers.rb:4: warning: redefining `object_id' may cause serious problems
    D, [2019-11-23T08:47:40.872307 #19] DEBUG -- : MONGODB | Topology type 'unknown' initializing.
    D, [2019-11-23T08:47:40.872537 #19] DEBUG -- : MONGODB | Server 127.0.0.1:27017 initializing.
    D, [2019-11-23T08:47:40.874808 #19] DEBUG -- : MONGODB | Topology type 'unknown' changed to type 'single'.
    D, [2019-11-23T08:47:40.874947 #19] DEBUG -- : MONGODB | Server description for 127.0.0.1:27017 changed from 'unknown' to 'standalone'.
    D, [2019-11-23T08:47:40.875045 #19] DEBUG -- : MONGODB | There was a change in the members of the 'single' topology.
    * Listening on tcp://0.0.0.0:9292
    Use Ctrl-C to stop
```

```
    docker exec -it reddit bash
      /# ps aux
      USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
      root         1  1.0  0.0  18028  1408 ?        Ss   22:14   0:00 /bin/bash /start.sh
      root         8  2.1  0.4 390372 33108 ?        Sl   22:14   0:00 /usr/bin/mongod --fork --logpath /var/log/mongod.log --config /etc/mongodb.conf
      root        19  3.1  0.3 513812 25436 ?        Sl   22:14   0:00 puma 3.10.0 (tcp://0.0.0.0:9292) [reddit]
      root        31  2.0  0.0  18232  2128 pts/0    Ss   22:15   0:00 bash
      root        45  0.0  0.0  34420  1768 pts/0    R+   22:15   0:00 ps aux
      /# killall5 1
      /# %  
```

```
    docker start reddit
      reddit
```

```
    docker stop reddit && docker rm reddit
      reddit
      reddit
```

```
    docker run --name reddit --rm -it zedzzorander/otus-reddit:1.0 bash
      root@702785e1dfcb:/# ps aux
      USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
      root         1  1.0  0.0  18232  1996 pts/0    Ss   22:19   0:00 bash
      root        15  0.0  0.0  34420  1564 pts/0    R+   22:19   0:00 ps aux
      root@702785e1dfcb:/# exit
      exit
```

- Выполняем еще проверки:
```
    docker inspect zedzzorander/otus-reddit:1.0
        [
            Wall of JSON text
        ]
```

```
    docker inspect zedzzorander/otus-reddit:1.0 -f '{{.ContainerConfig.Cmd}}'
    [/bin/sh -c #(nop)  CMD ["/start.sh"]]```
```

```
    docker run --name reddit -d -p 9292:9292 zedzzorander/otus-reddit:1.0
    docker exec -it reddit bash
        mkdir /test1234
        touch /test1234/testfile
        rmdir /opt
        exit
```

```
    docker diff reddit
    C /var
    C /var/lib
    C /var/lib/mongodb
    A /var/lib/mongodb/_tmp
    A /var/lib/mongodb/journal
    A /var/lib/mongodb/journal/j._0
    A /var/lib/mongodb/local.0
    A /var/lib/mongodb/local.ns
    A /var/lib/mongodb/mongod.lock
    C /var/log
    A /var/log/mongod.log
    C /root
    A /root/.bash_history
    A /test1234
    A /test1234/testfile
    C /tmp
    A /tmp/mongodb-27017.sock
    D /opt
```

```
    docker stop reddit && docker rm reddit
```    

```
    docker run --name reddit --rm -it zedzzorander/otus-reddit:1.0 bash
      root@6431531ac799:/# ls /
      bin  boot  dev  etc  home  lib  lib64  media  mnt  opt  proc  reddit  root  run  sbin  srv  start.sh  sys  tmp  usr  var
```
# Docker-microservices
## hw
- Подключился к хосту docker-host развернутому на предыдущем заниятии в GCP командой `eval $(docker-machine env docker-host)`
- Скачал архив `microservices.zip`  и распаковал его в папку с репозиторием. После распаковки архив удалил.
- Переименовал папку `reddit-microservices` в `src`
- Состав папки:
```
- post-py-сервис отвечающий за написание постов
- comment-сервис отвечающий за написание комментариев
- ui-веб-интерфейс,работающий с другими сервисами

```
- Содал Dockerfile для каждого микросервиса в репозитории
- Собираем образы:
```
   docker pull mongo:latest
   docker build -t zedzzorander/post:1.0 ./post-py
   docker build -t zedzzorander/comment:1.0 ./comment
   docker build -t zedzzorander/ui:1.0 ./ui
```
- Добавил в `src/post-py/Dockerfile` установку build-base мета-пакета, поскольку без него не ставятся зависимости, учел некторые рекомендации из лучшех практик.
- Создал сеть `reddit` и запустил контейнеры:
```
docker network create reddit
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post zedzzorander/post:1.0
docker run -d --network=reddit --network-alias=comment zedzzorander/comment:1.0
docker run -d --network=reddit -p 9292:9292 zedzzorander/ui:1.0
```
- Создал пост - Работает!

## HW * --env 
- Запускаем контейнеры сосвоими алиасами:
```
docker network create reddit
docker run -d --network=reddit --network-alias=my-post_db --network-alias=my-comment_db mongo:latest
docker run -d --network=reddit --network-alias=my-post --env POST_DATABASE_HOST=my-post_db zedzzorander/post:1.0 
docker run -d --network=reddit --network-alias=my-comment --env COMMENT_DATABASE_HOST=my-comment_db zedzzorander/comment:1.0 
docker run -d --network=reddit -p 9292:9292 --env POST_SERVICE_HOST=my-post --env COMMENT_SERVICE_HOST=my-comment zedzzorander/ui:1.0 
```
- Работает!

## hw images
- О - оптимизации. Перезаписываем  Dockerfile в папке src/ui/: `wget -O Dockerfile https://raw.githubusercontent.com/express42/otus-snippets/master/hw-16/%D0%A1%D0%B5%D1%80%D0%B2%D0%B8%D1%81%20ui%20-%20%D1%83%D0%BB%D1%83%D1%87%D1%88%D0%B0%D0%B5%D0%BC%20%D0%BE%D0%B1%D1%80%D0%B0%D0%B7`
- Пересобираем образ: 
```
% docker build -t zedzzorander/ui:2.0 ./ui
Sending build context to Docker daemon  30.72kB                                                                                                                                                             
Step 1/13 : FROM ubuntu:16.04                                                                                                                                                                               
 ---> 5f2bf26e3524 
...
Removing intermediate container f11c6c9eb063
 ---> 7df67873e2a6
Successfully built 7df67873e2a6
Successfully tagged zedzzorander/ui:1.0

```
- Сборка началась со второго шага, поскольку образ ubuntu:16.04 у нас уже загружен.


## hw volumes
- `docker kill $(docker ps -q)`
- Запукаем приложения заново:
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db mongo:latest
docker run -d --network=reddit --network-alias=post zedzzorander/post:1.0
docker run -d --network=reddit --network-alias=comment zedzzorander/comment:1.0
docker run -d --network=reddit -p 9292:9292 zedzzorander/ui:2.0
```
- Да, пост пропал, значит надо делать volume подключить его к контейнеру с БД и хранить базу данных на нем.
```
docker volume create reddit_db
```
- Убиваем запущеные контейнеры `docker kill $(docker ps -q)`
- Запускаем заново, но уже с volume
```
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post zedzzorander/post:1.0
docker run -d --network=reddit --network-alias=comment zedzzorander/comment:1.0
docker run -d --network=reddit -p 9292:9292 zedzzorander/ui:2.0
```
- Написали пост, перезапустили.
- Проверям - пост на месте. Отлично!

## HW* - images
- Соберем образы на базе alpine
