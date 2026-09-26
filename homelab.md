Ниже — объединённая Markdown-версия **первой части диалога** (архитектура Proxmox/Docker/NPM) и **последней части** (OMV/NFS/storage). Её можно целиком сохранить как, например, `homelab-architecture.md`.

````
# Home Lab: Proxmox + Docker + OMV + Nginx Proxy Manager

## Исходные данные

- Home Lab Server:
  - Intel Xeon E3-1265L v2
  - 32 GB RAM
  - NVMe SSD для VM/LXC
- Установлен Proxmox VE
- В отдельной VM работает:
  - OpenMediaVault 7.7.24-7
  - 1 CPU / 1 GB RAM
- Роутер провайдера имеет Public IPv4
- Планируемые сервисы:
  - Nginx Proxy Manager
  - Plex
  - Sonarr
  - Paperless-ngx
  - Home Assistant
  - Jellyfin
  - Nextcloud

---

# 1. Общая архитектура

Для данного Home Lab оптимальная схема:

> Proxmox → VM → Docker → Docker Compose → приложения

Не стоит создавать отдельную VM/LXC для каждого сервиса.

Базовая архитектура:

                         INTERNET
                            │
                    Public IPv4 on router
                            │
                       NAT 80/443
                            │
                            ▼
                  ┌──────────────────┐
                  │ Nginx Proxy Mgr  │
                  │   Docker / VM    │
                  └────────┬─────────┘
                           │
              ┌────────────┼─────────────┐
              │            │             │
              ▼            ▼             ▼
          services      services       services

Для начала лучше сделать:

Proxmox
│
├── VM 100  Home Assistant OS
│
├── VM 110  Docker Host
│   ├── Nginx Proxy Manager
│   ├── Sonarr
│   ├── Plex
│   ├── Jellyfin
│   ├── Paperless-ngx
│   └── Nextcloud
│
└── VM 120  OpenMediaVault
    └── Storage

---

# 2. VM vs LXC vs Docker

Нужно разделять два уровня:

- VM/LXC — изоляция на уровне Proxmox.
- Docker container — изоляция приложений внутри Linux.

Поэтому хороший вариант:

Proxmox
   │
   └── VM: docker-host
          │
          └── Debian
               │
               └── Docker
                    ├── NPM
                    ├── Sonarr
                    ├── Jellyfin
                    ├── Plex
                    ├── Paperless
                    └── Nextcloud

---

# 3. Почему Docker лучше разместить внутри VM

Рекомендуемый вариант:

Proxmox
   │
   └── Debian VM
          │
          └── Docker

Преимущества:

- Docker изолирован от Proxmox host.
- Можно делать backup всей VM.
- Можно делать snapshot.
- Docker можно обновлять независимо от Proxmox.
- Debian можно обслуживать независимо от Proxmox.
- VM легко перенести на другой сервер.
- Docker Compose позволяет описывать инфраструктуру декларативно.

Для Home Lab это хороший баланс между изоляцией и простотой.

---

# 4. Почему не VM на каждый сервис

Технически можно сделать:

VM 101 NPM
VM 102 Plex
VM 103 Sonarr
VM 104 Jellyfin
VM 105 Paperless
VM 106 Nextcloud
VM 107 Home Assistant

Но для данного сервера это избыточно.

Появляется:

- больше RAM overhead;
- больше ОС;
- больше обновлений;
- больше backup jobs;
- больше IP;
- больше firewall rules;
- больше SSH;
- больше monitoring;
- больше точек администрирования.

---

# 5. Почему не LXC на каждый сервис

Можно сделать:

Proxmox
├── LXC 101 NPM
├── LXC 102 Sonarr
├── LXC 103 Jellyfin
├── LXC 104 Plex
├── LXC 105 Paperless
├── LXC 106 Nextcloud
└── VM 107 Home Assistant

Это экономично по RAM.

Но появляется дополнительная административная сложность.

Для данного Home Lab Docker Compose будет удобнее.

---

# 6. Docker Host

Начальная конфигурация:

VM 110
Debian
Docker
Docker Compose

Например:

- 4 vCPU
- 8 GB RAM

При необходимости RAM можно увеличить:

8 GB
  ↓
12 GB
  ↓
16 GB

Нет необходимости сразу выделять Docker VM 16 GB.

---

# 7. Возможное дальнейшее разделение Docker Hosts

В дальнейшем можно сделать:

