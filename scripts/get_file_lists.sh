#!/bin/bash -e

scp ics-de-server:/projects/ipfs/china_study/data/files.csv data/files_server_1.csv
scp ics-cn-client:/projects/ipfs/china_study/data/files.csv data/files_server_2.csv
scp ics-us-client:/projects/ipfs/china_study/data/files.csv data/files_server_3.csv
scp ics-us-server:/projects/ipfs/china_study/data/files.csv data/files_server_4.csv
