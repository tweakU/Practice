# Архитектура Home Lab на Proxmox — Best Practices

 ## Исходные данные

 - Home Lab Server:
  - **Intel Xeon E3-1265L v2**
  - **32 GB RAM**
  - **NVMe SSD** для VM/LXC
- Установлен **Proxmox VE**
- Есть VM:
  - **OpenMediaVault (OMV)**
  - 1 CPU / 1 GB RAM
- Роутер провайдера имеет **Public IPv4**
- Планируемые сервисы:
  - Nginx Proxy Manager
  - Plex
  - Sonarr
  - Paperless-ngx
  - Home Assistant
  - Jellyfin
  - Nextcloud

---

 # 1\. Рекомендуемая архитектура

 Для данного Home Lab оптимально использовать:

 > **Proxmox → VM → Docker → Docker Compose → приложения**

 А не создавать отдельную VM или LXC для каждого сервиса.

 Базовая архитектура:

```
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
          VM/LXC        VM/LXC         VM/LXC
```

 Для начала лучше сделать проще:

```
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
└── OMV
```

---

 # 2\. VM vs LXC vs Docker

 ## Важное различие

 Нужно разделять два уровня:

 - **VM/LXC** — виртуализация/изоляция на уровне Proxmox.
- **Docker container** — контейнеризация приложений внутри Linux.

 Поэтому не обязательно выбирать только:

 > LXC **или** Docker.

 Хорошая архитектура:

```
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
```

---

 # 3\. Почему Docker лучше разместить внутри VM

 Рекомендуемый вариант:

```
Proxmox
   │
   └── Debian VM
          │
          └── Docker
```

 Преимущества:

 - Docker изолирован от Proxmox host.
- Можно делать backup всей VM.
- Можно делать snapshot.
- Docker можно обновлять независимо от Proxmox.
- Debian можно обслуживать независимо от Proxmox.
- VM легко перенести на другой сервер.
- Docker Compose позволяет описывать инфраструктуру декларативно.
- При проблеме с Docker сам Proxmox остаётся независимым.

 Это особенно важно с точки зрения безопасности: Docker daemon имеет значительные привилегии, поэтому отдельная VM даёт дополнительный уровень изоляции.

---

 # 4\. Почему не VM на каждый сервис

 Технически можно сделать:

```
VM 101 NPM
VM 102 Plex
VM 103 Sonarr
VM 104 Jellyfin
VM 105 Paperless
VM 106 Nextcloud
VM 107 Home Assistant
```

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

 Для большинства этих приложений Docker предоставляет достаточную изоляцию.

---

 # 5\. Почему не LXC на каждый сервис

 Можно сделать:

```
Proxmox
├── LXC 101 NPM
├── LXC 102 Sonarr
├── LXC 103 Jellyfin
├── LXC 104 Plex
├── LXC 105 Paperless
├── LXC 106 Nextcloud
└── VM 107 Home Assistant
```

 Это экономично по RAM.

 Но появляется дополнительная административная сложность.

 Вместо:

```
Docker Compose
```

 получается управление большим количеством LXC:

 - обновление контейнеров;
- backup;
- network configuration;
- mounts;
- permissions;
- firewall;
- lifecycle management.

 Для данного Home Lab Docker Compose будет удобнее.

---

 # 6\. Docker Host

 Начальная конфигурация:

```
VM 110
Debian
Docker
Docker Compose
```

 Например:

```
4 vCPU
8 GB RAM
```

 При необходимости RAM можно увеличить:

```
8 GB
   ↓
12 GB
   ↓
16 GB
```

 Нет необходимости сразу выделять Docker VM 16 GB.

---

 # 7\. Можно ли разделить Docker Hosts?

 Да.

 В дальнейшем можно сделать:

```
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
```

 Это даст дополнительную изоляцию.

 Однако для первого этапа это не обязательно.

 Лучше начать с одной Docker VM, а затем разделить инфраструктуру, когда появится необходимость.

---

 # 8\. Nginx Proxy Manager

 Nginx Proxy Manager лучше разместить внутри Docker Host:

```
Docker Host
│
├── Nginx Proxy Manager
├── Nextcloud
├── Paperless
├── Sonarr
├── Jellyfin
└── Plex
```

 NPM будет единственной точкой HTTP/HTTPS входа из Internet.

 Схема:

```
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
```

---

 # 9\. Какие порты публиковать наружу

 Из Internet:

```
TCP 80  → Nginx Proxy Manager
TCP 443 → Nginx Proxy Manager
```

 Не следует публиковать наружу:

