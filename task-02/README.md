## [MySQL Репликация (REBRAIN)](https://my.rebrainme.com/video/1358?course=podpiska-linux)

## Практическая работа № 4 — «MySQL master-slave репликация»

**Цель практического задания:**  
1) Репликация Master-Slave  
2) Тонкая настройка движка:  
- innodb_flush_log_at_trx_commit (способ обработки транзакций) 1=slow, 2=fast (#1236 не встречается);  
- sync_binlog (способ синхронизации) 0=fast (если умирает Master, 100% будет #1236), 1=reliability.
 
3) Репликация Master-Master

**Выполнение практического задания**:

**1) MASTER - SLAVE REPLICATION:**  

```console
**mysql01 srv**

root@mysql01:~# nano /etc/mysql/mariadb.conf.d/50-server.cnf 
bind-address = 0.0.0.0
server-id = 1 (2, 3 etc, UNIQUE NAME PREFER - LIKE HOST IP-ADDRESS)
log_bin = /var/log/mysql/mysql-bin.log
binlog-format = ROW
log-slave-updates = 1

root@mysql01:~# mkdir -p -m 2750 /var/log/mysql && chown mysql /var/log/mysql

root@vm-mysql01:~# service mariadb restart

root@mysql01:~# mysql
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
```

Создадим пользователя test для работы mysqlslap
```console
MariaDB [(none)]> CREATE USER 'test'@'%' IDENTIFIED BY 'test';
Query OK, 0 rows affected (0.064 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'test'@'%';
Query OK, 0 rows affected (0.010 sec)
```

Настроим движок на максимальную производительность:  
```console
MariaDB [(none)]> SHOW VARIABLES WHERE Variable_Name like 'innodb_flush_log_at_trx_commit' or Variable_Name like 'sync_binlog';
+--------------------------------+-------+
| Variable_name                  | Value |
+--------------------------------+-------+
| innodb_flush_log_at_trx_commit | 1     |
| sync_binlog                    | 0     |
+--------------------------------+-------+
2 rows in set (0.001 sec)

MariaDB [(none)]> SET GLOBAL innodb_flush_log_at_trx_commit = 2;
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> SET GLOBAL sync_binlog = 0;
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> SHOW VARIABLES WHERE Variable_Name like 'innodb_flush_log_at_trx_commit' or Variable_Name like 'sync_binlog';
+--------------------------------+-------+
| Variable_name                  | Value |
+--------------------------------+-------+
| innodb_flush_log_at_trx_commit | 2     |
| sync_binlog                    | 0     |
+--------------------------------+-------+
2 rows in set (0.001 sec)

MariaDB [(none)]> EXIT;
```


```console
**mysql02 srv**

root@mysql02:~# nano /etc/mysql/mariadb.conf.d/50-server.cnf 
server-id = 2 (3, 4 etc, UNIQUE NAME PREFER - LIKE HOST IP-ADDRESS)
log_bin = /var/log/mysql/mysql-bin.log
binlog-format = ROW
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
```

Cимулируем нагрузку на Master:
```console
root@mysql03:~# time mysqlslap -h 192.168.1.121 -utest -ptest --concurrency=50 --iterations=1000 --number-int-cols=5 --number-char-cols=20 --auto-generate-sql --auto-generate-sql-load-type=write --verbose
```

```console

```










**(Hard shutdown for Master (@mysql01)**
```console
MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.121
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 124866741
         Relay_Master_Log_File: mysql-bin.000004
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
           Exec_Master_Log_Pos: 124866528
               Relay_Log_Space: 356377338
               Until_Condition: None
                Until_Log_File: 
                 Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File: 
            Master_SSL_CA_Path: 
               Master_SSL_Cert: 
             Master_SSL_Cipher: 
                Master_SSL_Key: 
         Seconds_Behind_Master: 218
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
       Slave_SQL_Running_State: Commit
              Slave_DDL_Groups: 112
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 22740
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.121
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 139467822
         Relay_Master_Log_File: mysql-bin.000004
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
           Exec_Master_Log_Pos: 139467609
               Relay_Log_Space: 356377338
               Until_Condition: None
                Until_Log_File: 
                 Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File: 
            Master_SSL_CA_Path: 
               Master_SSL_Cert: 
             Master_SSL_Cipher: 
                Master_SSL_Key: 
         Seconds_Behind_Master: 230
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
       Slave_SQL_Running_State: Write_rows_log_event::write_row()
              Slave_DDL_Groups: 124
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 25399
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Reconnecting after a failed master event read
                   Master_Host: 192.168.1.121
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 143229146
         Relay_Master_Log_File: mysql-bin.000004
              Slave_IO_Running: Connecting
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
           Exec_Master_Log_Pos: 143228933
               Relay_Log_Space: 356377338
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
       Slave_SQL_Running_State: Commit
              Slave_DDL_Groups: 127
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 26084
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

```


```console
**SERVER mysql03**

root@mysql03:~# nano /etc/mysql/mariadb.conf.d/50-server.cnf 
server-id = 3 (4, 5 etc, UNIQUE NAME PREFER - LIKE HOST IP-ADDRESS)
log_bin = /var/log/mysql/mysql-bin.log
binlog-format = ROW
log-slave-updates = 1

root@mysql03:~# mkdir -p -m 2750 /var/log/mysql && chown mysql /var/log/mysql
root@mysql03:~# service mariadb restart

```


С параметрами максимальной производительности движка ...
```console
innodb_flush_log_at_trx_commit = 2  
sync_binlog = 0
```
... при смерти Master, Slave получит ошибку #1236 ... 
```console
MariaDB [(none)]> show slave status \G
*************************** 1. row ***************************
                Slave_IO_State:
                   Master_Host: 192.168.1.121
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 584533014
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 584531403
         Relay_Master_Log_File: mysql-bin.000001
              Slave_IO_Running: No
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
           Exec_Master_Log_Pos: 584533014
               Relay_Log_Space: 584531713
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
                 Last_IO_Errno: 1236
                 Last_IO_Error: Got fatal error 1236 from master when reading data from binary log: 'Client requested master to start replication from impossible position; the first event 'mysql-bin.000001' at 584533014, the last event read from 'mysql-bin.000001' at 4, the last byte read from 'mysql-bin.000001' at 4.'
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
              Slave_DDL_Groups: 502
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 106450
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)

MariaDB [(none)]>
```
... единсвенный способо устранить ошибку #1236 - снять dump с Master, применить его на Slave и заново настроить репликацию.


```console

```
































**Практическое задание выполнено**.


<br/>


[Вернуться к списку всех ДЗ](../README.md)
****
