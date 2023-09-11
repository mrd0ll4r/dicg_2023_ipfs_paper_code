#!/bin/bash -e

cd ../ipfs-crawler

export LIBP2P_ALLOW_WEAK_RSA_KEYS="" && export LIBP2P_SWARM_FD_LIMIT="10000" && ./out/libp2p-crawler --config dist/config_ipfs.yaml

for f in output_data_crawls/ipfs/*.csv; do
        echo "compressing $f..."
        gzip -9 "$f"
done

for f in output_data_crawls/ipfs/*.json; do
        echo "compressing $f..."
        gzip -9 "$f"
done

