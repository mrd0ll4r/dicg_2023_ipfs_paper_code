#!/bin/bash -e

echo "It's $(date -u), refreshing gateway cache..."
cd /projects/ipfs/china_study/
./scripts/cron_refresh_gateway_caches.sh >> ./cron_refresh_gateway_caches.log 2>&1

echo "It's now $(date -u), done refreshing gateway cache."
echo ""
