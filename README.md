# KeepUp

### The problem

I'm currently playing with some raspberry. Many of them will be placed somewhere and network connected.
Those devices have many apps that are in a continous developing. May be I need sometimes to make some change in the system.

How can I keep up them?

### The solution

A CSV table with incremental changes. Each row is a remote script to be executed on the machine.

This program is intended to run inside a cron job. The `install.sh` script install all the files needed,
add a user `keepup` to the system and give to him the evil `sudo` capabilities.

### How It work

It fetch the CSV table (url defined in configuration)
An internal table on sqlite keep track the status.
Every new row is executed.
A row contain

  ```
   - timestamp
   - app name
   - app version
   - url of the script to be downloaded and executed
   - sha256 of the script file
   - notes displayed on execution
  ```
I'm supposing the `timestamp` is the unique id of the changes so `timestamp` need to be sorted descending (last row is the last update)

Really simple. May be is not the right way (feedback appreciate).

### DB TABLE

```
CREATE TABLE changelog (
      timestamp TIMESTAMP NOT NULL PRIMARY KEY,
      app VARCHAR(64),
      version VARCHAR(12),
      script_url text,
      checksum VARCHAR(64),
      notes text
    );
```

### CSV EXAMPLE

```
1509193800,"UX","0.0.1","https://gitlab.com/p.nicorelli/test/raw/master/release.sh",245edcde7db69a17a2f24fa68da93605146ec2666fd2d453c87359df116ba200,"Initial Release"
1509194011,"UX","0.0.2","https://gitlab.com/p.nicorelli/test/raw/master/release_2.sh",93023c4904b5a00f14e34ce499e363c335753c0187db75bdee7c336e541025f3,"Add file"
1509210296,"WatchDog","1.0","https://gitlab.com/p.nicorelli/test/raw/master/xex_1.sh",ef9093dcf5dedb39174fc24863420f2343cc5bda0485e25d4d9b2219abf5c301,"New Software install"
```
