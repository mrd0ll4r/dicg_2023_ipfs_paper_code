#!/bin/bash

# Script to iterate through generated files in data/experiment_*/files/server_*/ and report hash and size to stdout, CSV-formatted.

echo "experiment,server,file_size,sha256_hash"

for ex in $(seq 1 2); do
    for server in $(seq 1 5); do
        for f in "data/experiment_0$ex/files/server_$server"/*; do
            b=$(basename "$f")

            s=$(wc -c "$f" | awk -F' ' '{print $1}')

            echo "$ex,$server,$s,$b"
        done
    done
done
