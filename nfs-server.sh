#!/bin/bash
echo "Установка сервера NFS:"
apt install nfs-kernel-server -y
mkdir -p /srv/nfs/upload
chown -R nobody:nogroup /srv/nfs/
chmod 777 /srv/nfs/upload/
echo "/srv/nfs/ *(rw,sync,no_subtree_check,root_squash)" >> /etc/exports
exportfs -r
var=$(exportfs -s)
if [[ -z $var ]]; then
  echo "Экспорты NFS не найдены!"
else
  echo "$var"
  echo "Настройка сервера NFS окончена!"
fi
