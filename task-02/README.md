## [MySQL Репликация (REBRAIN)](https://my.rebrainme.com/video/1358?course=podpiska-linux)

## Практическая работа № 4 — «MySQL master-slave репликация»

**Цель практического задания: **.

**Выполнение практического задания**:

**mysql-01**
```console
root@mysql01:/etc/mysql/mariadb.conf.d# pwd
/etc/mysql/mariadb.conf.d
root@mysql01:/etc/mysql/mariadb.conf.d# nano 50-server.cnf
# bind-address = 0.0.0.0
# server-id = 1 (2, 3 etc, UNIQUE NAME PREFER - LIKE HOST IP-ADDRESS)
# log_bin = /var/log/mysql/mysql-bin.log
# binlog-format = row
# log-slave-updates = 1

root@mysql01:~# mysql
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 33
Server version: 10.11.14-MariaDB-0ubuntu0.24.04.1 Ubuntu 24.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.000 sec)

MariaDB [(none)]> CREATE USER 'slave'@'%' IDENTIFIED BY 'p7+kRwqR=bZc8V.@d-qt';
Query OK, 0 rows affected (0.005 sec)

MariaDB [(none)]> select user,host from mysql.user;
+-------------+-----------+
| User        | Host      |
+-------------+-----------+
| slave       | %         |
| username    | hostname  |
| mariadb.sys | localhost |
| mysql       | localhost |
| root        | localhost |
+-------------+-----------+
5 rows in set (0.001 sec)

MariaDB [(none)]> 
```

**mysql-02**
```console
root@mysql02:~# mysql
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 5
Server version: 10.11.14-MariaDB-0ubuntu0.24.04.1 Ubuntu 24.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.001 sec)

MariaDB [(none)]>

```

**mysql-03**  
```console

```




**Практическое задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
****