Proxmox
│
├── VM 100
│   └── Home Assistant OS
│
├── VM 110
│   └── docker-public
│       ├── Nginx Proxy Manager
│       ├── Nextcloud
│       └── Paperless
│
└── VM 120
    └── docker-media
        ├── Plex
        ├── Jellyfin
        └── Sonarr

Но на первом этапе лучше начать с одной Docker VM.

---

# 8. Nginx Proxy Manager

Nginx Proxy Manager размещается внутри Docker Host:

Docker Host
│
├── Nginx Proxy Manager
├── Nextcloud
├── Paperless
├── Sonarr
├── Jellyfin
└── Plex

NPM становится единственной точкой HTTP/HTTPS входа из Internet.

Схема:

Internet
    │
    ▼
Public IPv4
    │
    ▼
Router
    │
    ├── TCP 80  ──► NPM
    └── TCP 443 ──► NPM
                       │
                       ▼
                 Docker network
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
      Nextcloud    Paperless     Sonarr

---

# 9. Какие порты публиковать наружу

Из Internet:

TCP 80  → Nginx Proxy Manager
TCP 443 → Nginx Proxy Manager

Не следует публиковать наружу:

- NPM :81
- Sonarr :8989
- Jellyfin :8096
- Plex :32400
- Paperless :8000
- Home Assistant :8123

Административный интерфейс NPM:

http://NPM-IP:81

должен быть доступен только из LAN или VPN.

---

# 10. NPM как единственная HTTP/HTTPS точка входа

                         INTERNET
                            │
                       Public IPv4
                            │
                       Router Firewall
                            │
                       TCP 80/443
                            │
                            ▼
                 ┌─────────────────────┐
                 │ Nginx Proxy Manager │
                 └──────────┬──────────┘
                            │
                    Docker internal net
                            │
          ┌─────────────────┼────────────────┐
          ▼                 ▼                ▼
      Nextcloud         Paperless          Sonarr

Например:

https://cloud.example.com
            │
            ▼
      Nginx Proxy Manager
            │
            ▼
       nextcloud:80

---

# 11. NPM: SQLite, MySQL/MariaDB или PostgreSQL?

Для Nginx Proxy Manager доступны:

- SQLite
- MySQL
- MariaDB

Для небольшого Home Lab:

> SQLite — рекомендуемый вариант.

NPM не является database-heavy application.

В базе хранятся:

- Proxy Hosts
- Users
- Access Lists
- Certificates
- Settings
- Streams
- другие настройки NPM

Для обычного Home Lab этого более чем достаточно.

---

# 12. SQLite для NPM

Схема:

Nginx Proxy Manager
        │
        ▼
database.sqlite

Плюсы:

- минимум компонентов;
- минимум RAM;
- не нужен отдельный DB server;
- простой backup;
- простой restore;
- меньше обслуживания;
- отлично подходит для небольшого количества Proxy Hosts.

Для данного Home Lab:

> SQLite — самый простой и практичный выбор.

---

# 13. MariaDB/MySQL для NPM

Альтернативный вариант:

NPM
 │
 ▼
MariaDB

Это имеет смысл, если хочется использовать отдельную DB infrastructure.

Но появляются дополнительные компоненты:

- MariaDB
- DB credentials
- DB backup
- DB updates
- DB monitoring

Если MariaDB нужна только NPM, практического преимущества для небольшого Home Lab немного.

---

# 14. PostgreSQL для NPM

Для NPM PostgreSQL специально выбирать не стоит.

Для Home Lab логичнее:

NPM → SQLite

или:

NPM → MariaDB

PostgreSQL лучше использовать для приложений, которым он действительно нужен.

---

# 15. Paperless-ngx

Для Paperless-ngx:

Paperless
   │
   ├── PostgreSQL
   └── Redis/Valkey

Например:

Docker Compose
│
├── paperless-web
├── paperless-worker
├── paperless-scheduler
├── postgres
└── redis/valkey

---

# 16. Nextcloud

Для Nextcloud также лучше не использовать SQLite как основную БД.

Рекомендуемая архитектура:

Nextcloud
   │
   └── PostgreSQL

При этом нужно разделять:

PostgreSQL
   │
   └── application metadata

и:

Filesystem
   │
   └── actual user files

---

# 17. Plex + Jellyfin

Plex и Jellyfin можно разместить в одной Docker VM:

Docker Host
│
├── Plex
└── Jellyfin

Оба используют одну media library:

/media
├── movies
├── tv
└── music

Главное ограничение на данном сервере может быть не RAM, а transcoding.

