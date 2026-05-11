## «Отказоустойчивый кластер MySQL»

[Видеоматериалы | REBRAIN | Отказоустойчивый кластер MySQL](https://my.rebrainme.com/video/1367?course=podpiska-linux)  
[MySQL master-master репликация, keepalived](https://docs.google.com/presentation/d/1fNKB4QXbhmnweuIKdX3LCHnE00FFm_JFoTya-4N-6wk)

**Цель задания: **.  
1. Репликая Master-Master (aka Master-Slave в обе стороны)

**Выполнение задания**:

1) Настройка репликации на mysql01, mysql02:

```console
root@vm-mysql01:~# mysql

MariaDB [(none)]> SELECT user, host FROM mysql.user;
+-------------+-----------+
| User        | Host      |
+-------------+-----------+
| mariadb.sys | localhost |
| mysql       | localhost |
| root        | localhost |
+-------------+-----------+
3 rows in set (0.001 sec)

MariaDB [(none)]> CREATE USER 'slave'@'%' IDENTIFIED BY 's0SaNfR63zi3g7rvlbNE';
Query OK, 0 rows affected (0.003 sec)

MariaDB [(none)]> SHOW GRANTS FOR 'slave'@'%';
+------------------------------------------------------------------------------------------------------+
| Grants for slave@%                                                                                   |
+------------------------------------------------------------------------------------------------------+
| GRANT USAGE ON *.* TO `slave`@`%` IDENTIFIED BY PASSWORD '*5ECC7DB446FCB56DBC23F502E4708FDDE478D92F' |
+------------------------------------------------------------------------------------------------------+
1 row in set (0.000 sec)

MariaDB [(none)]> GRANT REPLICATION SLAVE ON *.* TO 'slave'@'%';
Query OK, 0 rows affected (0.005 sec)

MariaDB [(none)]> SHOW GRANTS FOR 'slave'@'%';
+------------------------------------------------------------------------------------------------------------------+
| Grants for slave@%                                                                                               |
+------------------------------------------------------------------------------------------------------------------+
| GRANT REPLICATION SLAVE ON *.* TO `slave`@`%` IDENTIFIED BY PASSWORD '*5ECC7DB446FCB56DBC23F502E4708FDDE478D92F' |
+------------------------------------------------------------------------------------------------------------------+
1 row in set (0.000 sec)
```

Настройка репликации на mysql02
```console
root@vm-mysql02:~# mysql

MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='192.168.1.121', MASTER_USER='slave', MASTER_PASSWORD='s0SaNfR63zi3g7rvlbNE', MASTER_LOG_FILE = 'mysql-bin.000001', MASTER_LOG_POS = 328;
Query OK, 0 rows affected, 1 warning (0.012 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State:
                   Master_Host: 192.168.1.121
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
Query OK, 0 rows affected, 1 warning (0.000 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.121
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000002
           Read_Master_Log_Pos: 328
                Relay_Log_File: mysqld-relay-bin.000004
                 Relay_Log_Pos: 627
         Relay_Master_Log_File: mysql-bin.000002
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
               Relay_Log_Space: 1236
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

Настройка репликации на mysql01
```console
MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='192.168.1.122', MASTER_USER='slave', MASTER_PASSWORD='s0SaNfR63zi3g7rvlbNE', MASTER_LOG_FILE = 'mysql-bin.000001', MASTER_LOG_POS = 328;
Query OK, 0 rows affected, 1 warning (0.009 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State:
                   Master_Host: 192.168.1.122
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
Query OK, 0 rows affected (0.002 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.122
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
              Master_Server_Id: 2
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

Настройка репликации на mysql02 посредством GTID
```console
MariaDB [(none)]> STOP SLAVE;
Query OK, 0 rows affected (0.003 sec)

MariaDB [(none)]> SHOW VARIABLES LIKE '%gtid%';
+-------------------------+-------------+
| Variable_name           | Value       |
+-------------------------+-------------+
| gtid_binlog_pos         | 0-2-4       |
| gtid_binlog_state       | 0-1-2,0-2-4 |
| gtid_cleanup_batch_size | 64          |
| gtid_current_pos        | 0-2-4       |
| gtid_domain_id          | 0           |
| gtid_ignore_duplicates  | OFF         |
| gtid_pos_auto_engines   |             |
| gtid_seq_no             | 0           |
| gtid_slave_pos          | 0-2-4       |
| gtid_strict_mode        | OFF         |
| last_gtid               | 0-1-2       |
| wsrep_gtid_domain_id    | 0           |
| wsrep_gtid_mode         | OFF         |
| wsrep_gtid_seq_no       | 0           |
+-------------------------+-------------+
14 rows in set (0.001 sec)

MariaDB [(none)]> RESET SLAVE;
Query OK, 0 rows affected, 1 warning (0.005 sec)

MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='192.168.1.121', MASTER_USER='slave', MASTER_PASSWORD='s0SaNfR63zi3g7rvlbNE';
Query OK, 0 rows affected (0.015 sec)

MariaDB [(none)]> CHANGE MASTER TO MASTER_USE_GTID = current_pos;
Query OK, 0 rows affected (0.010 sec)

MariaDB [(none)]> SHOW VARIABLES LIKE '%gtid%';
+-------------------------+-------------+
| Variable_name           | Value       |
+-------------------------+-------------+
| gtid_binlog_pos         | 0-2-8       |
| gtid_binlog_state       | 0-1-7,0-2-8 |
| gtid_cleanup_batch_size | 64          |
| gtid_current_pos        | 0-2-8       |
| gtid_domain_id          | 0           |
| gtid_ignore_duplicates  | OFF         |
| gtid_pos_auto_engines   |             |
| gtid_seq_no             | 0           |
| gtid_slave_pos          | 0-2-8       |
| gtid_strict_mode        | OFF         |
| last_gtid               | 0-2-8       |
| wsrep_gtid_domain_id    | 0           |
| wsrep_gtid_mode         | OFF         |
| wsrep_gtid_seq_no       | 0           |
+-------------------------+-------------+
14 rows in set (0.001 sec)

# если gtid_slave_pos различается между нодами, то SET GLOBAL gtid_slave_pos = '2-4-8 (domain_id-server_id-sequence_number)';

MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.006 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.121
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 1478
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 686
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
           Exec_Master_Log_Pos: 1478
               Relay_Log_Space: 996
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
                    Using_Gtid: Current_Pos
                   Gtid_IO_Pos: 0-2-8
       Replicate_Do_Domain_Ids:
   Replicate_Ignore_Domain_Ids:
                 Parallel_Mode: optimistic
                     SQL_Delay: 0
           SQL_Remaining_Delay: NULL
       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
              Slave_DDL_Groups: 4
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 0
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)
```

Настройка репликации на mysql01 посредством GTID
```console
MariaDB [(none)]> STOP SLAVE;
Query OK, 0 rows affected (0.008 sec)

MariaDB [(none)]> RESET SLAVE;
Query OK, 0 rows affected, 1 warning (0.005 sec)

MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='192.168.1.122', MASTER_USER='slave', MASTER_PASSWORD='s0SaNfR63zi3g7rvlbNE';
Query OK, 0 rows affected (0.011 sec)

MariaDB [(none)]> CHANGE MASTER TO MASTER_USE_GTID = current_pos;
Query OK, 0 rows affected (0.010 sec)

MariaDB [(none)]> SHOW VARIABLES LIKE '%gtid%';
+-------------------------+-------------+
| Variable_name           | Value       |
+-------------------------+-------------+
| gtid_binlog_pos         | 0-2-8       |
| gtid_binlog_state       | 0-1-7,0-2-8 |
| gtid_cleanup_batch_size | 64          |
| gtid_current_pos        | 0-2-8       |
| gtid_domain_id          | 0           |
| gtid_ignore_duplicates  | OFF         |
| gtid_pos_auto_engines   |             |
| gtid_seq_no             | 0           |
| gtid_slave_pos          | 0-2-8       |
| gtid_strict_mode        | OFF         |
| last_gtid               | 0-1-7       |
| wsrep_gtid_domain_id    | 0           |
| wsrep_gtid_mode         | OFF         |
| wsrep_gtid_seq_no       | 0           |
+-------------------------+-------------+
14 rows in set (0.001 sec)

MariaDB [(none)]> START SLAVE;
Query OK, 0 rows affected (0.011 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.1.122
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000001
           Read_Master_Log_Pos: 1478
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 686
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
           Exec_Master_Log_Pos: 1478
               Relay_Log_Space: 996
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
              Master_Server_Id: 2
                Master_SSL_Crl:
            Master_SSL_Crlpath:
                    Using_Gtid: Current_Pos
                   Gtid_IO_Pos: 0-2-8
       Replicate_Do_Domain_Ids:
   Replicate_Ignore_Domain_Ids:
                 Parallel_Mode: optimistic
                     SQL_Delay: 0
           SQL_Remaining_Delay: NULL
       Slave_SQL_Running_State: Slave has read all relay log; waiting for more updates
              Slave_DDL_Groups: 2
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 0
          Replicate_Rewrite_DB:
1 row in set (0.000 sec)
```

Проверим работоспособность
```console
# mysql01
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

MariaDB [(none)]> CREATE DATABASE test123;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test123            |
+--------------------+
5 rows in set (0.000 sec)

# mysql02
MariaDB [(none)]> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
| test123            |
+--------------------+
5 rows in set (0.000 sec)

MariaDB [(none)]> DROP DATABASE test123;
Query OK, 0 rows affected (0.008 sec)

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

**метод репликации Master-Master предоставляет возможность быстрой перенастройки репликации с одной ноды на другую; для этого:**
```console
MariaDB [(none)]> STOP SLAVE;
MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='192.168.XXX.XXX', MASTER_USER='slave', MASTER_PASSWORD='s0SaNfR63zi3g7rvlbNE';
MariaDB [(none)]> START SLAVE;
```














**Практическое задание выполнено**.

<br/>

[Вернуться к списку всех заданий](../README.md)
****
