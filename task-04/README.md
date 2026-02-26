## Практическая работа № 4 — «Установка MySQL-сервера и настройка репликации (OTUS Linux Admin Basic)»

**Цель практического задания: **.

**Выполнение практического задания**:

![GTID](https://github.com/user-attachments/assets/6b254659-e2f3-48d4-872e-c8a6d4786433)

![binlog position](https://github.com/user-attachments/assets/46c38fe7-6635-4b4b-9b4d-6d9691fa0bca)

mysql-master
![Screenshot_2026-02-26-11-10-02-398_com alphainventor filemanager](https://github.com/user-attachments/assets/47c91ddc-7bcd-4f5d-97b9-a3932e495774)
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

mysql> SHOW MASTER STATUS; # столбец "Executed_Gtid_Set" получил значение "ID сервера: диапозон выполненных транзакций"  
+---------------+----------+--------------+------------------+------------------------------------------+
| File          | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set                        |
+---------------+----------+--------------+------------------+------------------------------------------+
| binlog.000009 |      691 |              |                  | d84f56fa-12eb-11f1-936e-08002719c604:1-2 |
+---------------+----------+--------------+------------------+------------------------------------------+
1 row in set (0.00 sec)

mysql> SHOW PROCESSLIST;
+----+-----------------+----------------------+------+------------------+------+-----------------------------------------------------------------+------------------+
| Id | User            | Host                 | db   | Command          | Time | State                                                           | Info             |
+----+-----------------+----------------------+------+------------------+------+-----------------------------------------------------------------+------------------+
|  5 | event_scheduler | localhost            | NULL | Daemon           | 5560 | Waiting on empty queue                                          | NULL             |
| 10 | repl            | 192.168.21.166:39658 | NULL | Binlog Dump GTID |  254 | Source has sent all binlog to replica; waiting for more updates | NULL             |
| 11 | root            | localhost            | NULL | Query            |    0 | init                                                            | SHOW PROCESSLIST |
+----+-----------------+----------------------+------+------------------+------+-----------------------------------------------------------------+------------------+
3 rows in set, 1 warning (0.00 sec)

mysql> CREATE DATABASE OTUS;
Query OK, 1 row affected (0.01 sec)

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| OTUS               |
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
5 rows in set (0.00 sec)

mysql> USE OTUS;
Database changed
mysql> CREATE TABLE test_tbl (id int);
Query OK, 0 rows affected (0.02 sec)

mysql> INSERT INTO test_tbl values (2),(3),(4);
Query OK, 3 rows affected (0.01 sec)
Records: 3  Duplicates: 0  Warnings: 0

mysql> EXIT;

root@mysql-master:~/tmp# git clone https://github.com/datacharmer/test_db.git

root@mysql-master:~/tmp/test_db# mysql -t < ./employees.sql
+-----------------------------+
| INFO                        |
+-----------------------------+
| CREATING DATABASE STRUCTURE |
+-----------------------------+
+------------------------+
| INFO                   |
+------------------------+
| storage engine: InnoDB |
+------------------------+
+---------------------+
| INFO                |
+---------------------+
| LOADING departments |
+---------------------+
+-------------------+
| INFO              |
+-------------------+
| LOADING employees |
+-------------------+
+------------------+
| INFO             |
+------------------+
| LOADING dept_emp |
+------------------+
+----------------------+
| INFO                 |
+----------------------+
| LOADING dept_manager |
+----------------------+
+----------------+
| INFO           |
+----------------+
| LOADING titles |
+----------------+
+------------------+
| INFO             |
+------------------+
| LOADING salaries |
+------------------+
+---------------------+
| data_load_time_diff |
+---------------------+
| 00:00:38            |
+---------------------+
```


mysql-slave
![Screenshot_2026-02-26-11-12-37-263_com alphainventor filemanager](https://github.com/user-attachments/assets/ab0e2011-39b2-4cb9-b4f7-3bcf184fc4db)
```console
root@mysql-slave:~# mysql --version
root@mysql-slave:~# cd /etc/mysql/mysql.conf.d/
root@mysql-slave:/etc/mysql/mysql.conf.d# nano mysqld.cnf
# server-id = 2
# relay-log = relay-log-server
# read-only = on
# gtid-mode = on
# enforce-gtid-consistency
# log-replica-updates

root@mysql-slave:/etc/mysql/mysql.conf.d# service mysql restart

root@mysql-slave:/etc/mysql/mysql.conf.d# ps afx | grep mysql
   2087 pts/0    S+     0:00          \_ grep --color=auto mysql
   2027 ?        Ssl    0:02 /usr/sbin/mysqld

root@mysql-slave:/etc/mysql/mysql.conf.d# cd ..
root@mysql-slave:/etc/mysql/mysql.conf.d# mysql

mysql> STOP SLAVE;
Query OK, 0 rows affected, 2 warnings (0.00 sec)

mysql> SHOW WARNINGS;
+---------+------+-----------------------------------------------------------------------------------------------------+
| Level   | Code | Message                                                                                             |
+---------+------+-----------------------------------------------------------------------------------------------------+
| Warning | 1287 | 'STOP SLAVE' is deprecated and will be removed in a future release. Please use STOP REPLICA instead |
| Note    | 3084 | Replication thread(s) for channel '' are already stopped.                                           |
+---------+------+-----------------------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> CHANGE REPLICATION SOURCE TO SOURCE_HOST='192.168.21.165', SOURCE_USER='repl', SOURCE_PASSWORD='p7+kRwqR=bZc8V.@d-qt', SOURCE_AUTO_POSITION = 1, GET_SOURCE_PUBLIC_KEY = 1;
Query OK, 0 rows affected, 2 warnings (0.01 sec)

mysql> SHOW WARNINGS;
+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Level | Code | Message                                                                                                                                                                                                                                                                                          |
+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Note  | 1759 | Sending passwords in plain text without SSL/TLS is extremely insecure.                                                                                                                                                                                                                           |
| Note  | 1760 | Storing MySQL user name or password information in the connection metadata repository is not secure and is therefore not recommended. Please consider using the USER and PASSWORD connection options for START REPLICA; see the 'START REPLICA Syntax' in the MySQL Manual for more information. |
+-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
2 rows in set (0.00 sec)

mysql> START REPLICA;
Query OK, 0 rows affected (0.02 sec)

mysql> SHOW REPLICA STATUS \G
*************************** 1. row ***************************
             Replica_IO_State: Waiting for source to send event
                  Source_Host: 192.168.21.165
                  Source_User: repl
                  Source_Port: 3306
                Connect_Retry: 60
              Source_Log_File: binlog.000009
          Read_Source_Log_Pos: 691
               Relay_Log_File: relay-log-server.000002
                Relay_Log_Pos: 901
        Relay_Source_Log_File: binlog.000009
           Replica_IO_Running: Yes
          Replica_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Source_Log_Pos: 691
              Relay_Log_Space: 1112
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Source_SSL_Allowed: No
           Source_SSL_CA_File:
           Source_SSL_CA_Path:
              Source_SSL_Cert:
            Source_SSL_Cipher:
               Source_SSL_Key:
        Seconds_Behind_Source: 0
Source_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Source_Server_Id: 1
                  Source_UUID: d84f56fa-12eb-11f1-936e-08002719c604
             Source_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
    Replica_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Source_Retry_Count: 86400
                  Source_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Source_SSL_Crl:
           Source_SSL_Crlpath:
           Retrieved_Gtid_Set: d84f56fa-12eb-11f1-936e-08002719c604:1-2
            Executed_Gtid_Set: d84f56fa-12eb-11f1-936e-08002719c604:1-2
                Auto_Position: 1
         Replicate_Rewrite_DB:
                 Channel_Name:
           Source_TLS_Version:
       Source_public_key_path:
        Get_Source_public_key: 1
            Network_Namespace:
1 row in set (0.00 sec)

mysql> SHOW REPLICA STATUS \G
*************************** 1. row ***************************
             Replica_IO_State: Waiting for source to send event
                  Source_Host: 192.168.21.165
                  Source_User: repl
                  Source_Port: 3306
                Connect_Retry: 60
              Source_Log_File: binlog.000009
          Read_Source_Log_Pos: 876
               Relay_Log_File: relay-log-server.000002
                Relay_Log_Pos: 1086
        Relay_Source_Log_File: binlog.000009
           Replica_IO_Running: Yes
          Replica_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Source_Log_Pos: 876
              Relay_Log_Space: 1297
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Source_SSL_Allowed: No
           Source_SSL_CA_File:
           Source_SSL_CA_Path:
              Source_SSL_Cert:
            Source_SSL_Cipher:
               Source_SSL_Key:
        Seconds_Behind_Source: 0
Source_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Source_Server_Id: 1
                  Source_UUID: d84f56fa-12eb-11f1-936e-08002719c604
             Source_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
    Replica_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Source_Retry_Count: 86400
                  Source_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Source_SSL_Crl:
           Source_SSL_Crlpath:
           Retrieved_Gtid_Set: d84f56fa-12eb-11f1-936e-08002719c604:1-3
            Executed_Gtid_Set: d84f56fa-12eb-11f1-936e-08002719c604:1-3
                Auto_Position: 1
         Replicate_Rewrite_DB:
                 Channel_Name:
           Source_TLS_Version:
       Source_public_key_path:
        Get_Source_public_key: 1
            Network_Namespace:
1 row in set (0.00 sec)

mysql> USE OTUS;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
mysql> SHOW TABLES;
+----------------+
| Tables_in_OTUS |
+----------------+
| test_tbl       |
+----------------+
1 row in set (0.00 sec)

mysql> SELECT * FROM test_tbl;
+------+
| id   |
+------+
|    2 |
|    3 |
|    4 |
+------+
3 rows in set (0.00 sec)

mysql> EXIT;
```

```console
root@mysql-master:~# mysql

mysql> SHOW REPLICA STATUS \G
*************************** 1. row ***************************
             Replica_IO_State: Waiting for source to send event
                  Source_Host: 192.168.21.165
                  Source_User: repl
                  Source_Port: 3306
                Connect_Retry: 60
              Source_Log_File: binlog.000010
          Read_Source_Log_Pos: 66378636
               Relay_Log_File: relay-log-server.000004
                Relay_Log_Pos: 66378846
        Relay_Source_Log_File: binlog.000010
           Replica_IO_Running: Yes
          Replica_SQL_Running: Yes
              Replicate_Do_DB:
          Replicate_Ignore_DB:
           Replicate_Do_Table:
       Replicate_Ignore_Table:
      Replicate_Wild_Do_Table:
  Replicate_Wild_Ignore_Table:
                   Last_Errno: 0
                   Last_Error:
                 Skip_Counter: 0
          Exec_Source_Log_Pos: 66378636
              Relay_Log_Space: 66379141
              Until_Condition: None
               Until_Log_File:
                Until_Log_Pos: 0
           Source_SSL_Allowed: No
           Source_SSL_CA_File:
           Source_SSL_CA_Path:
              Source_SSL_Cert:
            Source_SSL_Cipher:
               Source_SSL_Key:
        Seconds_Behind_Source: 0
Source_SSL_Verify_Server_Cert: No
                Last_IO_Errno: 0
                Last_IO_Error:
               Last_SQL_Errno: 0
               Last_SQL_Error:
  Replicate_Ignore_Server_Ids:
             Source_Server_Id: 1
                  Source_UUID: d84f56fa-12eb-11f1-936e-08002719c604
             Source_Info_File: mysql.slave_master_info
                    SQL_Delay: 0
          SQL_Remaining_Delay: NULL
    Replica_SQL_Running_State: Replica has read all relay log; waiting for more updates
           Source_Retry_Count: 86400
                  Source_Bind:
      Last_IO_Error_Timestamp:
     Last_SQL_Error_Timestamp:
               Source_SSL_Crl:
           Source_SSL_Crlpath:
           Retrieved_Gtid_Set: d84f56fa-12eb-11f1-936e-08002719c604:1-184
            Executed_Gtid_Set: d84f56fa-12eb-11f1-936e-08002719c604:1-184
                Auto_Position: 1
         Replicate_Rewrite_DB:
                 Channel_Name:
           Source_TLS_Version:
       Source_public_key_path:
        Get_Source_public_key: 1
            Network_Namespace:
1 row in set (0.00 sec)

mysql> EXIT;
```

mysqldump  

https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html --> [--set-gtid-purged](https://dev.mysql.com/doc/refman/8.4/en/mysqldump.html#option_mysqldump_set-gtid-purged)
```console
root@mysql-slave:~# mysqldump OTUS > dump.sql
Warning: A partial dump from a server that has GTIDs will by default include the GTIDs of all transactions, even those that changed suppressed parts of the database. If you don't want to restore GTIDs, pass --set-gtid-purged=OFF. To make a complete dump, pass --all-databases --triggers --routines --events.
Warning: A dump from a server that has GTIDs enabled will by default include the GTIDs of all transactions, even those that were executed during its extraction and might not be represented in the dumped data. This might result in an inconsistent data dump.
In order to ensure a consistent backup of the database, pass --single-transaction or --lock-all-tables or --master-data.

root@mysql-slave:~# cat dump.sql
-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: OTUS
-- ------------------------------------------------------
-- Server version       8.0.45-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'd84f56fa-12eb-11f1-936e-08002719c604:1-184';

--
-- Table structure for table `test_tbl`
--

DROP TABLE IF EXISTS `test_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test_tbl` (
  `id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test_tbl`
--

LOCK TABLES `test_tbl` WRITE;
/*!40000 ALTER TABLE `test_tbl` DISABLE KEYS */;
INSERT INTO `test_tbl` VALUES (2),(3),(4);
/*!40000 ALTER TABLE `test_tbl` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-26 15:31:31

root@mysql-slave:~# mysqldump --set-gtid-purged=COMMENTED OTUS > dump2.sql
Warning: A partial dump from a server that has GTIDs will by default include the GTIDs of all transactions, even those that changed suppressed parts of the database. If you don't want to restore GTIDs, pass --set-gtid-purged=OFF. To make a complete dump, pass --all-databases --triggers --routines --events.
Warning: A dump from a server that has GTIDs enabled will by default include the GTIDs of all transactions, even those that were executed during its extraction and might not be represented in the dumped data. This might result in an inconsistent data dump.
In order to ensure a consistent backup of the database, pass --single-transaction or --lock-all-tables or --master-data.

root@mysql-slave:~# cat dump2.sql
-- MySQL dump 10.13  Distrib 8.0.45, for Linux (x86_64)
--
-- Host: localhost    Database: OTUS
-- ------------------------------------------------------
-- Server version       8.0.45-0ubuntu0.24.04.1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup
--

/* SET @@GLOBAL.GTID_PURGED='+d84f56fa-12eb-11f1-936e-08002719c604:1-184';*/

--
-- Table structure for table `test_tbl`
--

DROP TABLE IF EXISTS `test_tbl`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `test_tbl` (
  `id` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `test_tbl`
--

LOCK TABLES `test_tbl` WRITE;
/*!40000 ALTER TABLE `test_tbl` DISABLE KEYS */;
INSERT INTO `test_tbl` VALUES (2),(3),(4);
/*!40000 ALTER TABLE `test_tbl` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-26 15:31:48

## Смысл ключа --set-gtid-purged=COMMENTED заключется в следующем: если он закоментирован, slave будет создан от момента создания бэкапа (ранее это называлосб binlog позиция) до конца master (!! НУЖНО ПРОВЕРИТЬ)
```




**Практическое задание выполнено**.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
****
