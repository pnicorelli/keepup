#!/bin/bash
REMOTE_LEDGER="https://domain.ext/data.csv"
LOCAL_DB="/usr/share/keepup/database.db"
LOGFILE="/var/log/keepup.log"

# OVERWRITE DEFAULT CONF
source /etc/keepup.cfg

DRYRUN=0

print_log() {
  echo "[K] "$1 >> $LOGFILE
}

show_help() {
  cat << EOF
Usage: ${0} [OPTION]
Keep up with what's happening in a ecosistem.
  -h                print this help
  -d                dry run, get updates but do not run them
  -l                list changes (first row is last change)
EOF
}

listChanges() {
  sqlite3 -csv $LOCAL_DB "SELECT timestamp, app, version, notes FROM changelog ORDER BY timestamp DESC;" | while IFS=, read ts app version notes;
  do
    DBTS=$(date -d @$ts +"%Y-%m-%d at %H:%M" )
    echo "[$DBTS] ---------"
    echo " > Runned $app to $version"
    echo $notes
    echo "-------------------------------"
  done
}

downloadToWorkplace() {
  curl -sL $1 > $WORKPLACE/$2
  if [ ! -e $WORKPLACE/$2 ]
  then
    echo "ERROR on download $1"
    print_log "ERROR on download $1"
    exit 1
  fi
  if [ -n "$3" ]
  then
    CS=$(sha256sum $WORKPLACE/$2 | cut -f 1 -d " ")
    if [ $3 != $CS ]
    then
      echo "ERROR on $1 checksum [$2]"
      print_log "ERROR on $1 checksum [$2]"
      exit 1
    fi
  fi
}

runSync() {
  lastUpdate
  while IFS=, read ts app version script checksum notes
  do
    if [ $ts -gt $LASTUPDATE ]
    then
      echo "[$ts] - $app v$version"
      DEST=$$
      script=$( echo $script | tr -d '"')
      downloadToWorkplace $script $DEST $checksum
      print_log "$(date +%Y%m%d%H%M%S) new script" >> $LOGFILE
      print_log "update $app to $version" >> $LOGFILE
      if [ $DRYRUN -eq 1 ]
      then
        print_log "this is a DRYRUN"
      else
        /bin/bash $WORKPLACE/$DEST >> $LOGFILE
      fi
      if [ $? -ne 0 ]
      then
        echo "update execution fail"
        print_log "update execution fail"
        exit 1
      fi
      app=$( echo $app | tr -d '"')
      version=$( echo $version | tr -d '"')
      notes=$( echo $notes | tr -d '"')
      sqlite3 $LOCAL_DB "INSERT INTO changelog (timestamp, app, version, script_url, checksum, notes) VALUES ($ts, '$app', '$version', '$script', '$checksum', '$notes');"
      if [ $? -ne 0 ]
      then
        echo "update db fail"
        print_log "update db fail"
        exit 1
      fi
      print_log "update complete" >> $LOGFILE
    fi

  done < $WORKPLACE/ledger.csv
}

lastUpdate() {
  LASTUPDATE=$(sqlite3 $LOCAL_DB "SELECT MAX(timestamp) FROM changelog")
  if [ $? -ne 0 ]
  then
    echo "unable to open db"
    print_log "unable to open db"
    exit 1
  fi
  if [ ! -n "$LASTUPDATE" ]
  then
    LASTUPDATE=$STARTDATE
  fi
}

while getopts hdl opt; do
  case $opt in
    h)
      show_help
      exit 0
      ;;
    d)
      DRYRUN=1
      ;;
    l)
      listChanges
      exit 0
      ;;
  esac
done

WORKPLACE=$(mktemp -d)
trap "rm -rf $WORKPLACE" EXIT

downloadToWorkplace $REMOTE_LEDGER "ledger.csv"
runSync

# cat $WORKPLACE/ledger.csv