Если Plex и Jellyfin будут одновременно транскодировать видео, нужно отдельно проверить возможности iGPU и организовать доступ к нему из Docker.

---

# 18. Sonarr + media storage

Sonarr:

Sonarr
│
├── /tv
└── /downloads

Лучше организовать filesystem paths таким образом, чтобы downloads и media находились в одном filesystem.

Например:

/data
├── torrents
│   └── tv
└── media
    └── tv

Это позволяет использовать hardlinks и избегать ненужных copy+delete операций.

---

# 19. Home Assistant

Home Assistant лучше разместить отдельно:

Proxmox
│
└── VM
     │
     └── Home Assistant OS

Например:

- 2 vCPU
- 2–4 GB RAM

Отдельная VM особенно удобна для:

- Zigbee USB dongle;
- Z-Wave;
- Bluetooth;
- Thread;
- других USB devices.

---

# 20. Storage architecture

Не стоит смешивать OS, Docker volumes и media в одном виртуальном диске.

Лучше:

NVMe
│
├── Proxmox
├── VM disks
└── Application data

А media/documents:

OMV
│
├── Movies
├── TV
├── Documents
└── Backups

Главный принцип:

> OMV = bulk storage
> NVMe = application state / database / config

---

# 21. Backup strategy

Snapshot VM сам по себе не является полноценной backup strategy.

Желательно иметь:

Proxmox
   │
   └── Backups
        ├── Docker VM
        ├── Home Assistant VM
        └── OMV

Дополнительно нужны application-level backups.

Например:

NPM
├── /data
└── /etc/letsencrypt

Paperless
├── documents
├── media
└── PostgreSQL dump

Nextcloud
├── data
└── PostgreSQL dump

---

# 22. Итоговая архитектура

                         INTERNET
                             │
                       Public IPv4
                             │
                        ISP Router
                             │
                      NAT TCP 80/443
                             │
                             ▼
                    ┌─────────────────┐
                    │ Proxmox VE      │
                    │                 │
                    │ ┌─────────────┐ │
                    │ │ VM 110      │ │
                    │ │ Debian      │ │
                    │ │ Docker      │ │
                    │ │             │ │
                    │ │ NPM         │ │
                    │ │ Nextcloud   │ │
                    │ │ Paperless   │ │
                    │ │ Sonarr      │ │
                    │ │ Plex        │ │
                    │ │ Jellyfin    │ │
                    │ └─────────────┘ │
                    │                 │
                    │ ┌─────────────┐ │
                    │ │ VM 120      │ │
                    │ │ Home        │ │
                    │ │ Assistant   │ │
                    │ │ OS          │ │
                    │ └─────────────┘ │
                    │                 │
                    │ ┌─────────────┐ │
                    │ │ OMV         │ │
                    │ │ Storage     │ │
                    │ └─────────────┘ │
                    └─────────────────┘

---

# 23. Финальная таблица

| Компонент | Рекомендация |
|---|---|
| Proxmox | Bare metal |
| Docker Host | Отдельная Debian VM |
| Nginx Proxy Manager | Docker |
| Plex | Docker |
| Jellyfin | Docker |
| Sonarr | Docker |
| Paperless-ngx | Docker Compose |
| Nextcloud | Docker Compose |
| Home Assistant | Отдельная VM + HAOS |
| NPM Database | SQLite |
| Paperless Database | PostgreSQL |
| Nextcloud Database | PostgreSQL |
| Media storage | OMV |
| Application/DB storage | Local NVMe |
| Internet ingress | NPM :80/:443 |
| NPM Admin :81 | Только LAN/VPN |
| Backup | Proxmox Backup + application-level DB/data backups |

---

# 24. Настройка OMV для Docker Host

## Целевая архитектура

OMV будет выступать как storage server, а Docker VM — как клиент NFS.

                         Proxmox
                            │
              ┌─────────────┴─────────────┐
              │                           │
        VM: OMV 7.7.24-7             VM: Docker Host
              │                           │
        OMV virtual disk              Debian
              │                           │
              ▼                           ▼
          OMV storage               Docker Compose
              │                           │
              ├── media                  ├── Plex
              ├── downloads              ├── Jellyfin
              ├── documents               ├── Sonarr
              └── backups                 ├── Paperless
                     │                    └── Nextcloud
                     │
                     └────── NFS ─────────┘

---

# 25. Почему NFS

Для Linux → Linux лучше использовать NFS:

OMV ──NFS──> Debian Docker VM

