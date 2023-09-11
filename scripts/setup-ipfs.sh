#!/bin/bash -e

mkdir tmp
cd tmp
wget https://github.com/ipfs/kubo/releases/download/v0.22.0/kubo_v0.22.0_linux-amd64.tar.gz
tar -xvf kubo_v0.22.0_linux-amd64.tar.gz
cd kubo
./install.sh

# you may need to log out and back in at this point
ipfs init
ipfs config profile apply server

# adjust ports in ~/.ipfs/config as necessary

# start the daemon via:
# ipfs daemon --enable-gc

