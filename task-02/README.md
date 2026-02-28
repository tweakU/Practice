## [MySQL Репликация (REBRAIN)](https://my.rebrainme.com/video/1358?course=podpiska-linux)

## Практическая работа № 4 — «MySQL master-slave репликация»

**Цель практического задания: **:  
1 Репликация Master-slave  
2 тонкая настройка (innodb_flush_log_at_trx_commit (способ обработки транзакций) 1=slow, 2=fast; sync_binlog (способ синхронизации) 0=fast 1=reliability)  
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

MariaDB [(none)]> CREATE USER 'test'@'%' IDENTIFIED BY 'test';
Query OK, 0 rows affected (0.064 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON *.* TO 'test'@'%';
Query OK, 0 rows affected (0.010 sec)

MariaDB [(none)]> SHOW VARIABLES WHERE Variable_Name like 'innodb_flush_log_at_trx_commit' or Variable_Name like 'sync_binlog';
+--------------------------------+-------+
| Variable_name                  | Value |
+--------------------------------+-------+
| innodb_flush_log_at_trx_commit | 1     |
| sync_binlog                    | 0     |
+--------------------------------+-------+
2 rows in set (0.001 sec)

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

MariaDB [(none)]> STOP SLAVE;
Query OK, 0 rows affected (0.008 sec)

MariaDB [(none)]> RESET SLAVE ALL;
Query OK, 0 rows affected, 1 warning (0.001 sec)

MariaDB [(none)]> SHOW WARNINGS;
+-------+------+---------------------------------------------------------------------------------------+
| Level | Code | Message                                                                               |
+-------+------+---------------------------------------------------------------------------------------+
| Note  | 4190 | RESET SLAVE is implicitly changing the value of 'Using_Gtid' from 'No' to 'Slave_Pos' |
+-------+------+---------------------------------------------------------------------------------------+
1 row in set (0.000 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G
Empty set (0.000 sec)

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 124272782
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
           Exec_Master_Log_Pos: 124272569
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
              Slave_DDL_Groups: 109
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 22632
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

!! SHUTDOWN MASTER HARD

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
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
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 125294899
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
           Exec_Master_Log_Pos: 125294686
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
       Slave_SQL_Running_State: Write_rows_log_event::write_row()
              Slave_DDL_Groups: 112
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 22818
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 127748902
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
           Exec_Master_Log_Pos: 127748689
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
         Seconds_Behind_Master: 221
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
    Slave_Transactional_Groups: 23265
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 128397637
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
           Exec_Master_Log_Pos: 128397424
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
         Seconds_Behind_Master: 221
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
              Slave_DDL_Groups: 115
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 23383
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 128858731
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
           Exec_Master_Log_Pos: 128858518
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
         Seconds_Behind_Master: 221
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
              Slave_DDL_Groups: 115
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 23467
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 129522896
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
           Exec_Master_Log_Pos: 129522683
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
         Seconds_Behind_Master: 222
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
              Slave_DDL_Groups: 115
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 23588
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 130132426
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
           Exec_Master_Log_Pos: 130132213
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
         Seconds_Behind_Master: 223
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
              Slave_DDL_Groups: 115
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 23699
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 130643067
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
           Exec_Master_Log_Pos: 130642854
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
         Seconds_Behind_Master: 223
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
              Slave_DDL_Groups: 115
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 23792
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 131120754
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
           Exec_Master_Log_Pos: 131120541
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
         Seconds_Behind_Master: 223
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
              Slave_DDL_Groups: 115
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 23879
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 131625738
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
           Exec_Master_Log_Pos: 131625525
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
         Seconds_Behind_Master: 224
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
              Slave_DDL_Groups: 115
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 23971
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 132016528
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
           Exec_Master_Log_Pos: 132016315
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
         Seconds_Behind_Master: 225
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
              Slave_DDL_Groups: 118
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24042
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 132395291
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
           Exec_Master_Log_Pos: 132395078
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
         Seconds_Behind_Master: 224
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
              Slave_DDL_Groups: 118
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24111
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 132751991
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
           Exec_Master_Log_Pos: 132751778
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
         Seconds_Behind_Master: 225
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
              Slave_DDL_Groups: 118
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24176
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 133224046
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
           Exec_Master_Log_Pos: 133223833
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
         Seconds_Behind_Master: 224
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
              Slave_DDL_Groups: 118
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24262
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 133756636
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
           Exec_Master_Log_Pos: 133756423
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
         Seconds_Behind_Master: 225
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
              Slave_DDL_Groups: 118
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24359
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 134239787
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
           Exec_Master_Log_Pos: 134239574
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
         Seconds_Behind_Master: 226
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
              Slave_DDL_Groups: 118
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24447
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 134739335
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
           Exec_Master_Log_Pos: 134739122
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
         Seconds_Behind_Master: 227
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
              Slave_DDL_Groups: 118
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24538
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 135233371
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
           Exec_Master_Log_Pos: 135233158
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
         Seconds_Behind_Master: 228
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
              Slave_DDL_Groups: 118
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24628
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 135596680
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
           Exec_Master_Log_Pos: 135596467
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
         Seconds_Behind_Master: 227
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
              Slave_DDL_Groups: 121
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24694
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 135931527
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
           Exec_Master_Log_Pos: 135931314
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
         Seconds_Behind_Master: 227
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
              Slave_DDL_Groups: 121
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24755
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 136288228
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
           Exec_Master_Log_Pos: 136288015
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
         Seconds_Behind_Master: 228
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
              Slave_DDL_Groups: 121
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24820
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 136716426
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
           Exec_Master_Log_Pos: 136716213
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
         Seconds_Behind_Master: 228
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
              Slave_DDL_Groups: 121
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24898
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 137194097
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
           Exec_Master_Log_Pos: 137193884
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
         Seconds_Behind_Master: 228
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
              Slave_DDL_Groups: 121
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 24985
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 137693727
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
           Exec_Master_Log_Pos: 137693514
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
         Seconds_Behind_Master: 229
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
              Slave_DDL_Groups: 121
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 25076
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 138165867
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
           Exec_Master_Log_Pos: 138165654
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
       Slave_SQL_Running_State: Commit
              Slave_DDL_Groups: 121
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 25162
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 138681815
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
           Exec_Master_Log_Pos: 138681602
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
         Seconds_Behind_Master: 231
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
              Slave_DDL_Groups: 121
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 25256
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 139078083
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
           Exec_Master_Log_Pos: 139077870
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
         Seconds_Behind_Master: 231
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
              Slave_DDL_Groups: 124
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 25328
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
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
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 139884903
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
           Exec_Master_Log_Pos: 139884690
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
       Slave_SQL_Running_State: Commit
              Slave_DDL_Groups: 124
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 25475
          Replicate_Rewrite_DB: 
1 row in set (0.001 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 140373424
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
           Exec_Master_Log_Pos: 140373211
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
         Seconds_Behind_Master: 231
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
              Slave_DDL_Groups: 124
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 25564
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Waiting for master to send event
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 140834706
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
           Exec_Master_Log_Pos: 140834493
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
         Seconds_Behind_Master: 232
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
              Slave_DDL_Groups: 124
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 25648
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Reconnecting after a failed master event read
                   Master_Host: 192.168.58.111
                   Master_User: slave
                   Master_Port: 3306
                 Connect_Retry: 60
               Master_Log_File: mysql-bin.000004
           Read_Master_Log_Pos: 356376815
                Relay_Log_File: mysqld-relay-bin.000002
                 Relay_Log_Pos: 141295901
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
           Exec_Master_Log_Pos: 141295688
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
              Slave_DDL_Groups: 124
Slave_Non_Transactional_Groups: 0
    Slave_Transactional_Groups: 25732
          Replicate_Rewrite_DB: 
1 row in set (0.000 sec)

ERROR: No query specified

MariaDB [(none)]> SHOW SLAVE STATUS \G;
*************************** 1. row ***************************
                Slave_IO_State: Reconnecting after a failed master event read
                   Master_Host: 192.168.58.111
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
**mysql-03**

root@mysql03:~# nano /etc/mysql/mariadb.conf.d/50-server.cnf 
server-id = 3 (4, 5 etc, UNIQUE NAME PREFER - LIKE HOST IP-ADDRESS)
log_bin = /var/log/mysql/mysql-bin.log
binlog-format = row
log-slave-updates = 1

root@mysql03:~# mkdir -p -m 2750 /var/log/mysql && chown mysql /var/log/mysql
root@mysql03:~# service mariadb restart

root@mysql03:~# time mysqlslap -h 192.168.58.111 -utest -ptest --concurrency=50 --iterations=100 --number-int-cols=5 --number-char-cols=20 --auto-generate-sql --auto-generate-sql-load-type=write --verbose
mysqlslap: Error when connecting to server: Access denied for user 'test'@'192.168.58.113' (using password: YES)

real	0m0.072s
user	0m0.003s
sys	0m0.005s
root@mysql03:~# time mysqlslap -h 192.168.58.111 -utest -ptest --concurrency=50 --iterations=100 --number-int-cols=5 --number-char-cols=20 --auto-generate-sql --auto-generate-sql-load-type=write --verbose
mysqlslap: Cannot drop database 'mysqlslap' ERROR : Access denied for user 'test'@'%' to database 'mysqlslap'

real	0m0.009s
user	0m0.003s
sys	0m0.005s
root@mysql03:~# time mysqlslap -h 192.168.58.111 -utest -ptest --concurrency=50 --iterations=100 --number-int-cols=5 --number-char-cols=20 --auto-generate-sql --auto-generate-sql-load-type=write --verbose
Benchmark
	Average number of seconds to run all queries: 1.118 seconds
	Minimum number of seconds to run all queries: 0.922 seconds
	Maximum number of seconds to run all queries: 1.454 seconds
	Number of clients running queries: 50
	Average number of queries per client: 0


real	4m36.339s
user	0m1.423s
sys	0m8.876s
root@mysql03:~#











```




**Практическое задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
****
