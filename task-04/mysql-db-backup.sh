#!/bin/bash

# MySQL backup script (логические бэкапы mysqldump)

MYSQL='mysql --skip-column-names'

for s in mysql $MYSQL -e "SHOW DATABASES LIKE '%\_db'";
    do
    mkdir $s;
    /usr/bin/mysqldump --add-drop-table --add-locks --create-options --disable-keys --extended-insert --single-transaction --quick --set-charset --events --routines --triggers $s | gzip -1 > $s/$s.gz;
    done
