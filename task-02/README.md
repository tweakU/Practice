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
| mysql-bin.000001 |      328 |              |                  |
+------------------+----------+--------------+------------------+
1 row in set (0.000 sec)

MariaDB [(none)]> SHOW MASTER STATUS \G
*************************** 1. row ***************************
            File: mysql-bin.000001
        Position: 328
    Binlog_Do_DB:
Binlog_Ignore_DB:
1 row in set (0.000 sec)
```

Создадим пользователя test для работы mysqlslap:
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
MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='192.168.21.178', MASTER_USER='slave', MASTER_PASSWORD='s0SaNfR63zi3g7rvlbNE', MASTER_LOG_FILE = 'mysql-bin.000001', MASTER_LOG_POS = 328;
Query OK, 0 rows affected, 1 warning (0.014 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State:
                   Master_Host: 192.168.21.178
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 328
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
           Exec_Master_Log_Pos: 328
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
       Slave_SQL_Running_State:
              Slave_DDL_Groups: 504
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 106450
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)

MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.21.178
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 328
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
           Exec_Master_Log_Pos: 328
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
              Slave_DDL_Groups: 504
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 106450
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)

MariaDB [(none)]>
```

Ситуация, когда binlog "догоняет:" 
```console
**MYSQL02-SRV:**
MariaDB [(none)]> STOP SLAVE;
Query OK, 0 rows affected (0.006 sec)

MariaDB [(none)]> RESET SLAVE ALL;
Query OK, 0 rows affected, 1 warning (0.005 sec)


**MYSQL01-SRV:**
MariaDB [(none)]> CREATE DATABASE t123;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> CREATE DATABASE t1234;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> DROP DATABASE t123;
Query OK, 0 rows affected (0.007 sec)

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| t1234              |
+--------------------+
5 rows in set (0.000 sec)

MariaDB [(none)]> SHOW MASTER STATUS \G
*************************** 1. row ***************************
            File: mysql-bin.000001
        Position: 724
    Binlog_Do_DB:
Binlog_Ignore_DB:
1 row in set (0.000 sec)
```
ВЫВОД: если начать репликацию с Position: 724, Slave не увидит изменений выше (и это лигично), поэтому нужно использовать позицию binlog до изменений в БД.

ДАЛЕЕ:

Cимулируем нагрузку на БД:
```console
root@mysql03:~# time mysqlslap -h 192.168.21.178 -utest -ptest --concurrency=50 --iterations=1000 --number-int-cols=5 --number-char-cols=20 --auto-generate-sql --auto-generate-sql-load-type=write --verbose
```

```console
MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| mysqlslap          |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.001 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.21.178
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 181992679
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 126894221
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
           Exec_Master_Log_Pos: 126893994
               Relay_Log_Space: 181993216
               Until_Condition: None
                Until_Log_File:
                 Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File:
            Master_SSL_CA_Path:
               Master_SSL_Cert:
             Master_SSL_Cipher:
                Master_SSL_Key:
         Seconds_Behind_Master: 4
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
              Slave_DDL_Groups: 2276
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 488287
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)
```

