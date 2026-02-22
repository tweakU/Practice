## «Настройка LDAP сервера»

[ЧТИВО:](https://www.freeipa.org/page/Demo)

**Цель задания: **.

**Выполнение задания**:

1) :

```console

```


**Задание выполнено**.

<br/>

[Вернуться к списку заданий](../README.md)
****











Настройка LDAP сервера

```console
# SETUP LDAP SERVER (slapd)

root@vm-ubuntu24:~# apt-get install slapd -y

root@vm-ubuntu24:~# dpkg-reconfigure slapd (No, homesrv01.org, homesrv01, Yes, No)

root@vm-ubuntu24:~# ls -l /var/lib/ldap/
total 60
-rw------- 1 openldap openldap 57344 Feb 22 09:52 data.mdb
-rw------- 1 openldap openldap  8192 Feb 22 09:52 lock.mdb

root@vm-ubuntu24:~# apt-get install apache2 phpldapadmin -y

root@vm-ubuntu24:~# ls -l /etc/apache2/conf-enabled/
total 0
lrwxrwxrwx 1 root root 30 Feb 22 09:53 charset.conf -> ../conf-available/charset.conf
lrwxrwxrwx 1 root root 44 Feb 22 09:53 localized-error-pages.conf -> ../conf-available/localized-error-pages.conf
lrwxrwxrwx 1 root root 46 Feb 22 09:53 other-vhosts-access-log.conf -> ../conf-available/other-vhosts-access-log.conf
lrwxrwxrwx 1 root root 35 Feb 22 09:57 phpldapadmin.conf -> ../conf-available/phpldapadmin.conf
lrwxrwxrwx 1 root root 31 Feb 22 09:53 security.conf -> ../conf-available/security.conf
lrwxrwxrwx 1 root root 36 Feb 22 09:53 serve-cgi-bin.conf -> ../conf-available/serve-cgi-bin.conf

root@vm-ubuntu24:~# nano /etc/apache2/conf-enabled/phpldapadmin.conf # allow all?

root@vm-ubuntu24:~# curl 127.0.0.1/phpldapadmin
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>301 Moved Permanently</title>
</head><body>
<h1>Moved Permanently</h1>
<p>The document has moved <a href="http://127.0.0.1/phpldapadmin/">here</a>.</p>
<hr>
<address>Apache/2.4.58 (Ubuntu) Server at 127.0.0.1 Port 80</address>
</body></html>

root@vm-ubuntu24:~# curl -L 127.0.0.1/phpldapadmin

root@vm-ubuntu24:~# ls -l /usr/share/phpldapadmin/config/

root@vm-ubuntu24:~# 	 # listening port ??

# Web browser
http://192.168.21.181/phpldapadmin/

ДОБАВИТЬ СКРИНЫ С ДЕЙСТВИЯМИ В БРАУЗЕРЕ

root@vm-ubuntu24:~# ldapsearch -H ldap://192.168.21.178 -D cn=admin,dc=homesrv01,dc=ru -w admin -b dc=homesrv01,dc=ru
# extended LDIF
#
# LDAPv3
# base <dc=homesrv01,dc=ru> with scope subtree
# filter: (objectclass=*)
# requesting: ALL
#

# homesrv01.ru
dn: dc=homesrv01,dc=ru
objectClass: top
objectClass: dcObject
objectClass: organization
o: homesrv01
dc: homesrv01

# ldap_user, homesrv01.ru
dn: cn=ldap_user,dc=homesrv01,dc=ru
cn: ldap_user
objectClass: posixGroup
objectClass: top
gidNumber: 5000

# test test, ldap_user, homesrv01.ru
dn: cn=test test,cn=ldap_user,dc=homesrv01,dc=ru
givenName: test
sn: test
cn: test test
uid: test
userPassword:: e01ENX1DWTlyelVZaDAzUEszazZESmllMDlnPT0=
gidNumber: 5000
homeDirectory: /home/test
loginShell: /bin/bash
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
uidNumber: 10000

# search result
search: 2
result: 0 Success

# numResponses: 4
# numEntries: 3


# CLIENT SIDE
root@vm-ubuntu24-ldap-client:~# apt-get install libnss-ldap libpam-ldap nscd -y
# здесь очень важные настройки (ldap://ip, domain name, ver. 3, ???)
root@vm-ubuntu24-ldap-client:~# getent passwd test

# далее необходимо добавить ldap
root@vm-ubuntu24-ldap-client:~# cat /etc/nsswitch.conf
# /etc/nsswitch.conf
#
# Example configuration of GNU Name Service Switch functionality.
# If you have the `glibc-doc-reference' and `info' packages installed, try:
# `info libc "Name Service Switch"' for information about this file.

passwd:         files systemd ldap
group:          files systemd ldap
shadow:         files systemd ldap
gshadow:        files systemd

hosts:          files dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis ldap

# нужно обновить pamd ## Create home directory on login
root@vm-ubuntu24-ldap-client:~# pam-auth-update

!! root@vm-ubuntu24-ldap-client:~# grep -r 'home' /etc/pam.d/
!! /etc/pam.d/common-session:session       optional                        pam_mkhomedir.so


```
