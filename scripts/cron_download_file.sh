#!/bin/bash

infile="data/to_download.csv"
outdir="data/downloaded_files"
csvdir="data"
csv_file="$csvdir/downloads.csv"

mkdir -p "$outdir"
mkdir -p "$csvdir"

if [ ! -f "$csv_file" ]; then
    echo "timestamp,cid,expected_sha256,computed_sha256" > "$csv_file"
fi

# pop the last line off the CSV file
line=$(sed -i -e '${w /dev/stdout' -e 'd;}' "$infile")

# Check if we're done
if [ -z "$line" -o "$line" == "cid,sha256_hash" ]; then
    echo "Experiment is over."
    exit 0
fi

cid=$(echo "$line" | awk -F',' '{print $1}')
sha256_hash=$(echo "$line" | awk -F',' '{print $2}')

echo "Downloading CID $cid, saving output to $outdir/$cid..."
if [ -z ${ipfs_staging+x} ]; then
  echo "Detected non-dockerized setup"
else
  echo "Detected dockerized setup"
fi

# Get a timestamp
ts=$(date -u -Iseconds)

# touch this file in case something goes wrong. At least we'll know we tried.
touch "$outdir/$cid.time"
echo "$ts" > "$outdir/$cid.ts"

# Actually download
if [ -z ${ipfs_staging+x} ]; then
  # Non-dockerized version
  t=$(time (ipfs --timeout=5m get "$cid" -o "$outdir/$cid" >"$outdir/$cid.log" 2>&1) 2>&1)
else
  # Alternatively for dockerized daemons, assuming $ipfs_staging is set and mounted at /export for the daemon:
  t=$(time (docker exec ipfs_host ipfs --timeout=5m get "$cid" -o "/export/$cid" >"$outdir/$cid.log" 2>&1) 2>&1)
  # Fix permissions
  sudo chmod 644 "$ipfs_staging/$cid"
  sudo chown $USER:$USER "$ipfs_staging/$cid"
  cp "$ipfs_staging/$cid" "$outdir/$cid"
fi

# Save time it took
echo "$t" > "$outdir/$cid.time"

# Compute and save SHA256 hash
computed_sha=$(sha256sum "$outdir/$cid" | cut -d' ' -f 1)
echo "expected_sha256,computed_sha256" > "$outdir/$cid.sha256.csv"
echo "$sha256_hash,$computed_sha" >> "$outdir/$cid.sha256.csv"

# Append to results CSV
echo "$ts,$cid,$sha256_hash,$computed_sha" >> "$csv_file"

echo "Done downloading $cid."
