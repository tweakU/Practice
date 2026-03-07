## Запускам CMS Wordpress на Ubuntu 24.04 (Angie + PHP-FPM)


**Установим Angie**  
[Официальная документацияю. Пакетная установка Angie](https://angie.software/angie/docs/installation/oss_packages/#angie-install-deb-oss)

1) Установите вспомогательные пакеты для подключения репозитория Angie:
```console
apt-get update
apt-get install -y ca-certificates curl
```

2) Скачайте открытый ключ репозитория Angie для проверки подлинности пакетов:
```console
curl -o /etc/apt/trusted.gpg.d/angie-signing.gpg \
            https://angie.software/keys/angie-signing.gpg
```

3) Подключите репозиторий Angie:
```console
echo "deb https://download.angie.software/angie/$(. /etc/os-release && echo "$ID/$VERSION_ID $VERSION_CODENAME") main" \
    | tee /etc/apt/sources.list.d/angie.list > /dev/null
```

4) Обновите индексы репозиториев:
```console
apt-get update
```

5) Установите пакет Angie:
```console
apt-get install -y angie
```

!) Проверим работоспособность сервиса:
```console
funt1k@http:~$ systemctl status angie.service
● angie.service - Angie - high performance web server
     Loaded: loaded (/usr/lib/systemd/system/angie.service; enabled; preset: enabled)
     Active: active (running) since Mon 2025-11-24 12:49:27 UTC; 31s ago
       Docs: https://en.angie.software/angie/docs/
    Process: 2134 ExecStart=/usr/sbin/angie -c /etc/angie/angie.conf (code=exited, status=0/SUCCESS)
   Main PID: 2135 (angie)
      Tasks: 3 (limit: 4603)
     Memory: 57.3M (peak: 57.3M)
        CPU: 162ms
     CGroup: /system.slice/angie.service
             ├─2135 "angie: master process v1.10.3 #1 [/usr/sbin/angie -c /etc/angie/angie.conf]"
             ├─2136 "angie: worker process #1"
             └─2137 "angie: worker process #1"

Nov 24 12:49:26 http systemd[1]: Starting angie.service - Angie - high performance web server...
Nov 24 12:49:27 http systemd[1]: Started angie.service - Angie - high performance web server.

funt1k@http:~$ ss -ntlp | grep 80
LISTEN 0      511          0.0.0.0:80        0.0.0.0:*    users:(("angie",pid=2137,fd=6),("angie",pid=2136,fd=6),("angie",pid=2135,fd=6))
```


**Установим дополнительные пакеты (php, mysql etc):**
```console
apt-get install php8.3 php8.3-fpm php8.3-mysql mysql-server-8.0 php-curl php-gd php-intl php-mbstring php-soap php-xml php-xmlrpc php-zip
```

