## «Настройка LDAP сервера»

[ЧТИВО:](https://www.freeipa.org/page/Demo)

**Цель задания: **.

**Выполнение задания**:

1) Setup LDAP Server (slapd):

```console
root@vm-ldap-srv:~# apt-get install slapd -y ## pwd

root@vm-ldap-srv:~# dpkg-reconfigure slapd ## No, homesrv01.org, homesrv01, pwd, Yes, No

root@vm-ldap-srv:~# ls -l /var/lib/ldap/
total 60
-rw------- 1 openldap openldap 57344 Feb 22 09:52 data.mdb
-rw------- 1 openldap openldap  8192 Feb 22 09:52 lock.mdb

root@vm-ldap-srv:~# apt-get install apache2 phpldapadmin -y

root@vm-ldap-srv:~# ls -l /etc/apache2/conf-enabled/
total 0
lrwxrwxrwx 1 root root 30 Feb 22 09:53 charset.conf -> ../conf-available/charset.conf
lrwxrwxrwx 1 root root 44 Feb 22 09:53 localized-error-pages.conf -> ../conf-available/localized-error-pages.conf
lrwxrwxrwx 1 root root 46 Feb 22 09:53 other-vhosts-access-log.conf -> ../conf-available/other-vhosts-access-log.conf
lrwxrwxrwx 1 root root 35 Feb 22 09:57 phpldapadmin.conf -> ../conf-available/phpldapadmin.conf
lrwxrwxrwx 1 root root 31 Feb 22 09:53 security.conf -> ../conf-available/security.conf
lrwxrwxrwx 1 root root 36 Feb 22 09:53 serve-cgi-bin.conf -> ../conf-available/serve-cgi-bin.conf

root@vm-ldap-srv:~# nano /etc/apache2/conf-enabled/phpldapadmin.conf ## ?? Allow from all

root@vm-ldap-srv:~# curl 127.0.0.1/phpldapadmin
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>301 Moved Permanently</title>
</head><body>
<h1>Moved Permanently</h1>
<p>The document has moved <a href="http://127.0.0.1/phpldapadmin/">here</a>.</p>
<hr>
<address>Apache/2.4.58 (Ubuntu) Server at 127.0.0.1 Port 80</address>
</body></html>

root@vm-ldap-srv:~# curl -L 127.0.0.1/phpldapadmin

root@vm-ldap-srv:~# ls -l /usr/share/phpldapadmin/config/
root@vm-ldap-srv:~# ls -l /usr/share/phpldapadmin/config/config.php ## replace "cn=admin,dc=example,dc=com" to "cn=admin,dc=homesrv01,dc=ru" twice

## Web browser
http://IP-адрес/phpldapadmin/

1 Create a child entry --> Generic: Posix Group --> Group "ldap_user" --> Create Object --> Commit --> gidNumber 5000 (+0) --> Update Object
2 Create a child entry --> Generic: User Account --> Last name --> Common Name --> User ID --> Password --> GID Number --> Home directory (/home/%username%) --> Login shell --> Create Object --> Commit --> uidNumber 10000 (+0) --> Update Object

root@vm-ldap-srv:~# ldapsearch -H ldap://192.168.1.172 -D cn=admin,dc=homesrv01,dc=ru -w admin -b dc=homesrv01,dc=ru
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

# proxyuser, homesrv01.ru
dn: cn=proxyuser,dc=homesrv01,dc=ru
sn: proxyuser
cn:: IHByb3h5dXNlcg==
uid: proxyuser
userPassword:: e01ENX1JQ3k1WXF4WkIxdVdTd2NWTFNOTGNBPT0=
gidNumber: 5000
homeDirectory: /home/proxyuser
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
```


2) Setup LDAP Client:

```console
root@vm-ldap-client:~# apt-get install libnss-ldap libpam-ldap nscd -y ## ldap://IP-адрес LDAP сервера, dc=homesrv01,dc=ru, LDAP ver. 3, No, Yes, cn=proxyuser,dc=homesv01,dc=ru, %proxyuser pwd

root@vm-ldap-client:~# nano /etc/nsswitch.conf ## ldap

root@vm-ldap-client:~# cat /etc/nsswitch.conf
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

root@vm-ldap-client:~# getent passwd proxyuser

root@vm-ldap-client:~# pam-auth-update ## Create home directory on login

root@vm-ldap-client:~# grep -r 'home' /etc/pam.d/
/etc/pam.d/common-session:session       optional                        pam_mkhomedir.so
```


**Задание выполнено**.

<br/>

[Вернуться к списку задач](../README.md)
****
