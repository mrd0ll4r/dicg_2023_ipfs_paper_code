#!/bin/bash -e

echo "It's $(date -u),  getting list of peers..."
cd /projects/ipfs/china_study/
./scripts/cron_ipfs_swarm_peers.sh >> ./cron_ipfs_swarm_peers.log 2>&1

echo "It's now $(date -u), done getting list of peers."
echo ""
