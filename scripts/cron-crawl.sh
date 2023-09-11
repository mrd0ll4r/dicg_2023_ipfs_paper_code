#!/bin/bash -e

echo "It's $(date -u), starting crawl..."
cd /projects/ipfs/china_study/scripts
./cron_crawl.sh >> ./cron_crawl.log 2>&1

echo "It's now $(date -u), done crawling."
echo ""
