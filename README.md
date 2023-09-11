# ipfs_china_paper_code
Code for the Paper "TODO"

## Prerequisites

You'll need:
- R, with `renv` for dependency management, but that should be installed automatically when you open an R session in the `plotting/` directory.
- [Miller](https://github.com/johnkerl/miller/), to deal with CSV files on the command line.
    This is probably available in your distribution's repositories
- Docker, to build and run the various pieces of software
- [Our crawler](https://github.com/trudi-group/ipfs-crawler), which we use to crawl the network
- A recent release of [kubo](https://github.com/ipfs/kubo)
- A bunch of (currently three) servers to measure between
- Python 3 for various data wrangling
- [jq](https://jqlang.github.io/jq/) to deal with JSON on the command line.
    This is probably available in your distribution's repositories.

## Machines

We use these machines, with an alias configured in `~/.ssh/config` for easier scripting:

```
server_1: DE, server, non-NATed, crawls, ics-de-server
server_2: CN, client, NATed, no crawls, ics-cn-client
server_3: US, client, NATed, no crawls, ics-us-client
server_4: US, server, non-NATed, crawls, ics-us-server
server_5: CN, server, non-NATed, crawls, ics-cn-server
```

## Docker

Run a NATed daemon like so:
```
docker run --name ipfs_host -v $ipfs_staging:/export -v $ipfs_data:/data/ipfs -v ./001-configure-ipfs.sh:/container-init.d/001_configure_ipfs.sh -p 127.0.0.1:8080:8080 -p 127.0.0.1:5001:5001 ipfs/kubo:v0.22.0
```

with `001-configure-ipfs.sh` being:
```sh
#!/bin/sh
set -ex

ipfs config apply server
```

The cron scripts will need to be run as the correct user, with the above variables exported.
This can be achieved by having the variables auto-set in `.bashrc` and runnin cron jobs with `bash -lc <command>`.
The scripts will detect whether a dockerized setup is being used based on whether the variables are set.
You'll also need passwordless sudo to fix permissions on the downloaded files, otherwise they belong to root and are not readable by the user running the scripts.

## Cron

Set up cron to run on UTC by modifying `/lib/systemd/system/cron.service`:
```
[Unit]
Description=Regular background program processing daemon
Documentation=man:cron(8)
After=remote-fs.target nss-user-lookup.target

[Service]
EnvironmentFile=-/etc/default/cron
Environment="TZ=UTC"
ExecStart=/usr/sbin/cron -f -P $EXTRA_OPTS
IgnoreSIGPIPE=false
KillMode=process
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Add the crawler script for servers that crawl:
```
20 2,8,14,20 * * * /projects/ipfs/china_study/scripts/cron-crawl.sh >> /projects/ipfs/china_study/scripts/cron-crawl.log 2>&1
```

Add the download script for every machine:
```
3,8,13,18,23,28,33,38,43,48,53,58 * * * * bash -lc /projects/ipfs/china_study/scripts/cron-download.sh >> /projects/ipfs/china_study/scripts/cron-download.log 2>&1
```

The `bash -lc` part makes sure to run bash in login shell mode, which sets `PATH` according to the current user.
This is required if you install IPFS as a user, which places it somewhere in `$USER/.local/bin`.

