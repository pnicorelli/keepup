#/bin/bash

if [ "$EUID" -ne 0 ]
then
  echo "ERR: Please run as root"
  exit 1
fi

userdel keepup
rm /etc/sudoers.d/keepup
rm /etc/keepup.cfg
rm /usr/local/bin/keepup
rm -rf /usr/share/keepup
rm /var/log/keepup.log
