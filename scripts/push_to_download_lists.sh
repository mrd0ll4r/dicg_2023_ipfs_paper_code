#!/bin/bash -e

scp plotting/csv/file_download_assignments_server_1.csv ics-de-server:/projects/ipfs/china_study/data/to_download.csv
scp plotting/csv/file_download_assignments_server_2.csv ics-cn-client:/projects/ipfs/china_study/data/to_download.csv
scp plotting/csv/file_download_assignments_server_3.csv ics-us-client:/projects/ipfs/china_study/data/to_download.csv
scp plotting/csv/file_download_assignments_server_4.csv ics-us-server:/projects/ipfs/china_study/data/to_download.csv
scp plotting/csv/file_download_assignments_server_5.csv ics-cn-server:/projects/ipfs/china_study/data/to_download.csv

