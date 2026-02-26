## [MySQL Репликация (REBRAIN)](https://my.rebrainme.com/video/1358?course=podpiska-linux)
![GTID](https://github.com/user-attachments/assets/6b254659-e2f3-48d4-872e-c8a6d4786433)
![binlog position](https://github.com/user-attachments/assets/46c38fe7-6635-4b4b-9b4d-6d9691fa0bca)
![Screenshot_2026-02-26-11-10-02-398_com alphainventor filemanager](https://github.com/user-attachments/assets/47c91ddc-7bcd-4f5d-97b9-a3932e495774)
![Screenshot_2026-02-26-11-12-37-263_com alphainventor filemanager](https://github.com/user-attachments/assets/ab0e2011-39b2-4cb9-b4f7-3bcf184fc4db)


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
