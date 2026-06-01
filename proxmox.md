## Proxmox post install

nano /etc/apt/sources.list
```console
deb http://ftp.ru.debian.org/debian bookworm main contrib

deb http://ftp.ru.debian.org/debian bookworm-updates main contrib

# manualy added by me
deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription

# security updates
deb http://security.debian.org bookworm-security main contrib

# manualy added by me
#deb http://security.debian.org/debian-security bookworm-security main contrib
```

nano /etc/apt/sources.list.d/pve-enterprise.list
```console
#deb https://enterprise.proxmox.com/debian/pve bookworm pve-enterprise
```

nano /etc/apt/sources.list.d/ceph.list
```console
#deb https://enterprise.proxmox.com/debian/ceph-quincy bookworm enterprise

# manualy added by me
deb http://download.proxmox.com/debian/ceph-quincy bookworm no-subscription
```

```console
apt update && apt upgrade -y
```

```console
reboot
```
