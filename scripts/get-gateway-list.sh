#!/bin/bash -e

mkdir -p data/gateways

curl -o data/gateways/gateways.ts https://raw.githubusercontent.com/ipfs/public-gateway-checker/master/src/gateways.ts

# Transform that to bash-processable text
echo "[" $(tail -n +2 data/gateways/gateways.ts | head -n -1) "\"\"]" | tr "\'" '"' | jq -r '.[]' | sed '/^\s*$/d' > data/gateways/gateways.txt

