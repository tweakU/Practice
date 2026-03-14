[wg-easy@GitHub.com](https://github.com/wg-easy/wg-easy)

[Using WireGuard Easy with nginx SSL - wg-easy@GitHub.com](https://github.com/wg-easy/wg-easy/wiki/Using-WireGuard-Easy-with-nginx-SSL)

[Basic Installation with Docker Compose (Recommended) - wg-easy.github.io](https://wg-easy.github.io/wg-easy/latest/examples/tutorials/basic-installation/)

[Simple Installation with Docker Run - wg-easy.github.io](https://wg-easy.github.io/wg-easy/latest/examples/tutorials/docker-run/)


To automatically install & run wg-easy, simply run:
```console
docker run -d --name=wg-easy \
-e WG_HOST=155.212.163.243 \
-e PASSWORD=xdrn9tEa1A6JR2bpcnm6 \
-e WG_MTU=1280 \
-v ~/.wg-easy:/etc/wireguard \
-p 51820:51820/udp \
-p 51821:51821/tcp \
--cap-add=NET_ADMIN \
--cap-add=SYS_MODULE \
--sysctl="net.ipv4.conf.all.src_valid_mark=1" \
--sysctl="net.ipv4.ip_forward=1" \
--restart unless-stopped \
weejewel/wg-easy
```

```console
ufw allow 51820/udp comment 'WireGuard'
ufw allow 51821/tcp comment 'WireGuard Web UI'
ufw reload
ufw status verbose
```


CLIENT SIDE:
```console
apt-get update
apt-get install wireguard -y
mkdir -p /etc/wireguard
cat > /etc/wireguard/wg00.conf
ctrl + v < wg.conf from WG server
enter
ctrl + d
systemctl start wg-quick@wg00.service
```


## Setup Reverse Proxy
[Caddy](https://wg-easy.github.io/wg-easy/latest/examples/tutorials/caddy/)
docker-compose.yml:
```console
---
volumes:
  etc_wireguard:

services:
  wg-easy:
    environment:
      - PORT=80
    image: ghcr.io/wg-easy/wg-easy:15
    container_name: wg-easy
    networks:
      caddy:
        ipv4_address: 172.18.0.10 # IP-адрес из подсети Caddy brigde
#        ipv6_address: 
    volumes:
      - etc_wireguard:/etc/wireguard
      - /lib/modules:/lib/modules:ro
    ports:
      - "51820:51820/udp"
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
      - SYS_MODULE
    sysctls:
      - net.ipv4.ip_forward=1
      - net.ipv4.conf.all.src_valid_mark=1
#      - net.ipv6.conf.all.disable_ipv6=0
#      - net.ipv6.conf.all.forwarding=1
#      - net.ipv6.conf.default.forwarding=1

networks:
  caddy:
    external: true
    driver: bridge
#    enable_ipv6: true
    ipam:
      driver: default
      config:
        - subnet: 172.18.0.0/16
#        - subnet: 
```
