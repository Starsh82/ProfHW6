# ProfHW6
Домашнее задание №6. Работа с NFS.
<b>Настраиваем сервер NFS</b>
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
<b>Настраиваем клиент NFS на второй виртуалке</b>
