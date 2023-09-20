#!/bin/bash

outdir="data/swarm_peers"

mkdir -p "$outdir"

echo "Getting list of connected peers...."
if [ -z ${ipfs_staging+x} ]; then
  echo "Detected non-dockerized setup"
else
  echo "Detected dockerized setup"
fi

# Get a timestamp
ts=$(date '+%s')
nice_ts=$(date -u -Iseconds)
echo "It's now $nice_ts ($ts)"

# touch this file in case something goes wrong. At least we'll know we tried.
touch "$outdir/$ts.peers"
echo "$nice_ts" > "$outdir/$ts.ts"

# Actually download
if [ -z ${ipfs_staging+x} ]; then
  # Non-dockerized version
  ipfs swarm peers > "$outdir/$ts.peers" 2>"$outdir/$ts.error"
else
  # Alternatively for dockerized daemons, assuming $ipfs_staging is set and mounted at /export for the daemon:
  docker exec ipfs_host ipfs swarm peers > "$outdir/$ts.peers" 2>"$outdir/$ts.error"
fi

echo "Done getting list of connected peers."