**(Hard shutdown for Master (@mysql01)** (имитация физического падения сервера):
```console

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.21.178
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 784321388
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 666987959
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
           Exec_Master_Log_Pos: 666987732
               Relay_Log_Space: 784321925
               Until_Condition: None
                Until_Log_File:
                 Until_Log_Pos: 0
            Master_SSL_Allowed: No
            Master_SSL_CA_File:
            Master_SSL_CA_Path:
               Master_SSL_Cert:
             Master_SSL_Cipher:
                Master_SSL_Key:
         Seconds_Behind_Master: 17
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
              Slave_DDL_Groups: 2732
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 586645
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Reconnecting after a failed master event read
                   Master_Host: 192.168.21.178
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 784321388
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 784321615
         Relay_Master_Log_File: mysql-bin.000001
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
           Exec_Master_Log_Pos: 784321388
               Relay_Log_Space: 784321925
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
       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
              Slave_DDL_Groups: 2831
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 608012
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Reconnecting after a failed master event read
                   Master_Host: 192.168.21.178
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 784321388
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 784321615
         Relay_Master_Log_File: mysql-bin.000001
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
           Exec_Master_Log_Pos: 784321388
               Relay_Log_Space: 784321925
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
                 Last_IO_Errno: 2003
                 Last_IO_Error: error reconnecting to master 'slave@192.168.21.178:3306' - retry-time: 60  maximum-retries: 100000  message: Can't connect to server on '192.168.21.178' (113 "No route to host")
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
              Slave_DDL_Groups: 2831
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 608012
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)

MariaDB [(none)]>
```

Стартуем MASTER:
```console
MariaDB [(none)]> SHOW MASTER STATUS \G
*************************** 1. row ***************************
            File: mysql-bin.000002
        Position: 342
    Binlog_Do_DB:
Binlog_Ignore_DB:
1 row in set (0.000 sec)

MariaDB [(none)]>
```

SLAVE подключился к MASTER с ошибкой #1236:
```console
MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State:
                   Master_Host: 192.168.21.178
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 784321388
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 784321615
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
           Exec_Master_Log_Pos: 784321388
               Relay_Log_Space: 784321925
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
                 Last_IO_Error: Got fatal error 1236 from master when reading data from binary log: 'Client requested master to start replication from impossible position; the first event 'mysql-bin.000001' at 784321388, the last event read from 'mysql-bin.000001' at 4, the last byte read from 'mysql-bin.000001' at 4.'
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
              Slave_DDL_Groups: 2831
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 608012
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)
```

С параметрами максимальной производительности движка ...
```console
innodb_flush_log_at_trx_commit = 2  
sync_binlog = 0
```
... при смерти MASTER, SLAVE получит ошибку #1236 (в binlog на MASTER отсутствует след. позиция, которую готов получать SLAVE) ... 
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
... единсвенный способо устранить ошибку #1236 - снять dump с MASTER, применить его на SLAVE и заново настроить репликацию. 


Наигрались с параметрами максимальной производительности.
Пришло время параметров максимальной стабильности:
SLAVE:
```console
MariaDB [(none)]> STOP SLAVE;
Query OK, 0 rows affected (0.005 sec)

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| mysqlslap          |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.000 sec)

MariaDB [(none)]> DROP DATABASE mysqlslap;
Query OK, 1 row affected (0.010 sec)
```

MASTER:
```console
MariaDB [(none)]> DROP DATABASE mysqlslap;
Query OK, 1 row affected (0.013 sec)

MariaDB [(none)]> SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000007 |      488 |              |                  |
+------------------+----------+--------------+------------------+
1 row in set (0.000 sec)

MariaDB [(none)]>
```

SLAVE:
```console
MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='192.168.1.101', MASTER_USER='slave', MASTER_PASSWORD='s0SaNfR63zi3g7rvlbNE', MASTER_LOG_FILE='mysql-bin.000007', MASTER_LOG_POS=488;
Query OK, 0 rows affected, 1 warning (0.208 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: 
                   Master_Host: 192.168.1.101
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000007
           Read_Master_Log_Pos: 488
                Relay_Log_File: mysqld-relay-bin.000001
                 Relay_Log_Pos: 4
         Relay_Master_Log_File: mysql-bin.000007
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
           Exec_Master_Log_Pos: 488
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
       Slave_SQL_Running_State: 
              Slave_DDL_Groups: 240
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 51796
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.003 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.101
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000007
           Read_Master_Log_Pos: 488
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 555
         Relay_Master_Log_File: mysql-bin.000007
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
           Exec_Master_Log_Pos: 488
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
              Slave_DDL_Groups: 240
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 51796
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

# on the MASTER: MariaDB [(none)]> CREATE DATABASE DB_after_MASTER_down;

MariaDB [(none)]> SHOW DATABASES;
+----------------------+
| Database             |
+----------------------+
| DB_after_MASTER_down |
| information_schema   |
| mysql                |
| performance_schema   |
| sys                  |
+----------------------+
5 rows in set (0.001 sec)

# on the MASTER: MariaDB [(none)]> DROP DATABASE DB_after_MASTER_down;

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.000 sec)
```

MASTER:
```console
MariaDB [(none)]> set global innodb_flush_log_at_trx_commit = 1;
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> set global sync_binlog = 1;
Query OK, 0 rows affected (0.000 sec)

MariaDB [(none)]> SHOW VARIABLES WHERE Variable_Name like 'innodb_flush_log_at_trx_commit' or Variable_Name like 'sync_binlog';
+--------------------------------+-------+
| Variable_name                  | Value |
+--------------------------------+-------+
| innodb_flush_log_at_trx_commit | 1     |
| sync_binlog                    | 1     |
+--------------------------------+-------+
2 rows in set (0.001 sec)
```

HARD MASTER SHUTDOWN
RESTART MASTER

MASTER:
```console
MariaDB [(none)]> SHOW MASTER STATUS;
+------------------+----------+--------------+------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------------+----------+--------------+------------------+
| mysql-bin.000008 |      **342** |              |                  |
+------------------+----------+--------------+------------------+
1 row in set (0.000 sec)

MariaDB [(none)]>
```

SLAVE:
```console
MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.101
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000008
           Read_Master_Log_Pos: **342**
                Relay_Log_File: mysqld-relay-bin.000004
                 Relay_Log_Pos: 641
         Relay_Master_Log_File: mysql-bin.000008
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
           Exec_Master_Log_Pos: 342
               Relay_Log_Space: 1250
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
              Slave_DDL_Groups: 310
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 66074
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]>
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




**Практическое задание выполнено**.


<br/>


[Вернуться к списку всех ДЗ](../README.md)
****
