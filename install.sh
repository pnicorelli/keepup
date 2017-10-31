#/bin/bash

if [ "$EUID" -ne 0 ]
then
  echo "ERR: Please run as root"
  exit 1
fi

if [ -e "/etc/keepup.cfg" ]
then
  echo "ERR: Looks a /etc/keepup.cfg already exist, I'm too stupid to go ahead"
  exit 1
fi

if [ -e "/usr/share/keepup/database.db" ]
then
  echo "ERR: Looks a /etc/keepup.cfg already exist, I'm too stupid to go ahead"
  exit 1
fi

grep -q "keepup" /etc/passwd
if [ $? -eq 0 ]
then
  echo "User keepup already exist."
  exit 1
fi

useradd -U -b '/usr/share' keepup

mkdir /usr/share/keepup
cp * /usr/share/keepup
cp /usr/share/keepup/empty_database.db /usr/share/keepup/database.db

chown -R keepup:keepup /usr/share/keepup

ln -s /usr/share/keepup/empty_keepup.cfg /etc/keepup.cfg
ln -s /usr/share/keepup/keepup.sh /usr/local/bin/keepup
chmod 775 ./keepup.sh

touch /var/log/keepup.log
chown keepup /var/log/keepup.log
chmod 644 /var/log/keepup.log

echo "keepup   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/keepup
chmod 400 /etc/sudoers.d/keepup

apt install curl sqlite3
