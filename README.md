# KeepUp

### The problem

I'm currently playing with some raspberry. Many of them will be placed somewhere and network connected.
Those devices have many apps that are in a continous developing. Sometimes I need to make some changes in those machines.

How can I keep up them?

### The solution

A script launched in a cronjob who read a remote CSV table with incremental changes.
Each row is a pointer to a remote script, the service download and run the script.

The status is saved in a sqlite3 db.

A single machine is consider update from the `keepup` install date.

### How It work

Install on the device
```bash
git clone https://github.com/pnicorelli/keepup.git
cd keepup
sudo bash install.sh
```

this will create a new user `keepup` with full SUDO access (like the `pi` user)

Then publish a CSV on **REMOTE_LEDGER** url with format:

```
TIMESTAMP,REFNAME,REFVERSION,SCRIPT_URL,SHA256,NOTES
```

where each field is:

  - TIMESTAMP : epoch of the script generation
  - REFNAME   : a name for reference
  - REFVERSION: a reference for versioning
  - HTTP_URL  : where you serve the script
  - SHA256    : checksum, return value of `sha256sum yourscript.sh`
  - NOTES     : bla bla bla if needed

( -g SCRIPT_URL option output the row to be added on **REMOTE_LEDGER** file)

Then update **REMOTE_LEDGER** in `/etc/keepup.cfg`

Last but not least, add a cronjob who execute the keepup.

```
# /etc/crontab: system-wide crontab
# example to run keepup every hour

0 * 	* * *	keepup	/usr/local/bin/keepup
```



### EXAMPLE

- REMOTE_LEDGER.csv

```
1509193800,"UX","0.0.1","https://gitlab.com/p.nicorelli/test/raw/master/release.sh",245edcde7db69a17a2f24fa68da93605146ec2666fd2d453c87359df116ba200,"Initial Release"
1509194011,"UX","0.0.2","https://gitlab.com/p.nicorelli/test/raw/master/release_2.sh",93023c4904b5a00f14e34ce499e363c335753c0187db75bdee7c336e541025f3,"Add file"
1509210296,"WatchDog","1.0","https://gitlab.com/p.nicorelli/test/raw/master/xex_1.sh",ef9093dcf5dedb39174fc24863420f2343cc5bda0485e25d4d9b2219abf5c301,"New Software install"
```
