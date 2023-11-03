# DICG 2023 IPFS Functionality Paper

Code for the DICG 2023 Paper "I'm InterPlanetary, Get Me Out of Here! Accessing IPFS From Restrictive Environments".

## Experiments

We run a total of four experiments:
- One experiment to ascertain gateway functionality from all vantage points.
- Three experiments to exchange data between the nodes in a controlled manner.
  These experiments differ in whether gateway pseudo-pinning was utilized to try to bolster the success rate.

Additionally, we collect peer lists of the nodes, to make statements about node interconnectivity.

## Data

We do not provide the datasets themselves, as, e.g., the peer lists contain sensitive information such as IP addresses.
However, we describe the setup and include all scripts required to replicate the experiments.

Please have a look at the [script/README](scripts/README.md) file for information on each of the scripts.
Please also have a look at the [plotting/README](plotting/README.md) file for information on the R scripts and evaluation.

## Machines

We use these machines, with an alias configured in `~/.ssh/config` for easier scripting:

```
server_1: DE, server, non-NATed, ics-de-server
server_2: CN, client, NATed, ics-cn-client
server_3: US, client, NATed, ics-us-client
server_4: US, server, non-NATed, ics-us-server
```

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

## Docker

This assumes you have the environemnt variables `ipfs_staging` and `ipfs_data` set to empty, existing directories.
It's advisable to have these exports in your `~/.profile`, for reasons explained below.

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
This can be achieved by having the variables auto-set in `~/.profile` and running cron jobs with `bash -lc <command>`.
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

Add the download script for every machine:
```
3,8,13,18,23,28,33,38,43,48,53,58 * * * * bash -lc /projects/ipfs/china_study/scripts/cron-download.sh >> /projects/ipfs/china_study/scripts/cron-download.log 2>&1
```

Add the script getting the list of connected peers for every maching:
```
3,8,13,18,23,28,33,38,43,48,53,58 * * * * bash -lc /projects/ipfs/china_study/scripts/cron-ipfs-swarm-peers.sh >> /projects/ipfs/china_study/cron-ipfs-swarm-peers.log 2>&1
```

The `bash -lc` part makes sure to run bash in login shell mode, which sets `PATH` according to the current user.
This is required if you install IPFS as a user, which places it somewhere in `$USER/.local/bin`.

For the experiments relying on gateway-cached data, add the caching script for every machine:
```
7 5,17 * * * bash -lc /projects/ipfs/china_study/scripts/cron-refresh.sh >> /projects/ipfs/china_study/scripts/cron-refresh.log 2>&1
```

## License

MIT, see [LICENSE](LICENSE).
