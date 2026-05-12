## «Отказоустойчивый кластер MySQL»

[Видеоматериалы | REBRAIN | Отказоустойчивый кластер MySQL](https://my.rebrainme.com/video/1367?course=podpiska-linux)  
[MySQL master-master репликация, keepalived](https://docs.google.com/presentation/d/1fNKB4QXbhmnweuIKdX3LCHnE00FFm_JFoTya-4N-6wk)

**Цель задания: **.  
1. Репликая Master-Master (aka Master-Slave в обе стороны)
2. ДОПИСАТЬ ЦЕЛИ

**Выполнение задания**:

Настройка репликации на mysql01, mysql02:

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

Проверка работоспособности:
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

**!! Метод репликации Master-Master предоставляет возможность быстрой перенастройки репликации с одной ноды на другую; для этого:**
```console
MariaDB [(none)]> STOP SLAVE;
MariaDB [(none)]> CHANGE MASTER TO MASTER_HOST='192.168.XXX.XXX', MASTER_USER='slave', MASTER_PASSWORD='s0SaNfR63zi3g7rvlbNE';
MariaDB [(none)]> START SLAVE;
```

**!! Как выяснить GTID на основании binlog`а и его позиции**
```console
MariaDB [(none)]> SELECT BINLOG_GTID_POS('mysql-bin.000001', 659);
```


**!! ПРОСЛУШАТЬ С 01:06:00 ПО х3 **


**Настройка keepalived**

Настройка keepalived.conf:
```console
vrrp_script check_mysql {
    script "nc -z localhost 3306" # cheaper than pidof
    interval 2                    # check every 2 seconds
    fall 1
    rise 2
}

vrrp_instance db {
    state MASTER
    interface enp1s0
    virtual_router_id 11
    priority 200
    advert_int 1

    preempt_delay 0
    virtual_ipaddress {
        192.168.21.93/24        
    }
    track_script {
        check_mysql
    }
}
```

Добавление пользователя:
```console
root@vm-mysql01:~# useradd --system --no-create-home --shell /usr/sbin/nologin keepalived_script
```

Проверка работоспособности:
```console
root@vm-mysql01:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:a8:f0:f6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.21.91/24 brd 192.168.21.255 scope global enp0s3
       valid_lft forever preferred_lft forever

root@vm-mysql01:~# systemctl start keepalived.service

root@vm-mysql01:~# systemctl status keepalived.service
● keepalived.service - Keepalive Daemon (LVS and VRRP)
     Loaded: loaded (/usr/lib/systemd/system/keepalived.service; enabled; preset: enabled)
     Active: active (running) since Tue 2026-05-12 18:55:12 MSK; 4s ago
       Docs: man:keepalived(8)
             man:keepalived.conf(5)
             man:genhash(1)
             https://keepalived.org
   Main PID: 5521 (keepalived)
      Tasks: 2 (limit: 1033)
     Memory: 1.8M (peak: 2.3M)
        CPU: 15ms
     CGroup: /system.slice/keepalived.service
             ├─5521 /usr/sbin/keepalived --dont-fork
             └─5522 /usr/sbin/keepalived --dont-fork

May 12 18:55:12 vm-mysql01 Keepalived[5521]: Command line: '/usr/sbin/keepalived' '--dont-fork'
May 12 18:55:12 vm-mysql01 Keepalived[5521]: Configuration file /etc/keepalived/keepalived.conf
May 12 18:55:12 vm-mysql01 Keepalived[5521]: NOTICE: setting config option max_auto_priority should result in better keepalived performance
May 12 18:55:12 vm-mysql01 Keepalived[5521]: Starting VRRP child process, pid=5522
May 12 18:55:12 vm-mysql01 Keepalived_vrrp[5522]: SECURITY VIOLATION - scripts are being executed but script_security not enabled.
May 12 18:55:12 vm-mysql01 Keepalived[5521]: Startup complete
May 12 18:55:12 vm-mysql01 systemd[1]: Started keepalived.service - Keepalive Daemon (LVS and VRRP).
May 12 18:55:12 vm-mysql01 Keepalived_vrrp[5522]: VRRP_Script(check_mysql) succeeded
May 12 18:55:12 vm-mysql01 Keepalived_vrrp[5522]: (db) Entering BACKUP STATE
May 12 18:55:15 vm-mysql01 Keepalived_vrrp[5522]: (db) Entering MASTER STATE

root@vm-mysql01:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:a8:f0:f6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.21.91/24 brd 192.168.21.255 scope global enp0s3
       valid_lft forever preferred_lft forever
    inet 192.168.21.93/24 scope global secondary enp0s3
       valid_lft forever preferred_lft forever

root@vm-mysql02:~# systemctl start keepalived.service

root@vm-mysql02:~# systemctl status keepalived.service
● keepalived.service - Keepalive Daemon (LVS and VRRP)
     Loaded: loaded (/usr/lib/systemd/system/keepalived.service; enabled; preset: enabled)
     Active: active (running) since Tue 2026-05-12 19:05:23 MSK; 2s ago
       Docs: man:keepalived(8)
             man:keepalived.conf(5)
             man:genhash(1)
             https://keepalived.org
   Main PID: 5324 (keepalived)
      Tasks: 2 (limit: 1033)
     Memory: 1.8M (peak: 2.3M)
        CPU: 10ms
     CGroup: /system.slice/keepalived.service
             ├─5324 /usr/sbin/keepalived --dont-fork
             └─5325 /usr/sbin/keepalived --dont-fork

May 12 19:05:23 vm-mysql02 Keepalived[5324]: Running on Linux 6.8.0-111-generic #111-Ubuntu SMP PREEMPT_DYNAMIC Sat Apr 11 23:16:02 UTC 2026 (built f>
May 12 19:05:23 vm-mysql02 Keepalived[5324]: Command line: '/usr/sbin/keepalived' '--dont-fork'
May 12 19:05:23 vm-mysql02 Keepalived[5324]: Configuration file /etc/keepalived/keepalived.conf
May 12 19:05:23 vm-mysql02 Keepalived[5324]: NOTICE: setting config option max_auto_priority should result in better keepalived performance
May 12 19:05:23 vm-mysql02 Keepalived[5324]: Starting VRRP child process, pid=5325
May 12 19:05:23 vm-mysql02 Keepalived_vrrp[5325]: SECURITY VIOLATION - scripts are being executed but script_security not enabled.
May 12 19:05:23 vm-mysql02 Keepalived[5324]: Startup complete
May 12 19:05:23 vm-mysql02 systemd[1]: Started keepalived.service - Keepalive Daemon (LVS and VRRP).
May 12 19:05:23 vm-mysql02 Keepalived_vrrp[5325]: VRRP_Script(check_mysql) succeeded
May 12 19:05:23 vm-mysql02 Keepalived_vrrp[5325]: (db) Entering BACKUP STATE

root@vm-mysql02:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:00:a9:b9 brd ff:ff:ff:ff:ff:ff
    inet 192.168.21.92/24 brd 192.168.21.255 scope global enp0s3
       valid_lft forever preferred_lft forever

root@vm-mysql01:~# systemctl stop mariadb.service

root@vm-mysql01:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:a8:f0:f6 brd ff:ff:ff:ff:ff:ff
    inet 192.168.21.91/24 brd 192.168.21.255 scope global enp0s3
       valid_lft forever preferred_lft forever

root@vm-mysql02:~# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:00:a9:b9 brd ff:ff:ff:ff:ff:ff
    inet 192.168.21.92/24 brd 192.168.21.255 scope global enp0s3
       valid_lft forever preferred_lft forever
    inet 192.168.21.93/24 scope global secondary enp0s3
       valid_lft forever preferred_lft forever
```

**!! ПРОСЛУШАТЬ 01:30:00 ПО 01:31:30, ЗАФИКСИРОВАТЬ МЫСЛЬ**


**Практическое задание выполнено**.

<br/>

[Вернуться к списку всех заданий](../README.md)
****