а не SMB.

SMB имеет больше смысла для Windows clients.

Для Linux Docker Host + Linux OMV:

> NFS — естественный вариант.

---

# 26. Организация storage в OMV

В OMV:

Storage
└── File Systems

Убедиться, что filesystem смонтирован.

Например:

/dev/sdb1
    ↓
/srv/dev-disk-by-uuid-XXXX/

Не следует вручную редактировать `/etc/fstab` OMV.

Для storage management лучше использовать интерфейс OMV.

---

# 27. Shared Folders

В OMV:

Storage → Shared Folders

Можно создать:

- media
- downloads
- documents
- backups

Логическая структура:

OMV filesystem
│
├── media
│   ├── movies
│   ├── tv
│   └── music
│
├── downloads
│   ├── torrents
│   └── usenet
│
├── documents
│
└── backups

Не нужно создавать отдельный Shared Folder для каждого Docker container.

---

# 28. NFS

В OMV:

Services → NFS → Settings

Включить NFS.

Затем:

Services → NFS → Shares

Создать NFS shares.

Например:

Shared folder:
    media

Client:
    192.168.1.20/32

где `192.168.1.20` — IP Docker VM.

Не стоит разрешать:

Client:
    *

или:

0.0.0.0/0

Если storage нужен только Docker VM, доступ должен быть ограничен её IP.

Например:

OMV:        192.168.1.10
Docker VM:  192.168.1.20

---

# 29. NFS shares

Можно экспортировать:

192.168.1.10:/export/media
192.168.1.10:/export/downloads
192.168.1.10:/export/documents
192.168.1.10:/export/backups

Но не нужно делать отдельный NFS share для каждого приложения.

Не стоит создавать:

- npm-data
- sonarr-data
- plex-data
- jellyfin-data
- paperless-data
- nextcloud-data

Это быстро усложнит storage management.

---

# 30. Docker VM: NFS client

На Debian Docker VM:

```bash
sudo apt update
sudo apt install nfs-common
````

 Проверить exports:

```
showmount -e 192.168.1.10
```

 Ожидаемый результат:

```
Export list for 192.168.1.10:

/export/media       192.168.1.20
/export/downloads   192.168.1.20
/export/documents   192.168.1.20
/export/backups     192.168.1.20
```

---

 # 31\. Mount points на Docker VM

 Создать:

```
sudo mkdir -p /mnt/omv/media
sudo mkdir -p /mnt/omv/downloads
sudo mkdir -p /mnt/omv/documents
sudo mkdir -p /mnt/omv/backups
```

 Проверить вручную:

```
sudo mount -t nfs 192.168.1.10:/export/media /mnt/omv/media
```

 Проверить:

```
mount | grep omv
```

 и:

```
df -h
```

---

 # 32\. Проверка записи

```
sudo touch /mnt/omv/media/test.txt
ls -l /mnt/omv/media/
```

 На OMV проверить наличие файла.

 Если файл появился — NFS работает.

---

 # 33\. Постоянный mount через fstab

 После успешной проверки добавить на Docker VM:

```
192.168.1.10:/export/media       /mnt/omv/media       nfs4  defaults,_netdev  0  0
192.168.1.10:/export/downloads   /mnt/omv/downloads   nfs4  defaults,_netdev  0  0
192.168.1.10:/export/documents   /mnt/omv/documents   nfs4  defaults,_netdev  0  0
192.168.1.10:/export/backups     /mnt/omv/backups     nfs4  defaults,_netdev  0  0
```

 Затем:

```
sudo mount -a
```

 Проверить:

```
findmnt /mnt/omv/media
```

 `_netdev` важен, поскольку система понимает, что это network filesystem.

---

 # 34\. Docker и NFS

 Docker не должен напрямую знать об OMV.

 Docker VM видит:

 /mnt/omv/media\
 /mnt/omv/downloads\
 /mnt/omv/documents

 как обычные Linux directories.

 Docker container получает bind mount:

```
services:
  jellyfin:
    image: jellyfin/jellyfin
    volumes:
      - /opt/docker/jellyfin/config:/config
      - /mnt/omv/media:/media
```

 Получается:

 Jellyfin container\
 │\
 │ /media\
 ▼\
 Docker VM\
 │\
 │ /mnt/omv/media\
 ▼\
 NFS\
 │\
 ▼\
 OMV\
 │\
 ▼\
 Physical disk

---

 # 35\. Sonarr

 Например:

```
services:
  sonarr:
    image: lscr.io/linuxserver/sonarr:latest
    volumes:
      - /opt/docker/sonarr/config:/config
      - /mnt/omv/media:/media
      - /mnt/omv/downloads:/downloads
