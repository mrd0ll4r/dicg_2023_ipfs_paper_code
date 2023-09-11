#!/bin/bash -e

indir="data/files/"
outfile="data/files.csv"

echo "Adding all files from $indir to IPFS, writing results to $outfile"
if [ -z ${ipfs_staging+x} ]; then
  echo "Detected non-dockerized setup"
else
  echo "Detected dockerized setup"
fi

echo "cid,sha256_hash" > "$outfile";

for f in $(find "$indir" -type f); do
    echo $f;
    sha256_hash=$(basename "$f");
    if [ -z ${ipfs_staging+x} ]; then
      # Non-dockerized version
      cid=$(ipfs add --cid-version 1 -Q "$f");
    else
      # Alternatively, for dockerized kubo:
      # This assumes the $ipfs_staging variable is set to a directory accessible by the dockerized daemon at /export
      cp "$f" "$ipfs_staging/"
      cid=$(docker exec ipfs_host ipfs add --cid-version 1 -Q "/export/$sha256_hash");
    fi
    echo "$cid,$sha256_hash">>"$outfile";
done