```
NPM :81
Sonarr :8989
Jellyfin :8096
Plex :32400
Paperless :8000
Home Assistant :8123
```

 Административный интерфейс NPM:

```
http://NPM-IP:81
```

 должен быть доступен только из LAN или VPN.

---

 # 10\. NPM как единственная HTTP/HTTPS точка входа

 Рекомендуемая схема:

```
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
```

 Например:

```
https://cloud.example.com
            │
            ▼
      Nginx Proxy Manager
            │
            ▼
       nextcloud:80
```

 и:

```
https://paperless.example.com
            │
            ▼
      Nginx Proxy Manager
            │
            ▼
       paperless:8000
```

---

 # 11\. NPM: SQLite, MySQL/MariaDB или PostgreSQL?

 Для Nginx Proxy Manager доступны:

 - SQLite
- MySQL
- MariaDB

 Для небольшого Home Lab:

 > **SQLite — рекомендуемый вариант.**

 NPM не является database-heavy application.

 В базе хранятся:

 - Proxy Hosts
- Users
- Access Lists
- Certificates
- Settings
- Streams
- и другие настройки NPM.

 Для обычного Home Lab этого более чем достаточно.

---

 # 12\. SQLite для NPM

 Схема:

```
Nginx Proxy Manager
        │
        ▼
database.sqlite
```

 Плюсы:

 - минимум компонентов;
- минимум RAM;
- не нужен отдельный DB server;
- простой backup;
- простой restore;
- меньше обслуживания;
- отлично подходит для небольшого количества Proxy Hosts.

 Для данного Home Lab:

 > **SQLite — самый простой и практичный выбор.**

---

 # 13\. MariaDB/MySQL для NPM

 Альтернативный вариант:

```
NPM
 │
 ▼
MariaDB
```

 Это имеет смысл, если хочется использовать отдельную DB infrastructure.

 Но появляется дополнительный компонент:

```
NPM
 +
MariaDB
 +
DB credentials
 +
DB backup
 +
DB updates
 +
DB monitoring
```

 Если MariaDB нужна только NPM, практического преимущества для небольшого Home Lab немного.

---

 # 14\. PostgreSQL для NPM

 Для NPM PostgreSQL я бы специально не выбирал.

 Для Home Lab:

```
NPM → SQLite
```

 или:

```
NPM → MariaDB
```

 гораздо логичнее.

 PostgreSQL имеет смысл использовать для других приложений, которым он действительно нужен.

---

 # 15\. Paperless-ngx

 Для Paperless-ngx лучше:

```
Paperless
   │
   ├── PostgreSQL
   └── Redis/Valkey
```

 То есть:

```
Docker Compose
│
├── paperless-web
├── paperless-worker
├── paperless-scheduler
├── postgres
└── redis/valkey
```

 Для новой установки Paperless-ngx PostgreSQL является предпочтительным вариантом.

---

 # 16\. Nextcloud

 Для Nextcloud также лучше не использовать SQLite как основную БД.

 Рекомендуемая архитектура:

```
Nextcloud
   │
   └── PostgreSQL
```

 При этом нужно разделять:

```
PostgreSQL
   │
   └── application metadata
```

 и:

```
Filesystem
   │
   └── actual user files
```

 Это важно для backup strategy.

---

 # 17\. Plex + Jellyfin

 Plex и Jellyfin можно спокойно разместить в одной Docker VM:

```
Docker Host
│
├── Plex
└── Jellyfin
```

 Оба используют одну media library:

```
/media
├── movies
├── tv
└── music
```

 При этом необходимо учитывать transcoding.

 Для вашего:

```
Xeon E3-1265L v2
32 GB RAM
```

 главным ограничением может оказаться не RAM, а transcoding.

 Если Plex и Jellyfin будут одновременно транскодировать видео, нужно отдельно проверить возможности iGPU и организовать доступ к нему из Docker.

---

 # 18\. Sonarr + media storage

 Sonarr:

```
Sonarr
│
├── /tv
└── /downloads
```

 Важно правильно организовать filesystem paths.

 Например:

```
/data
├── torrents
│   └── tv
└── media
    └── tv
```

 Это позволяет использовать hardlinks и избежать ненужного copy+delete при перемещении файлов.

---

 # 19\. Home Assistant

 Home Assistant лучше разместить отдельно:

```
Proxmox
│
└── VM
     │
     └── Home Assistant OS
```

 Например:

```
2 vCPU
2–4 GB RAM
```

 Отдельная VM особенно удобна, если позже появятся:

 - Zigbee USB dongle;
