## Практическая работа № 4 — «Установка MySQL-сервера и настройка репликации (OTUS Linux Admin Basic)»

**Цель практического задания: **.

**Выполнение практического задания**:

1) binlog position:
2) GTID


LET`S START: mysql-master SIDE 
```console
root@mysql-master:~# mysql --version
root@mysql-master:~# cd /etc/mysql/mysql.conf.d/
root@mysql-master:/etc/mysql/mysql.conf.d# nano mysqld.cnf
# bind-address = 0.0.0.0
# server-id = 1
# binlog_format = row
# gtid-mode = on
# enforce-gtid-consistency
# log-replica-updates

root@mysql-master:/etc/mysql/mysql.conf.d# service mysql restart

root@mysql-master:/etc/mysql/mysql.conf.d# ps afx | grep mysql
   2087 pts/0    S+     0:00          \_ grep --color=auto mysql
   2027 ?        Ssl    0:02 /usr/sbin/mysqld

root@mysql-master:/etc/mysql/mysql.conf.d# cd ..
root@mysql-master:/etc/mysql/mysql.conf.d# mysql
mysql> SHOW MASTER STATUS; # данная комманда служит для определения binlog позиции; в данном примере не используется
+---------------+----------+--------------+------------------+-------------------+
| File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+---------------+----------+--------------+------------------+-------------------+
| binlog.000009 |      157 |              |                  |                   |
+---------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

mysql> CREATE USER repl@'%' IDENTIFIED WITH 'caching_sha2_password' BY 'p7+kRwqR=bZc8V.@d-qt'; # создадим нового пользователя
Query OK, 0 rows affected (0.01 sec)

mysql> GRANT REPLICATION SLAVE ON *.* TO repl@'%'; # выдадим права пользователю repl@'%' (с любого хоста) на все БД, таблицы (*.*) 
Query OK, 0 rows affected (0.01 sec)

mysql> SELECT User, Host FROM mysql.user;
+------------------+-----------+
| User             | Host      |
+------------------+-----------+
| repl             | %         |
| debian-sys-maint | localhost |
| mysql.infoschema | localhost |
| mysql.session    | localhost |
| mysql.sys        | localhost |
| root             | localhost |
+------------------+-----------+
6 rows in set (0.01 sec)

mysql>











```


2) GTID


**Практическое задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
****
