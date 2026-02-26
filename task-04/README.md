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


```


2) GTID


**Практическое задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
****