- Z-Wave;
- Bluetooth;
- Thread;
- другие USB devices.

 USB passthrough в VM будет проще и понятнее, чем строить это вокруг LXC/Docker.

---

 # 20\. Storage architecture

 Не стоит смешивать OS, Docker volumes и media в одном виртуальном диске.

 Лучше:

```
NVMe
│
├── Proxmox
│
├── VM disks
│
└── Application data
```

 А media/documents:

```
OMV
│
├── Movies
├── TV
├── Documents
└── Backups
```

 При этом:

 > **Database и активные Docker volumes лучше хранить на локальном NVMe.**

 Не стоит размещать PostgreSQL на SMB/NFS без конкретной причины.

---

 # 21\. Пример storage layout

```
NVMe
│
└── Docker VM
    │
    ├── /opt/docker
    │   ├── nginx-proxy-manager
    │   ├── paperless
    │   ├── nextcloud
    │   └── media
    │
    └── databases
        ├── postgres
        └── ...
```

 OMV:

```
OMV
│
├── /media
│   ├── movies
│   ├── tv
│   └── music
│
├── /documents
│
└── /backups
```

---

 # 22\. Docker Compose лучше разделить на проекты

 Не стоит создавать один огромный Compose:

```
docker-compose.yml
500+ lines
```

 Лучше:

```
/opt/docker/
│
├── nginx-proxy-manager/
│   └── compose.yml
│
├── media/
│   └── compose.yml
│
├── paperless/
│   └── compose.yml
│
└── nextcloud/
    └── compose.yml
```

 Например:

```
media
├── sonarr
├── plex
└── jellyfin
```

 Отдельно:

```
paperless
├── paperless
├── postgres
└── valkey
```

 и:

```
nextcloud
├── nextcloud
└── postgres
```

 Так проще:

 - обновлять;
- делать backup;
- диагностировать;
- восстанавливать;
- переносить отдельные приложения.

---

 # 23\. Распределение RAM

 Для 32 GB RAM можно начать примерно так:

 | Компонент | RAM |
| --- | --- |
| Proxmox | 2–4 GB |
| Docker VM | 8–16 GB |
| Home Assistant OS | 2–4 GB |
| OMV | 4–8 GB |
| Запас | Остаток |

Например:

```
32 GB total
│
├── Proxmox       ~3 GB
├── Docker VM     10 GB
├── Home Assistant 3 GB
├── OMV            4 GB
└── Free           12 GB
```

 Затем смотреть на реальное потребление и постепенно увеличивать ресурсы.

---

 # 24\. Backup strategy

 Snapshot VM сам по себе **не является полноценной backup strategy**.

 Желательно иметь:

```
Proxmox
   │
   └── Backups
        ├── Docker VM
        ├── Home Assistant VM
        └── OMV
```

 Дополнительно нужны application-level backups.

 Например:

```
NPM
├── /data
└── /etc/letsencrypt
```

 Paperless:

```
Paperless
├── documents
├── media
└── PostgreSQL dump
```

 Nextcloud:

```
Nextcloud
├── data
└── PostgreSQL dump
```

---

 # 25\. Финальная рекомендуемая схема

```
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
```

---

 # 26\. Итоговая таблица

 | Компонент | Рекомендация |
| --- | --- |
| Proxmox | Bare metal |
| Docker Host | **Отдельная Debian VM** |
| Nginx Proxy Manager | **Docker** |
| Plex | Docker |
| Jellyfin | Docker |
| Sonarr | Docker |
| Paperless-ngx | Docker Compose |
| Nextcloud | Docker Compose |
| Home Assistant | **Отдельная VM + HAOS** |
| NPM Database | **SQLite** |
| Paperless Database | **PostgreSQL** |
| Nextcloud Database | **PostgreSQL** |
| Media storage | OMV |
| Application/DB storage | **Local NVMe** |
| Internet ingress | **NPM :80/:443** |
| NPM Admin :81 | **Только LAN/VPN** |
| Backup | Proxmox Backup + application-level DB/data backups |

---

 ## Главная идея

```
Proxmox
   │
   ├── VM → Home Assistant OS
   │
   ├── VM → Debian → Docker → Applications
   │
   └── OMV → Storage
```

 То есть:

 > **Proxmox отвечает за инфраструктурную изоляцию, VM — за изоляцию Docker Host, Docker — за изоляцию приложений, а Docker Compose — за lifecycle приложений.**

 Для вашего Home Lab это хороший баланс между **простотой, безопасностью, эффективным использованием ресурсов и учебной ценностью**.
