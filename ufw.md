ufw reset
ufw default deny incoming
ufw default allow outgoing
ufw allow <port>/tcp comment 'Allow incoming SSH'
ufw allow 51820/udp comment 'Allow incoming WireGuard'
ufw status numbered
ufw delete <>
ufw reload