```console
mkdir ~/tmp && cd ~/tmp

wget https://ru.wordpress.org/wordpress-6.8.3-ru_RU.tar.gz

tar -xvf ./wordpress-6.8.3-ru_RU.tar.gz

mkdir -p /var/www/html/

cp -r wordpress /var/www/html/

cd /var/www/html/wordpress/

funt1k@http:/var/www/html/wordpress$ ls -la
total 252
drwxr-xr-x  5 root root  4096 Nov 24 13:09 .
drwxr-xr-x  3 root root  4096 Nov 24 13:09 ..
-rw-r--r--  1 root root   405 Nov 24 13:09 index.php
-rw-r--r--  1 root root 19903 Nov 24 13:09 license.txt
-rw-r--r--  1 root root 10734 Nov 24 13:09 readme.html
-rw-r--r--  1 root root  7387 Nov 24 13:09 wp-activate.php
drwxr-xr-x  9 root root  4096 Nov 24 13:09 wp-admin
-rw-r--r--  1 root root   351 Nov 24 13:09 wp-blog-header.php
-rw-r--r--  1 root root  2323 Nov 24 13:09 wp-comments-post.php
-rw-r--r--  1 root root  4908 Nov 24 13:09 wp-config-sample.php
drwxr-xr-x  5 root root  4096 Nov 24 13:09 wp-content
-rw-r--r--  1 root root  5617 Nov 24 13:09 wp-cron.php
drwxr-xr-x 30 root root 16384 Nov 24 13:09 wp-includes
-rw-r--r--  1 root root  2502 Nov 24 13:09 wp-links-opml.php
-rw-r--r--  1 root root  3937 Nov 24 13:09 wp-load.php
-rw-r--r--  1 root root 51414 Nov 24 13:09 wp-login.php
-rw-r--r--  1 root root  8727 Nov 24 13:09 wp-mail.php
-rw-r--r--  1 root root 30081 Nov 24 13:09 wp-settings.php
-rw-r--r--  1 root root 34516 Nov 24 13:09 wp-signup.php
-rw-r--r--  1 root root  5102 Nov 24 13:09 wp-trackback.php
-rw-r--r--  1 root root  3205 Nov 24 13:09 xmlrpc.php

find /var/www/html/wordpress -type d -exec chmod 755 {} \;
find /var/www/html/wordpress -type f -exec chmod 644 {} \;

funt1k@http:~$ ls -la /var/www/html/wordpress/
total 252
drwxr-xr-x  5 root root  4096 Nov 24 13:09 .
drwxr-xr-x  3 root root  4096 Nov 24 13:09 ..
-rw-r--r--  1 root root   405 Nov 24 13:09 index.php
-rw-r--r--  1 root root 19903 Nov 24 13:09 license.txt
-rw-r--r--  1 root root 10734 Nov 24 13:09 readme.html
-rw-r--r--  1 root root  7387 Nov 24 13:09 wp-activate.php
drwxr-xr-x  9 root root  4096 Nov 24 13:09 wp-admin
-rw-r--r--  1 root root   351 Nov 24 13:09 wp-blog-header.php
-rw-r--r--  1 root root  2323 Nov 24 13:09 wp-comments-post.php
-rw-r--r--  1 root root  4908 Nov 24 13:09 wp-config-sample.php
drwxr-xr-x  5 root root  4096 Nov 24 13:09 wp-content
-rw-r--r--  1 root root  5617 Nov 24 13:09 wp-cron.php
drwxr-xr-x 30 root root 16384 Nov 24 13:09 wp-includes
-rw-r--r--  1 root root  2502 Nov 24 13:09 wp-links-opml.php
-rw-r--r--  1 root root  3937 Nov 24 13:09 wp-load.php
-rw-r--r--  1 root root 51414 Nov 24 13:09 wp-login.php
-rw-r--r--  1 root root  8727 Nov 24 13:09 wp-mail.php
-rw-r--r--  1 root root 30081 Nov 24 13:09 wp-settings.php
-rw-r--r--  1 root root 34516 Nov 24 13:09 wp-signup.php
-rw-r--r--  1 root root  5102 Nov 24 13:09 wp-trackback.php
-rw-r--r--  1 root root  3205 Nov 24 13:09 xmlrpc.php

mkdir /var/www/html/wordpress/wp-content/uploads

chown -R www-data:www-data /var/www/html/wordpress/

?? chmod 640 /var/www/html/wordpress/wp-config.php

ps afx

root@http:/var/www/html/wordpress# mysql
CREATE DATABASE wordpress_db;
CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'Et6zdaf0y9yfbYBmvaQR';
GRANT ALL ON wordpress_db.* TO 'wp_user'@'localhost';
exit

cp wp-config-sample.php wp-config.php

nano wp-config.php
- 'DB_NAME' = wordpress_db
- 'DB_USER' = wp_user
- 'DB_PASSWORD' = Et6zdaf0y9yfbYBmvaQR

root@wordpress:/var/www/html/wordpress# cd /etc/angie/
root@wordpress:/etc/angie# ls -la
total 60
drwxr-xr-x   4 root root  4096 Mar  7 22:14 .
drwxr-xr-x 113 root root  4096 Mar  7 22:15 ..
-rw-r--r--   1 root root  1230 Feb  6 10:05 angie.conf
-rw-r--r--   1 root root  1086 Feb  5 22:32 fastcgi.conf
-rw-r--r--   1 root root  1016 Feb  5 22:32 fastcgi_params
drwxr-xr-x   2 root root  4096 Mar  7 22:14 http.d
-rw-r--r--   1 root root  5354 Feb  5 22:32 mime.types
lrwxrwxrwx   1 root root    22 Feb  6 10:05 modules -> /usr/lib/angie/modules
-rw-r--r--   1 root root 15908 Feb  5 22:32 prometheus_all.conf
-rw-r--r--   1 root root   645 Feb  5 22:32 scgi_params
drwxr-xr-x   2 root root  4096 Mar  7 22:14 stream.d
-rw-r--r--   1 root root   673 Feb  5 22:32 uwsgi_params

root@wordpress:/etc/angie# nano angie.conf
- user = www-data

root@wordpress:/etc/angie# cd http.d/
root@wordpress:/etc/angie/http.d# ls -la
total 12
drwxr-xr-x 2 root root 4096 Mar  7 22:14 .
drwxr-xr-x 4 root root 4096 Mar  7 23:13 ..
-rw-r--r-- 1 root root 1177 Feb  6 10:05 default.conf




















```
