Конечно. Ниже — первая часть нашего диалога в Markdown, начиная с твоего исходного запроса и моего первого ответа.

````
# DevOps: VPS с Nextcloud AIO и WGDashboard

## Исходная задача

Есть VPS с прямым IPv4-адресом.

Нужно разместить на нём две службы:

1. WGDashboard / WireGuard
2. Nextcloud AIO

### WGDashboard

```yaml
services:
  wgdashboard:
    image: ghcr.io/wgdashboard/wgdashboard:latest
    restart: unless-stopped
    container_name: wgdashboard

    ports:
      - 10086:10086/tcp
      - 51820:51820/udp

    volumes:
      - aconf:/etc/amnezia/amneziawg
      - conf:/etc/wireguard
      - data:/data

    cap_add:
      - NET_ADMIN

volumes:
  aconf:
  conf:
  data:
````

 ### Nextcloud AIO

```
name: nextcloud-aio

services:
  nextcloud-aio-mastercontainer:
    image: ghcr.io/nextcloud-releases/all-in-one:latest
    init: true
    restart: always
    container_name: nextcloud-aio-mastercontainer

    volumes:
      - nextcloud_aio_mastercontainer:/mnt/docker-aio-config
      - /var/run/docker.sock:/var/run/docker.sock:ro

    network_mode: bridge

    ports:
      - "80:80"
      - "8080:8080"
      - "8443:8443"

volumes:
  nextcloud_aio_mastercontainer:
    name: nextcloud_aio_mastercontainer
```

---

 # Code Review

 ## Общая архитектура

 Для production VPS я бы не публиковал административные интерфейсы напрямую.

 Рекомендуемая схема:

```
                         Internet
                            │
              ┌─────────────┴─────────────┐
              │                            │
        TCP 80/443                    UDP 51820
              │                            │
          ┌───▼────┐                 ┌─────▼─────┐
          │ Caddy  │                 │ WireGuard │
          │ :80/443│                 │ :51820    │
          └───┬────┘                 └───────────┘
              │
       ┌──────┴─────────┐
       │                │
       ▼                ▼
 cloud.example.com   wg.example.com
       │                │
       ▼                ▼
  127.0.0.1:11000   127.0.0.1:10086
       │                │
       ▼                ▼
 Nextcloud AIO       WGDashboard
```

 То есть:

 - Caddy — единственная публичная HTTP(S)-точка входа.
- WireGuard — отдельный публичный UDP-сервис.
- AIO management interface не публикуется.
- WGDashboard UI не публикуется напрямую.

---

 # WGDashboard

 Исходная конфигурация:

```
ports:
  - 10086:10086/tcp
  - 51820:51820/udp
```

 Я бы изменил её на:

```
ports:
  - "127.0.0.1:10086:10086/tcp"
  - "51820:51820/udp"
```

 В результате:

 - `10086/TCP` доступен только локально;
- `51820/UDP` доступен из интернета.

 Полная конфигурация:

```
services:
  wgdashboard:
    image: ghcr.io/wgdashboard/wgdashboard:latest
    restart: unless-stopped
    container_name: wgdashboard

    ports:
      - "127.0.0.1:10086:10086/tcp"
      - "51820:51820/udp"

    volumes:
      - aconf:/etc/amnezia/amneziawg
      - conf:/etc/wireguard
      - data:/data

    cap_add:
      - NET_ADMIN

volumes:
  aconf:
  conf:
  data:
```

 ### Почему `127.0.0.1`

 Запись:

```
- 10086:10086
```

 публикует порт на всех интерфейсах.

 То есть web UI потенциально становится доступным из интернета.

 Запись:

```
- "127.0.0.1:10086:10086"
```

 оставляет его доступным только на localhost VPS.

 После этого Caddy сможет обратиться к нему локально.

---

 # Nextcloud AIO

 Исходная конфигурация содержит:

```
ports:
  - "80:80"
  - "8080:8080"
  - "8443:8443"
```

 Для reverse proxy это избыточно.

 Я бы использовал:

```
ports:
  - "127.0.0.1:8080:8080"
```

 и:

```
environment:
  APACHE_PORT: 11000
  APACHE_IP_BINDING: 127.0.0.1
```

 То есть:

 - `8080` — только локальная AIO management interface;
- `11000` — локальный backend Nextcloud;
- внешний HTTP/HTTPS обслуживает Caddy.

---

 # Рекомендуемый Nextcloud compose

```
name: nextcloud-aio

services:
  nextcloud-aio-mastercontainer:
    image: ghcr.io/nextcloud-releases/all-in-one:latest

    init: true
    restart: always

    container_name: nextcloud-aio-mastercontainer

    volumes:
      - nextcloud_aio_mastercontainer:/mnt/docker-aio-config
      - /var/run/docker.sock:/var/run/docker.sock:ro

    network_mode: bridge

    ports:
      - "127.0.0.1:8080:8080"

    environment:
      APACHE_PORT: 11000
      APACHE_IP_BINDING: 127.0.0.1

volumes:
  nextcloud_aio_mastercontainer:
    name: nextcloud_aio_mastercontainer
```

---

 # Почему `APACHE_PORT=11000`

 Здесь есть два разных интерфейса.

 ## AIO management

```
127.0.0.1:8080
```

 Это административный интерфейс AIO.

 ## Сам Nextcloud

```
127.0.0.1:11000
        ▲
        │
      Caddy
        ▲
        │
