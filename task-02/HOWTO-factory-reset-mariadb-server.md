```console
systemctl stop mariadb &&\
apt purge mariadb-server mariadb-client mariadb-common -y &&\
rm -rf /etc/mysql &&\
rm -rf /var/lib/mysql &&\
rm -rf /var/log/mysql &&\
rm -rf /var/run/mysqld &&\
apt autoremove -y &&\
apt autoclean &&\
apt update &&\
apt install mariadb-server -y
```
