#!/bin/bash

# This script takes the list of CIDs stored on this machine,
# and a list of known-to-function gateways,
# and requests each CID off two randomly selected gateways.
# The whole thing happens in parallel, with timeouts between requests.

echo "Starting refresh..."

cat data/files.csv |
    tail -n +2 |
    awk -F',' '{print $1}' |
    shuf |
    parallel -j10 'cat data/functioning_gateways.csv | tail -n +2 | shuf -n 2 | sed "s/\:hash/{}/"' |
    parallel -j10 'echo "requesting {}... $(curl -o /dev/null -s -S -w "%{response_code}" -L {} 2>&1)"; sleep 5'

echo "Done refreshing."