Internet → https://cloud.example.com
```

 `11000` используется как HTTP backend для reverse proxy.

---

 # Caddy

 Для этой архитектуры удобно использовать Caddy.

 Он будет выполнять две функции:

 1. Reverse proxy.
2. Автоматическое получение и обновление TLS-сертификатов.

 Схема:

```
cloud.example.com → 127.0.0.1:11000
wg.example.com    → 127.0.0.1:10086
```

---

 # DNS

 Если используется собственный домен:

```
example.com
```

 создаются записи:

```
A cloud.example.com → VPS_PUBLIC_IP
A wg.example.com    → VPS_PUBLIC_IP
```

---

 # Caddyfile

```
cloud.example.com {
    reverse_proxy 127.0.0.1:11000
}

wg.example.com {
    reverse_proxy 127.0.0.1:10086
}
```

 Caddy автоматически получает TLS-сертификаты для публичных доменов.

---

 # Firewall

 На VPS желательно оставить только необходимые входящие порты:

```
TCP 22       SSH
TCP 80       HTTP / ACME
TCP 443      HTTPS
UDP 51820    WireGuard
```

 Например, с UFW:

```
sudo ufw default deny incoming
sudo ufw default allow outgoing

sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 51820/udp

sudo ufw enable
sudo ufw status verbose
```

 Не нужно открывать:

```
10086/tcp
8080/tcp
8443/tcp
11000/tcp
```

---

 # Порядок развёртывания

 ## 1\. Проверить занятые порты

```
sudo ss -lntup
```

 И:

```
sudo ss -lntup | grep -E ':(80|443|8080|10086|11000|51820)\b'
```

---

 # 2\. Запустить WGDashboard

```
cd /opt/wgdashboard

docker compose pull
docker compose up -d
```

 Проверить:

```
docker ps
```

 И:

```
sudo ss -lntup | grep -E '10086|51820'
```

 Ожидается примерно:

```
127.0.0.1:10086
0.0.0.0:51820
```

 Проверка UI:

```
curl -I http://127.0.0.1:10086
```

---

 # 3\. Проверить WireGuard

```
docker exec wgdashboard wg show
```

 или:

```
sudo wg show
```

 Порт:

```
sudo ss -lunp | grep 51820
```

 Клиент WireGuard:

```
Endpoint = wg.example.com:51820
```

---

 # 4\. Запустить Nextcloud AIO

```
cd /opt/nextcloud-aio

docker compose pull
docker compose up -d
```

 Проверить:

```
docker ps
```

 И:

```
sudo ss -lntp | grep -E '8080|11000'
```

 Публично эти порты открыты быть не должны.

---

 # 5\. Открыть AIO management interface

 Поскольку `8080` привязан к localhost, с рабочего компьютера используется SSH tunnel:

```
ssh -L 8080:127.0.0.1:8080 user@VPS
```

 После этого открыть:

```
https://127.0.0.1:8080
```

 У AIO на `8080` используется self-signed certificate, поэтому предупреждение браузера ожидаемо.

---

 # 6\. Настроить Nextcloud

 В AIO указывается:

```
cloud.example.com
```

 DNS должен указывать:

```
cloud.example.com → VPS
```

 Архитектура:

```
Browser
   │
   │ HTTPS :443
   ▼
Caddy
   │
   │ HTTP localhost:11000
   ▼
AIO Apache
   │
   ▼
Nextcloud
```

---

 # Итоговая схема

```
                    Internet
                       │
              ┌────────┴────────┐
              │                 │
           TCP 443          UDP 51820
              │                 │
              ▼                 ▼
           Caddy            WireGuard
              │
       ┌──────┴──────┐
       │             │
       ▼             ▼
 cloud.example.com wg.example.com
       │             │
       ▼             ▼
127.0.0.1:11000 127.0.0.1:10086
       │             │
       ▼             ▼
 Nextcloud AIO   WGDashboard
```

 Публично доступны:

 | Port | Protocol | Назначение |
| --- | --- | --- |
| 22 | TCP | SSH |
| 80 | TCP | Caddy / ACME / redirect |
| 443 | TCP | Nextcloud + WGDashboard |
| 51820 | UDP | WireGuard |

Локально:

 | Port | Назначение |
| --- | --- |
| 10086 | WGDashboard |
| 8080 | AIO management |
| 11000 | Nextcloud AIO Apache |

---

 # Важное замечание про `latest`

 Для production желательно не полагаться бездумно на:

```
image: ...:latest
```

 Лучше иметь контролируемый процесс обновления:

```
backup
   ↓
pull new image
   ↓
start
   ↓
health check
   ↓
functional test
   ↓
keep / rollback
```

 Особенно это важно для Nextcloud.

---

 # Backup

 Docker volumes сами по себе не являются backup.

 Для Nextcloud необходимо иметь независимую копию:

```
Nextcloud data
+
database
+
AIO configuration
```

 и периодически проверять восстановление.

 Для WGDashboard также желательно сохранять:

```
/etc/wireguard
/etc/amnezia/amneziawg
/data
```

---

 # Финальные изменения относительно исходной конфигурации

 ## WGDashboard

```
ports:
-  - 10086:10086/tcp
+  - "127.0.0.1:10086:10086/tcp"
   - 51820:51820/udp
```

 ## Nextcloud AIO

```
ports:
-  - "80:80"
-  - "8080:8080"
-  - "8443:8443"
+  - "127.0.0.1:8080:8080"

+ environment:
+   APACHE_PORT: 11000
+   APACHE_IP_BINDING: 127.0.0.1
```

 ## Caddy

```
80/443
   ↓
Caddy
   ├── cloud.example.com → 127.0.0.1:11000
   └── wg.example.com    → 127.0.0.1:10086
```

 ## Firewall

```
ALLOW 22/tcp
ALLOW 80/tcp
ALLOW 443/tcp
ALLOW 51820/udp

DENY everything else
```

 Это даёт чистую production-схему для одного VPS с public IPv4, Nextcloud AIO, WGDashboard и WireGuard.

```

```
