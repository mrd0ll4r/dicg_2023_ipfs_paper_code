#!/bin/bash -e

base_dir="data/files"

mkdir -p "$base_dir"

for i in $(seq 1 4); do
    echo "Generating files for server $i..."
    out_dir="$base_dir/server_${i}"
    mkdir -p "$out_dir"

    # Dirty hack
    server='$server'
    file_sizes=$(mlr --csv --headerless-csv-output filter "$server == $i" then cut -f file_size < plotting/csv/file_sizes.csv)

    for file_size in $file_sizes; do
        dd if=/dev/urandom bs=1 count=$file_size of="$out_dir/tmp" >/dev/null 2>&1
        hash=$(sha256sum "$out_dir/tmp" | cut -d' ' -f 1)
        mv "$out_dir/tmp" "$out_dir/$hash"
    done
done
