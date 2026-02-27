## [MySQL Репликация (REBRAIN)](https://my.rebrainme.com/video/1358?course=podpiska-linux)

## Практическая работа № 4 — «MySQL master-slave репликация»

**Цель практического задания: **:  
1 Репликация Master-slave  
2 тонкая настройка  
3 Репликация Master-master

**Выполнение практического задания**:

**Master-slave replication:**
```console
**mysql-01**

root@mysql01:~# nano /etc/mysql/mariadb.conf.d/50-server.cnf 
bind-address = 0.0.0.0
server-id = 1 (2, 3 etc, UNIQUE NAME PREFER - LIKE HOST IP-ADDRESS)
log_bin = /var/log/mysql/mysql-bin.log
binlog-format = row
log-slave-updates = 1

root@mysql01:~# mkdir -p -m 2750 /var/log/mysql && chown mysql /var/log/mysql

root@vm-mysql01:~# service mariadb restart

root@mysql01:~# mysql
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 32
Server version: 10.11.14-MariaDB-0ubuntu0.24.04.1-log Ubuntu 24.04

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'slave'@'%' IDENTIFIED BY 's0SaNfR63zi3g7rvlbNE';
Query OK, 0 rows affected (0.007 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'slave'@'%';
Query OK, 0 rows affected (0.008 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> SHOW GRANTS FOR 'slave'@'%';
+---------------------------------------------------------------------------------------------------------------+
| Grants for slave@%                                                                                            |
+---------------------------------------------------------------------------------------------------------------+
| GRANT ALL PRIVILEGES ON *.* TO `slave`@`%` IDENTIFIED BY PASSWORD '*5ECC7DB446FCB56DBC23F502E4708FDDE478D92F' |
+---------------------------------------------------------------------------------------------------------------+
1 row in set (0.000 sec)

MariaDB [(none)]> SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000001 |     1076 |              |                  |
+------------------+----------+--------------+------------------+
1 row in set (0.000 sec)

MariaDB [(none)]> SHOW MASTER STATUS \G;
*************************** 1. row ***************************
            File: mysql-bin.000001
        Position: 1076
    Binlog_Do_DB: 
Binlog_Ignore_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]>
```

```console
**mysql-02**

root@mysql02:~# nano /etc/mysql/mariadb.conf.d/50-server.cnf 
server-id = 2 (3, 4 etc, UNIQUE NAME PREFER - LIKE HOST IP-ADDRESS)
log_bin = /var/log/mysql/mysql-bin.log
binlog-format = row
log-slave-updates = 1

root@mysql02:~# mkdir -p -m 2750 /var/log/mysql && chown mysql /var/log/mysql

root@mysql02:~# service mariadb restart

root@mysql02:~# mysql
MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='192.168.1.121', MASTER_USER='slave', MASTER_PASSWORD='s0SaNfR63zi3g7rvlbNE', MASTER_LOG_FILE = 'mysql-bin.000001', MASTER_LOG_POS = 777;
Query OK, 0 rows affected, 1 warning (0.014 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State:
                   Master_Host: 192.168.1.121
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 777
                Relay_Log_File: mysqld-relay-bin.000001
                 Relay_Log_Pos: 4
         Relay_Master_Log_File: mysql-bin.000001
              Slave_IO_Running: No
             Slave_SQL_Running: No
               Replicate_Do_DB:
           Replicate_Ignore_DB:
            Replicate_Do_Table:
        Replicate_Ignore_Table:
       Replicate_Wild_Do_Table:
   Replicate_Wild_Ignore_Table:
                    Last_Errno: 0
                    Last_Error:
                  Skip_Counter: 0
           Exec_Master_Log_Pos: 777
               Relay_Log_Space: 256
               Until_Condition: None
                Until_Log_File:
                 Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File:
            Master_SSL_CA_Path:
               Master_SSL_Cert:
             Master_SSL_Cipher:
                Master_SSL_Key:
         Seconds_Behind_Master: NULL
 Master_SSL_Verify_Server_Cert: No
                 Last_IO_Errno: 0
                 Last_IO_Error:
                Last_SQL_Errno: 0
                Last_SQL_Error:
   Replicate_Ignore_Server_Ids:
              Master_Server_Id: 0
                Master_SSL_Crl:
            Master_SSL_Crlpath:
                    Using_Gtid: No
                   Gtid_IO_Pos:
       Replicate_Do_Domain_Ids:
   Replicate_Ignore_Domain_Ids:
                 Parallel_Mode: optimistic
                     SQL_Delay: 0
           SQL_Remaining_Delay: NULL
       Slave_SQL_Running_State:
              Slave_DDL_Groups: 0
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 0
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)

MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.121
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 777
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 555
         Relay_Master_Log_File: mysql-bin.000001
              Slave_IO_Running: Yes
             Slave_SQL_Running: Yes
               Replicate_Do_DB:
           Replicate_Ignore_DB:
            Replicate_Do_Table:
        Replicate_Ignore_Table:
       Replicate_Wild_Do_Table:
   Replicate_Wild_Ignore_Table:
                    Last_Errno: 0
                    Last_Error:
                  Skip_Counter: 0
           Exec_Master_Log_Pos: 777
               Relay_Log_Space: 865
               Until_Condition: None
                Until_Log_File:
                 Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File:
            Master_SSL_CA_Path:
               Master_SSL_Cert:
             Master_SSL_Cipher:
                Master_SSL_Key:
         Seconds_Behind_Master: 0
 Master_SSL_Verify_Server_Cert: No
                 Last_IO_Errno: 0
                 Last_IO_Error:
                Last_SQL_Errno: 0
                Last_SQL_Error:
   Replicate_Ignore_Server_Ids:
              Master_Server_Id: 1
                Master_SSL_Crl:
            Master_SSL_Crlpath:
                    Using_Gtid: No
                   Gtid_IO_Pos:
       Replicate_Do_Domain_Ids:
   Replicate_Ignore_Domain_Ids:
                 Parallel_Mode: optimistic
                     SQL_Delay: 0
           SQL_Remaining_Delay: NULL
       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
              Slave_DDL_Groups: 0
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 0
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)

MariaDB [(none)]>


















```

```console
**mysql-03**

root@mysql03:~# nano /etc/mysql/mariadb.conf.d/50-server.cnf 
server-id = 3 (4, 5 etc, UNIQUE NAME PREFER - LIKE HOST IP-ADDRESS)
log_bin = /var/log/mysql/mysql-bin.log
binlog-format = row
log-slave-updates = 1

root@mysql03:~# mkdir -p -m 2750 /var/log/mysql && chown mysql /var/log/mysql
root@mysql03:~# service mariadb restart

root@mysql03:~# mysql

```




**Практическое задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
****
