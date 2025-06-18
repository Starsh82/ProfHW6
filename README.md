# ProfHW6
Домашнее задание №6. Работа с NFS.  

<b>Настраиваем сервер NFS</b>

---
Устанавливаем NFS сервер
```
root@UbuntuTestVirt:/srv# apt install nfs-kernel-server
Чтение списков пакетов… Готово
Построение дерева зависимостей… Готово
Чтение информации о состоянии… Готово
Уже установлен пакет nfs-kernel-server самой новой версии (1:2.6.4-3ubuntu5.1).
Обновлено 0 пакетов, установлено 0 новых пакетов, для удаления отмечено 0 пакетов, и 1 пакетов не обновлено.
```
---
Проверяем порты 2049 и 111
```
root@UbuntuTestVirt:/srv# ss -tulpn | grep "2049\|111"
udp   UNCONN 0      0      10.0.2.15%enp0s3:68         0.0.0.0:*    users:(("systemd-network",pid=1118,fd=24))
udp   UNCONN 0      0               0.0.0.0:111        0.0.0.0:*    users:(("rpcbind",pid=1139,fd=5),("systemd",pid=1,fd=222))
udp   UNCONN 0      0                  [::]:111           [::]:*    users:(("rpcbind",pid=1139,fd=7),("systemd",pid=1,fd=224))
tcp   LISTEN 0      64              0.0.0.0:2049       0.0.0.0:*
tcp   LISTEN 0      4096            0.0.0.0:111        0.0.0.0:*    users:(("rpcbind",pid=1139,fd=4),("systemd",pid=1,fd=221))
tcp   LISTEN 0      64                 [::]:2049          [::]:*
tcp   LISTEN 0      4096               [::]:111           [::]:*    users:(("rpcbind",pid=1139,fd=6),("systemd",pid=1,fd=223))
```
---
Создаём шару для экспорта. Меняем владельца и группу для директории /srv/nfs и её содержимого. Устанавливаем полные права для всех на директорию /srv/nfs/upload
```
root@UbuntuTestVirt:/srv# mkdir -p ./nfs/upload
root@UbuntuTestVirt:/srv# chown -R nobody:nogroup /srv/nfs/
root@UbuntuTestVirt:/srv# chmod 777 ./nfs/upload/
root@UbuntuTestVirt:/srv# ll
total 12
drwxr-xr-x  3 root   root    4096 июн 16 00:57 ./
drwxr-xr-x 26 root   root    4096 июн  2 21:50 ../
drwxr-xr-x  3 nobody nogroup 4096 июн 16 00:57 nfs/
root@UbuntuTestVirt:/srv# ll ./nfs/
total 12
drwxr-xr-x 3 nobody nogroup 4096 июн 16 00:57 ./
drwxr-xr-x 3 root   root    4096 июн 16 00:57 ../
drwxrwxrwx 2 nobody nogroup 4096 июн 16 00:57 upload/
```
---
Вносим изменения в файл /etc/exports
```
# /etc/exports: the access control list for filesystems which may be exported
#               to NFS clients.  See exports(5).
#
# Example for NFSv2 and NFSv3:
# /srv/homes       hostname1(rw,sync,no_subtree_check) hostname2(ro,sync,no_subtree_check)
#
# Example for NFSv4:
# /srv/nfs4        gss/krb5i(rw,sync,fsid=0,crossmnt,no_subtree_check)
# /srv/nfs4/homes  gss/krb5i(rw,sync,no_subtree_check)
#
/srv/nfs/ *(rw,sync,no_subtree_check,root_squash)
```
---
Экспортируем директорию /srv/nfs
```
root@UbuntuTestVirt:/srv# exportfs -r
root@UbuntuTestVirt:/srv# exportfs -s
/srv/nfs  *(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
```
---
Информация для монтирования директории по NFS:
```
root@UbuntuTestVirt:/srv# ip -4 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: enp0s3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 10.0.2.15/24 metric 100 brd 10.0.2.255 scope global dynamic enp0s3
       valid_lft 70618sec preferred_lft 70618sec
3: enp0s8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 192.168.0.160/24 brd 192.168.0.255 scope global enp0s8
       valid_lft forever preferred_lft forever
```
---
<b>Настраиваем клиент NFS на второй виртуалке</b>  
Устанавливаем NFS клиент на второй виртуалке
```
starsh@ubu22serv:~$ sudo apt install nfs-common
[sudo] password for starsh:
Чтение списков пакетов… Готово
Построение дерева зависимостей… Готово
Чтение информации о состоянии… Готово
Уже установлен пакет nfs-common самой новой версии (1:2.6.4-3ubuntu5.1).
Обновлено 0 пакетов, установлено 0 новых пакетов, для удаления отмечено 0 пакетов, и 1 пакетов не обновлено.
```
---
Добавляем в fstab строку лоя автоматического монтирования директории по NFS
```
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
# / was on /dev/ubuntu-vg/ubuntu-lv during curtin installation
/dev/disk/by-id/dm-uuid-LVM-bvDXb4KjeT1mT2Idyi9XiSJ3uU5ooVPMQN9aOcWxvleopRQmfk0XehqQv61Ro7zb / >
# /boot was on /dev/sda2 during curtin installation
/dev/disk/by-uuid/40ee35c7-71ee-4b50-95df-5f9931acd212 /boot ext4 defaults 0 1
/swap.img       none    swap    sw      0       0
192.168.0.160:/srv/nfs/ /mnt nfs vers=3,noauto,x-systemd.automount 0 0
```
---
Перезагружаем конфигурацию юнитов systemd (необходимо в случае приминения опций x-systemd.* в fstab) и перегружаем сервисы, связанные с монтированием удалённых фс
```
starsh@ubu22serv:~$ sudo systemctl daemon-reload
starsh@ubu22serv:~$ sudo systemctl restart remote-fs.target
```
---
Проверяем монтирование удалённой директории
```
starsh@ubu22serv:~$ cd /mnt/
starsh@ubu22serv:/mnt$ mount | grep /mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=91,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=13215)
192.168.0.160:/srv/nfs/ on /mnt type nfs (rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.0.160,mountvers=3,mountport=52593,mountproto=udp,local_lock=none,addr=192.168.0.160)
```
---
<b>Проверка работоспособности клиент-серверного соединения по NFS</b>
- Заходим на сервер. 
- Заходим в каталог /srv/share/upload.  
- Создаём тестовый файл touch check_file.  
- Заходим на клиент.  
- Заходим в каталог /mnt/upload.  
- Проверяем наличие ранее созданного файла.  
- Создаём тестовый файл touch client_file.  
- Проверяем, что файл успешно создан.  
На сервере:
```
root@UbuntuTestVirt:/srv# cd /srv/nfs/upload/
root@UbuntuTestVirt:/srv/nfs/upload# touch check_file
root@UbuntuTestVirt:/srv/nfs/upload# ll
total 8
drwxrwxrwx 2 nobody nogroup 4096 июн 16 02:20 ./
drwxr-xr-x 3 nobody nogroup 4096 июн 16 00:57 ../
-rw-r--r-- 1 root   root       0 июн 16 02:20 check_file
```
На клиенте
```
starsh@ubu22serv:/mnt$ cd /mnt/upload/
starsh@ubu22serv:/mnt/upload$ ll
total 8
drwxrwxrwx 2 nobody nogroup 4096 июн 16 02:20 ./
drwxr-xr-x 3 nobody nogroup 4096 июн 16 00:57 ../
-rw-r--r-- 1 root   root       0 июн 16 02:20 check_file
starsh@ubu22serv:/mnt/upload$ touch client_file
starsh@ubu22serv:/mnt/upload$ ll
total 8
drwxrwxrwx 2 nobody nogroup 4096 июн 16 02:21 ./
drwxr-xr-x 3 nobody nogroup 4096 июн 16 00:57 ../
-rw-r--r-- 1 root   root       0 июн 16 02:20 check_file
-rw-rw-r-- 1 starsh starsh     0 июн 16 02:21 client_file
```
---
<b>Проверяем клиент касательно монтирования при запуске системы:  
перезагружаем клиент;  
заходим на клиент;  
заходим в каталог /mnt/upload;  
проверяем наличие ранее созданных файлов.</b>  
```
starsh@ubu22serv:/mnt/upload$ sudo reboot

Broadcast message from root@ubu22serv on pts/1 (Mon 2025-06-16 02:25:46 +04):

The system will reboot now!

starsh@ubu22serv:/mnt/upload$

[SSH] INFO: DISCONNECT
```
```
Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-60-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Вс 15 июн 2025 21:40:59 +04

  System load:             0.0
  Usage of /:              53.6% of 9.75GB
  Memory usage:            19%
  Swap usage:              0%
  Processes:               101
  Users logged in:         0
  IPv4 address for enp0s3: 10.0.2.15
  IPv6 address for enp0s3: fd00::a00:27ff:fe8e:5cb8


Расширенное поддержание безопасности (ESM) для Applications выключено.

0 обновлений может быть применено немедленно.

Включите ESM Apps для получения дополнительных будущих обновлений безопасности.
Смотрите https://ubuntu.com/esm или выполните: sudo pro status


Last login: Sun Jun 15 21:41:02 2025 from 10.0.2.2
starsh@ubu22serv:~$ cd /mnt/
starsh@ubu22serv:/mnt$ ll
total 12
drwxr-xr-x  3 nobody nogroup 4096 июн 16 00:57 ./
drwxr-xr-x 23 root   root    4096 ноя  3  2024 ../
drwxrwxrwx  2 nobody nogroup 4096 июн 16 02:21 upload/
starsh@ubu22serv:/mnt$ ll ./upload/
total 8
drwxrwxrwx 2 nobody nogroup 4096 июн 16 02:21 ./
drwxr-xr-x 3 nobody nogroup 4096 июн 16 00:57 ../
-rw-r--r-- 1 root   root       0 июн 16 02:20 check_file
-rw-rw-r-- 1 starsh starsh     0 июн 16 02:21 client_file
starsh@ubu22serv:/mnt$
```
---
<b>Проверяем сервер  
- заходим на сервер в отдельном окне терминала;  
- перезагружаем сервер;  
- заходим на сервер;  
- проверяем наличие файлов в каталоге /srv/share/upload/;  
- проверяем экспорты exportfs -s;  
- проверяем работу RPC showmount -a 192.168.1.160</b>
```
root@UbuntuTestVirt:~# reboot

Broadcast message from root@UbuntuTestVirt on pts/1 (Mon 2025-06-16 02:31:24 +04):

The system will reboot now!

root@UbuntuTestVirt:~#

[SSH] INFO: DISCONNECT
```
```
[SSH] Server Version OpenSSH_9.6p1 Ubuntu-3ubuntu13.12
[SSH] Encryption used: chacha20-poly1305@openssh.com
[SSH] Logged in (password)

Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-60-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Вс 15 июн 2025 19:40:50 +04

  System load:             0.25
  Usage of /:              72.7% of 9.75GB
  Memory usage:            24%
  Swap usage:              0%
  Processes:               263
  Users logged in:         1
  IPv4 address for enp0s3: 10.0.2.15
  IPv6 address for enp0s3: fd00::a00:27ff:fe53:13dd

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Расширенное поддержание безопасности (ESM) для Applications выключено.

0 обновлений может быть применено немедленно.

Включите ESM Apps для получения дополнительных будущих обновлений безопасности.
Смотрите https://ubuntu.com/esm или выполните: sudo pro status


Last login: Sun Jun 15 21:26:12 2025 from 10.0.2.2
starsh@UbuntuTestVirt:~$ sudo -i
[sudo] password for starsh:
```
```
root@UbuntuTestVirt:~# ll /srv/nfs/upload/
total 8
drwxrwxrwx 2 nobody nogroup 4096 июн 16 02:21 ./
drwxr-xr-x 3 nobody nogroup 4096 июн 16 00:57 ../
-rw-r--r-- 1 root   root       0 июн 16 02:20 check_file
-rw-rw-r-- 1 starsh starsh     0 июн 16 02:21 client_file
root@UbuntuTestVirt:~# exportfs -s
/srv/nfs  *(sync,wdelay,hide,no_subtree_check,sec=sys,rw,secure,root_squash,no_all_squash)
root@UbuntuTestVirt:~# showmount -a 192.168.0.160
All mount points on 192.168.0.160:
192.168.0.120:/srv/nfs
```
---
<b>Проверяем клиент:  
- возвращаемся на клиент;
- перезагружаем клиент;
- заходим на клиент;
- проверяем работу RPC showmount -a 192.168.50.10;
- заходим в каталог /mnt/upload;
- проверяем статус монтирования mount | grep mnt;
- проверяем наличие ранее созданных файлов;
- создаём тестовый файл touch final_check;
- проверяем, что файл успешно создан.</b>  
```
starsh@ubu22serv:~$ sudo reboot

Broadcast message from root@ubu22serv on pts/2 (Wed 2025-06-18 23:49:54 +04):

The system will reboot now!

starsh@ubu22serv:~$

[SSH] INFO: DISCONNECT


[SSH] Server Version OpenSSH_9.6p1 Ubuntu-3ubuntu13.12
[SSH] Encryption used: chacha20-poly1305@openssh.com
[SSH] Logged in (password)

Welcome to Ubuntu 24.04.2 LTS (GNU/Linux 6.8.0-60-generic x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

 System information as of Ср 18 июн 2025 23:36:36 +04

  System load:             0.1
  Usage of /:              53.9% of 9.75GB
  Memory usage:            23%
  Swap usage:              0%
  Processes:               109
  Users logged in:         1
  IPv4 address for enp0s3: 10.0.2.15
  IPv6 address for enp0s3: fd00::a00:27ff:fe8e:5cb8

 * Strictly confined Kubernetes makes edge and IoT secure. Learn how MicroK8s
   just raised the bar for easy, resilient and secure K8s cluster deployment.

   https://ubuntu.com/engage/secure-kubernetes-at-the-edge

Расширенное поддержание безопасности (ESM) для Applications выключено.

0 обновлений может быть применено немедленно.

Включите ESM Apps для получения дополнительных будущих обновлений безопасности.
Смотрите https://ubuntu.com/esm или выполните: sudo pro status


Last login: Wed Jun 18 23:36:38 2025 from 10.0.2.2
```
```
starsh@ubu22serv:~$ showmount -a 192.168.0.160
All mount points on 192.168.0.160:
192.168.0.120:/srv/nfs
starsh@ubu22serv:~$ cd /mnt/upload/
starsh@ubu22serv:/mnt/upload$ mount | grep mnt
systemd-1 on /mnt type autofs (rw,relatime,fd=65,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=4034)
192.168.0.160:/srv/nfs/ on /mnt type nfs (rw,relatime,vers=3,rsize=262144,wsize=262144,namlen=255,hard,proto=tcp,timeo=600,retrans=2,sec=sys,mountaddr=192.168.0.160,mountvers=3,mountport=36039,mountproto=udp,local_lock=none,addr=192.168.0.160)
starsh@ubu22serv:/mnt/upload$ ll
total 8
drwxrwxrwx 2 nobody nogroup 4096 июн 18 23:55 ./
drwxr-xr-x 3 nobody nogroup 4096 июн 18 23:08 ../
-rw-rw-r-- 1 starsh starsh     0 июн 18 23:11 client_file
-rw-r--r-- 1 root   root       0 июн 18 23:10 server_file
starsh@ubu22serv:/mnt/upload$ touch final_check
starsh@ubu22serv:/mnt/upload$ ll
total 8
drwxrwxrwx 2 nobody nogroup 4096 июн 18 23:56 ./
drwxr-xr-x 3 nobody nogroup 4096 июн 18 23:08 ../
-rw-rw-r-- 1 starsh starsh     0 июн 18 23:11 client_file
-rw-rw-r-- 1 starsh starsh     0 июн 18 23:56 final_check
-rw-r--r-- 1 root   root       0 июн 18 23:10 server_file
```
