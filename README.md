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
# Docker-3
[![Build Status](https://travis-ci.com/Otus-DevOps-2019-08/zzzorander_microservices.svg?branch=docker-3)](https://travis-ci.com/Otus-DevOps-2019-08/zzzorander_microservices)
## HW
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

## HW images
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


## HW тома
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

## HW* оптимизация размера образов
- Собраны образы для `ui` и `comment` на базе `ruby:2.3-alpine`
- Изменены устаревшие директивы `bundler --no-ri --no-rdoc` на `bundler --no-document`
- Добавлена директива очистки кэша менеджера пакетов.
- Размер образа уменьшился с 771MB до 298MB

# Docker-4
## Сети и Docker
- Используем готовый контейнер, чтобы изучить как работают сети.
- Первый прогон -network none:
```
docker run -ti --rm --network none joffotron/docker-net-tools -c ifconfig
...
lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```
- Второй запуск --network host
```
docker run -ti --rm --network host joffotron/docker-net-tools -c ifconfig
...
br-ebe0446d49fa Link encap:Ethernet  HWaddr 02:42:F0:04:CF:12  
          inet addr:172.18.0.1  Bcast:172.18.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:f0ff:fe04:cf12%32543/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:210 errors:0 dropped:0 overruns:0 frame:0
          TX packets:224 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:63595 (62.1 KiB)  TX bytes:51610 (50.4 KiB)

docker0   Link encap:Ethernet  HWaddr 02:42:BF:EF:01:C9  
          inet addr:172.17.0.1  Bcast:172.17.255.255  Mask:255.255.0.0
          inet6 addr: fe80::42:bfff:feef:1c9%32543/64 Scope:Link
          UP BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:31786 errors:0 dropped:0 overruns:0 frame:0
          TX packets:38645 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:2507896 (2.3 MiB)  TX bytes:835278696 (796.5 MiB)

ens4      Link encap:Ethernet  HWaddr 42:01:0A:84:00:02  
          inet addr:10.132.0.2  Bcast:10.132.0.2  Mask:255.255.255.255
          inet6 addr: fe80::4001:aff:fe84:2%32543/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1460  Metric:1
          RX packets:317135 errors:0 dropped:0 overruns:0 frame:0
          TX packets:269444 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1869597769 (1.7 GiB)  TX bytes:266939337 (254.5 MiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1%32543/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:897237 errors:0 dropped:0 overruns:0 frame:0
          TX packets:897237 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:122021654 (116.3 MiB)  TX bytes:122021654 (116.3 MiB)
```
- Интерфейсы идентичны интерфесам docker-host
- Запустил несколько раз команду `docker run --network host -d nginx`
- `docker ps` выдает в списке всего один контейнер.
- `sudo ln -s /var/run/docker/netns /var/run/netns` -  делаем на docker-host. Теперь можно сделать `docker-machine ssh docker-host`, а потом `sudo ip netns monitor` и наблюдать что происходит с сетевыми неймспейсами на хосте или пролистать их командой `sudo ip netns list`
- При создании контейнера из вышерассмотреных создается новый неймспейс, а после удаление - удаляется в независимости от типа указываемого в  `--network`
### Bridge networks
- Создаем новый мост - `docker network create reddit --driver bridge` (`--driver bridge` - используется по умолчанию, поэтому это значение в команде можно опускать)
- Запускаю проект и с использованием bridge сети ( как и до этого, но уже осознано ):
```
docker run -d --network=reddit -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit zedzzorander/post:1.0
docker run -d --network=reddit zedzzorander/comment:1.0
docker run -d --network=reddit -p 9292:9292 zedzzorander/ui:2.0
```
- Спотыкаюсь об отсутствие алиасов, исправляю их:
```
docker kill $(docker ps -q)
docker run -d --network=reddit --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
docker run -d --network=reddit --network-alias=post zedzzorander/post:1.0
docker run -d --network=reddit --network-alias=comment zedzzorander/comment:1.0
docker run -d --network=reddit -p 9292:9292 zedzzorander/ui:2.0
```
- Есть два варианта для имен - можно назначить одно имя директивой `--name NAME` или несколько через уже знакомую `--network-alias`
- Заходим на наш сайт - все работает (ура!)
### MultiBridge - запускаем два моста и добавляем часть контейнеров в оба.
- У нас будет `front_net` (ui, comment, post) и `back_net` (db, comment, post)
- Расчищу место - `docker kill $(docker ps -q)`
- Создам сети:
```
docker network create back_net --subnet=10.0.2.0/24 
docker network create front_net --subnet=10.0.1.0/24
```
- Создам машины:
```
docker run -d --network=front_net -p 9292:9292 --name ui  zedzzorander/ui:1.0
docker run -d --network=back_net --name comment  zedzzorander/comment:1.0
docker run -d --network=back_net --name post  zedzzorander/post:1.0
docker run -d --network=back_net --name mongo_db --network-alias=post_db --network-alias=comment_db -v reddit_db:/data/db mongo:latest
```
- Захожу на страничку нашего приложения и вижу, что ничего не работает. Это потому что машины в разных мостах и не видят друг-друга, потому что докер не может подключит больше одной сети при инициализации контейнера. Нам придется делать это самим.
- Исправляю это досадную недоработку, мужественным копипастом из методички:
```
docker network connect front_net post 
docker network connect front_net comment 
```
- Проверяю - все работает (ура!)

- Подключаюсь к нашему хосту с докером, и устанавливаю необходмые утилиты:
```
docker-machine ssh docker-host
sudo apt-get update && sudo apt-get install bridge-utils
```
- Изучаю получившиеся в результате моей деятельности сети:
```
docker-user@docker-host:~$ sudo docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
96de712b0fcb        back_net            bridge              local
a84e556505d0        bridge              bridge              local
dd6963210e9f        front_net           bridge              local
4a54a878b30f        host                host                local
fbc791e848a0        none                null                local
ebe0446d49fa        reddit              bridge              local
```
- Использую команду `ifconfig | grep br`, чтобы отобразить доступные нам bridge
```
ifconfig | grep br
br-96de712b0fcb Link encap:Ethernet  HWaddr 02:42:da:af:a3:93  
br-dd6963210e9f Link encap:Ethernet  HWaddr 02:42:47:57:bc:8c  
br-ebe0446d49fa Link encap:Ethernet  HWaddr 02:42:f0:04:cf:12  
```
- Посмотрим, какие инерфейсы учавствуют в bridge
```
brctl show br-96de712b0fcb
bridge name     bridge id               STP enabled     interfaces
br-96de712b0fcb         8000.0242daafa393       no              veth049f3ba
                                                        veth385559e
                                                        veth63adf6c
```
- Теперь посмотрим на `iptables`
```
$ sudo iptables -nL -t nat
Chain PREROUTING (policy ACCEPT)
target     prot opt source               destination         
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

Chain INPUT (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy ACCEPT)
target     prot opt source               destination         
DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL

Chain POSTROUTING (policy ACCEPT)
target     prot opt source               destination         
MASQUERADE  all  --  10.0.1.0/24          0.0.0.0/0           #
MASQUERADE  all  --  10.0.2.0/24          0.0.0.0/0           # Правила, отвещающие за выход во внешнюю сеть.
MASQUERADE  all  --  172.18.0.0/16        0.0.0.0/0           #
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0           #
MASQUERADE  tcp  --  10.0.1.2             10.0.1.2             tcp dpt:9292

Chain DOCKER (2 references)
target     prot opt source               destination         
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
RETURN     all  --  0.0.0.0/0            0.0.0.0/0           
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:9292 to:10.0.1.2:9292 # Публикация порта для нашего UI

```
- Посмотрю на docker-proxy:
```
$ ps ax | grep docker-proxy
 1839 ?        Sl     0:00 /usr/bin/docker-proxy -proto tcp -host-ip 0.0.0.0 -host-port 9292 -container-ip 10.0.1.2 -container-port 9292
10993 pts/0    S+     0:00 grep --color=auto docker-proxy
```
## Docker Compose
### Проблемы решаемые композом
- Одно приложение состоит из множества контейнеров/сервисов
- Один контейнер зависит от другого
- Порядок запуска имеет значение
- docker build/run/create ... (долго и много)
### Описание
- Отдельная утилита
- Декларативное описание в YAML формате
- Управление многоконтейнерными приложениями
### Установка
- Не буду скромничать, и поставлю его system-wide 
```
sudo pip3 install docker-compose
```
### Настройка
- Загрузим из гиста `wget -O docker-compose.yml https://raw.githubusercontent.com/express42/otus-snippets/master/hw-17/docker-compose.yml`
- docker-compose поддерживает интерполяцию переменных окружения, и мы будет это использовать
```
export USERNAME=zedzzorander
docker-compose up -d
docker-compose ps
```
- В итоге получили такой вывод
```
docker-compose ps           
    Name                  Command             State           Ports         
----------------------------------------------------------------------------
src_comment_1   puma                          Up                            
src_post_1      python3 post_app.py           Up                            
src_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp             
src_ui_1        puma                          Up      0.0.0.0:9292->9292/tcp
```
- Заходим на страничку сервиса - все работает.

## Несколько сетей в compose и параметризация через файл .env
- В раздел `networks:` добавил сети `front_net` и `back_net`
- Дописал для каждого контейнера в его разделе `networks` соответствующие сети, аналогично уже проделаной работы в докере
- Создал в папке `src/` файл `.env` и заполнил его значениями. Прописал переменные в `docker-compose.yml`
- Сделал `docker-compose up -d` 
- Сделал `docker-compose ps`:
```
    Name                  Command             State           Ports         
----------------------------------------------------------------------------
src_comment_1   puma                          Up                            
src_post_1      python3 post_app.py           Up                            
src_post_db_1   docker-entrypoint.sh mongod   Up      27017/tcp             
src_ui_1        puma                          Up      0.0.0.0:9292->9292/tcp
```
- Зашел на страничку сервиса - все работает.

## Как поименовать проект нужным именем
- Можно добавить переменную окружения `COMPOSE_PROJECT_NAME`, экспортировав ее, или добавив в `.env` файл
- Можно стартовать `docker-compose -p my-project-name up` 

## HW*
- Для переопределения команды запуска контейнера существует директива `command` соответственно для запуска пумы мы испольуем следующую конструкцию, в контексте контейнера:
```
command: puma -w 2 --debug
```
- Так же композер позволяет смонтировать папки машины-хоста в виде тома в контейнер. Для этого я добавлю в нужные контейнеры риздел директив `volumes:` и опишу в нем пути относительно текущего размещения `docker-compose.yml`
- Подробная информация о директивах и синтаксисе находится здесь https://docs.docker.com/compose/compose-file/
