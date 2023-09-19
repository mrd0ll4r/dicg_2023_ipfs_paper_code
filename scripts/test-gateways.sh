#!/bin/bash

infile="data/gateways/gateways.txt"
csv_file="data/gateways/results.csv"
outdir="data/gateways/results"

rm -Rf "$outdir"
mkdir -p "$outdir"

# The CID to request.
# QmPZ9gcCEpqKTo6aq61g2nXGUhM4iCL3ewB6LDXZCtioEB is the README file shipped with every IPFS installation, it's almost guaranteed to be available in the network.
# bafybeiflvj6x42coend4h4waxl7blc46x2cm5urwc7rw3yo3y4bfugzsgy is a text file from one of the IPFS tutorials. It's not stored on nodes by default, so this tests whether the gateways actually request from the network, have a whitelist, etc.
#example_cid="QmPZ9gcCEpqKTo6aq61g2nXGUhM4iCL3ewB6LDXZCtioEB"
example_cid="bafybeiflvj6x42coend4h4waxl7blc46x2cm5urwc7rw3yo3y4bfugzsgy"

cache_bust_ts=$(date '+%s')

# Initialize CSV
echo "timestamp,gateway,gateway_base64,url,response_code,effective_url,computed_sha256,error" > "$csv_file"

# For each gateway...
for gw in $(cat "$infile"); do
    base64_name="$(echo $gw | base64)"
    url="${gw/:hash/$example_cid}?now=$cache_bust_ts"
    echo "Requesting $url, which is on gateway $base64_name..."

    ts=$(date -u -Iseconds)
    curl -s -L -S -o "$outdir/$base64_name.data" -w "%{response_code},%{url_effective}\n" "$url" 1>"$outdir/$base64_name.req_metadata" 2>"$outdir/$base64_name.error"

    sha256=$(cat "$outdir/$base64_name.data" | sha256sum | cut -d' ' -f 1)
    error=$(cat "$outdir/$base64_name.error")
    response_code=$(cat "$outdir/$base64_name.req_metadata" | awk -F',' '{print $1}')
    effective_url=$(cat "$outdir/$base64_name.req_metadata" | awk -F',' '{print $2}')

    echo "Got SHA256-ed result $sha256, error $error, response code $response_code, effective URL $effective_url"

    echo "$ts,\"$gw\",\"$base64_name\",\"$url\",$response_code,\"$effective_url\",$sha256,\"$error\"" >> "$csv_file"
done
