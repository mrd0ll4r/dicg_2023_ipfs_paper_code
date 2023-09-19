#!/bin/bash -e

mkdir -p data/gateways/results_server_{1,2,3,4}

rsync -av --progress ics-de-server:/projects/ipfs/china_study/data/gateways/results/* data/gateways/results_server_1/
rsync -av --progress ics-cn-client:/projects/ipfs/china_study/data/gateways/results/* data/gateways/results_server_2/
rsync -av --progress ics-us-client:/projects/ipfs/china_study/data/gateways/results/* data/gateways/results_server_3/
rsync -av --progress ics-us-server:/projects/ipfs/china_study/data/gateways/results/* data/gateways/results_server_4/

rsync -av --progress ics-de-server:/projects/ipfs/china_study/data/gateways/results.csv data/gateways/results_server_1.csv
rsync -av --progress ics-cn-client:/projects/ipfs/china_study/data/gateways/results.csv data/gateways/results_server_2.csv
rsync -av --progress ics-us-client:/projects/ipfs/china_study/data/gateways/results.csv data/gateways/results_server_3.csv
rsync -av --progress ics-us-server:/projects/ipfs/china_study/data/gateways/results.csv data/gateways/results_server_4.csv

