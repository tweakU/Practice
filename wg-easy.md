[GitHub - wg-easy](https://github.com/wg-easy/wg-easy?tab=readme-ov-file)

[Docker Run - wg-easy](https://wg-easy.github.io/wg-easy/latest/examples/tutorials/docker-run/)

To setup the IPv6 Network, simply run once:
```console
docker network create \
  -d bridge --ipv6 \
  --subnet 10.42.42.0/24 \
  --subnet fdcc:ad94:bacf:61a3::/64 \
   wg
```

To automatically install & run wg-easy, simply run:
```console
docker run -d \
  --net wg \
  -e INSECURE=true \
  --name wg-easy \
  --ip6 fdcc:ad94:bacf:61a3::2a \
  --ip 10.42.42.42 \
  -v ~/.wg-easy:/etc/wireguard \
  -v /lib/modules:/lib/modules:ro \
  -p 51820:51820/udp \
  -p 51821:51821/tcp \
  --cap-add NET_ADMIN \
  --cap-add SYS_MODULE \
  --sysctl net.ipv4.ip_forward=1 \
  --sysctl net.ipv4.conf.all.src_valid_mark=1 \
  --sysctl net.ipv6.conf.all.disable_ipv6=0 \
  --sysctl net.ipv6.conf.all.forwarding=1 \
  --sysctl net.ipv6.conf.default.forwarding=1 \
  --restart unless-stopped \
  ghcr.io/wg-easy/wg-easy:15
```
```console
ufw allow 51820/udp
ufw allow 51821/tcp
ufw reload
ufw status verbose
```
The Web UI will now be available at http://0.0.0.0:51821.

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
