#!/bin/bash -e

mkdir -p data/download_results/server_{1,2,3,4,5}

# We do not regularly download the downloaded files themselves, because they are potentially large and could skew the ongoing measurements.

rsync -av --progress ics-de-server:/projects/ipfs/china_study/data/downloaded_files/*.csv data/download_results/server_1/
rsync -av --progress ics-cn-client:/projects/ipfs/china_study/data/downloaded_files/*.csv data/download_results/server_2/
rsync -av --progress ics-us-client:/projects/ipfs/china_study/data/downloaded_files/*.csv data/download_results/server_3/
rsync -av --progress ics-us-server:/projects/ipfs/china_study/data/downloaded_files/*.csv data/download_results/server_4/
#rsync -av --progress ics-cn-server:/projects/ipfs/china_study/data/downloaded_files/*.csv data/download_results/server_5/

rsync -av --progress ics-de-server:/projects/ipfs/china_study/data/downloaded_files/*.time data/download_results/server_1/
rsync -av --progress ics-cn-client:/projects/ipfs/china_study/data/downloaded_files/*.time data/download_results/server_2/
rsync -av --progress ics-us-client:/projects/ipfs/china_study/data/downloaded_files/*.time data/download_results/server_3/
rsync -av --progress ics-us-server:/projects/ipfs/china_study/data/downloaded_files/*.time data/download_results/server_4/
#rsync -av --progress ics-cn-server:/projects/ipfs/china_study/data/downloaded_files/*.time data/download_results/server_5/

rsync -av --progress ics-de-server:/projects/ipfs/china_study/data/downloaded_files/*.log data/download_results/server_1/
rsync -av --progress ics-cn-client:/projects/ipfs/china_study/data/downloaded_files/*.log data/download_results/server_2/
rsync -av --progress ics-us-client:/projects/ipfs/china_study/data/downloaded_files/*.log data/download_results/server_3/
rsync -av --progress ics-us-server:/projects/ipfs/china_study/data/downloaded_files/*.log data/download_results/server_4/
#rsync -av --progress ics-cn-server:/projects/ipfs/china_study/data/downloaded_files/*.log data/download_results/server_5/

rsync -av --progress ics-de-server:/projects/ipfs/china_study/data/downloads.csv data/downloads_server_1.csv
rsync -av --progress ics-cn-client:/projects/ipfs/china_study/data/downloads.csv data/downloads_server_2.csv
rsync -av --progress ics-us-client:/projects/ipfs/china_study/data/downloads.csv data/downloads_server_3.csv
rsync -av --progress ics-us-server:/projects/ipfs/china_study/data/downloads.csv data/downloads_server_4.csv
#rsync -av --progress ics-cn-server:/projects/ipfs/china_study/data/downloads.csv data/downloads_server_5.csv

