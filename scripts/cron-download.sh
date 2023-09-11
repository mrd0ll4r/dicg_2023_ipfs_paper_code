#!/bin/bash -e

echo "It's $(date -u), downloading an item..."
cd /projects/ipfs/china_study/
./scripts/cron_download_file.sh >> ./cron_download_file.log 2>&1

echo "It's now $(date -u), done downloading an item."
echo ""