```

 Внутри контейнера:

 /media\
 /downloads

---

 # 36\. Plex

```
services:
  plex:
    image: lscr.io/linuxserver/plex:latest
    volumes:
      - /opt/docker/plex/config:/config
      - /mnt/omv/media:/media
```

 Plex получает:

 /media/movies\
 /media/tv\
 /media/music

---

 # 37\. Важный принцип: `/config` на NVMe

 Не следует выносить абсолютно все Docker volumes на OMV.

 Лучше:

 /config → local NVMe\
 /media → OMV

 Например:

 Docker VM\
 │\
 ├── /opt/docker/\
 │ ├── plex/config ← NVMe\
 │ ├── jellyfin/config ← NVMe\
 │ ├── sonarr/config ← NVMe\
 │ └── npm/data ← NVMe\
 │\
 └── /mnt/omv/\
 ├── media ← NFS\
 ├── downloads ← NFS\
 ├── documents ← NFS\
 └── backups ← NFS

---

 # 38\. Почему configuration лучше держать на NVMe

 Application configuration может содержать:

 - SQLite databases;
- metadata;
- cache;
- thumbnails;
- indexes;
- logs;
- frequent small writes.

 Поэтому:

 Jellyfin\
 /config → NVMe\
 /media → OMV

 лучше, чем:

 Jellyfin\
 /config → NFS\
 /media → NFS

---

 # 39\. Sonarr и hardlinks

 Для media stack лучше сделать единый filesystem:

 OMV\
 │\
 └── data\
 ├── torrents\
 │ ├── movies\
 │ └── tv\
 │\
 ├── usenet\
 │ ├── movies\
 │ └── tv\
 │\
 └── media\
 ├── movies\
 ├── tv\
 └── music

 На Docker VM:

 /mnt/omv/data

 Sonarr получает:

 /data

 Тогда:

 /data/torrents/tv/Show.S01E01.mkv\
 │\
 │ hardlink\
 ▼\
 /data/media/tv/Show/Season 01/Show.S01E01.mkv

 Оба пути находятся в одном filesystem.

---

 # 40\. Paperless-ngx

 Для Paperless:

 Paperless\
 │\
 ├── application/config → NVMe\
 ├── PostgreSQL → NVMe\
 ├── Redis/Valkey → NVMe\
 │\
 └── documents → OMV

 Например:

```
volumes:
  - /opt/docker/paperless/data:/usr/src/paperless/data
  - /opt/docker/paperless/media:/usr/src/paperless/media
  - /mnt/omv/documents:/usr/src/paperless/export
```

 Конкретные paths следует согласовать с используемым Compose deployment Paperless.

---

 # 41\. Nextcloud

 Для Nextcloud:

 Nextcloud\
 │\
 ├── application/config → NVMe\
 ├── PostgreSQL → NVMe\
 │\
 └── user data → OMV

 Но Nextcloud data directory на NFS требует аккуратной настройки:

 - permissions;
- locking;
- network filesystem behaviour;
- performance.

 Поэтому разумнее сначала поднять Nextcloud полностью на NVMe, убедиться в стабильности, а затем переносить user data на OMV.

---

 # 42\. Nginx Proxy Manager

 NPM полностью оставить на NVMe:

 NPM\
 │\
 ├── /data → NVMe\
 └── /etc/letsencrypt → NVMe

 Для NPM нет практической необходимости использовать NFS.

---

 # 43\. Финальная storage architecture

```
             ┌───────────────────────┐
             │        Proxmox        │
             └───────────┬───────────┘
                         │
          ┌──────────────┴──────────────┐
          │                             │
          ▼                             ▼
    ┌───────────┐                 ┌──────────────┐
    │    OMV    │                 │ Docker VM    │
    │           │                 │              │
    │ HDD/SSD   │◄───── NFS ─────►│ Debian       │
    │           │                 │ Docker       │
    └───────────┘                 └──────┬───────┘
                                         │
                      ┌──────────────────┼──────────────────┐
                      │                  │                  │
                      ▼                  ▼                  ▼
                   NPM/Plex           Sonarr            Jellyfin
                   /config            /config            /config
                      │                  │                  │
                      └──────── NVMe ────┘                  │
                                         │                  │
                                         └──── NFS ─────────┘
  
