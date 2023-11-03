#!/bin/bash -e

experiment=3
mkdir -p data/experiment_0$experiment/download_results/server_{1,2,3,4}

# We do not regularly download the downloaded files themselves, because they are potentially large and could skew the ongoing measurements.

rsync -av --progress ics-de-server:/projects/ipfs/china_study/data/downloaded_files/*.csv data/experiment_0${experiment}/download_results/server_1/
rsync -av --progress ics-cn-client:/projects/ipfs/china_study/data/downloaded_files/*.csv data/experiment_0${experiment}/download_results/server_2/
rsync -av --progress ics-us-client:/projects/ipfs/china_study/data/downloaded_files/*.csv data/experiment_0${experiment}/download_results/server_3/
rsync -av --progress ics-us-server:/projects/ipfs/china_study/data/downloaded_files/*.csv data/experiment_0${experiment}/download_results/server_4/

rsync -av --progress ics-de-server:/projects/ipfs/china_study/data/downloaded_files/*.time data/experiment_0${experiment}/download_results/server_1/
rsync -av --progress ics-cn-client:/projects/ipfs/china_study/data/downloaded_files/*.time data/experiment_0${experiment}/download_results/server_2/
rsync -av --progress ics-us-client:/projects/ipfs/china_study/data/downloaded_files/*.time data/experiment_0${experiment}/download_results/server_3/
rsync -av --progress ics-us-server:/projects/ipfs/china_study/data/downloaded_files/*.time data/experiment_0${experiment}/download_results/server_4/

rsync -av --progress ics-de-server:/projects/ipfs/china_study/data/downloaded_files/*.log data/experiment_0${experiment}/download_results/server_1/
rsync -av --progress ics-cn-client:/projects/ipfs/china_study/data/downloaded_files/*.log data/experiment_0${experiment}/download_results/server_2/
rsync -av --progress ics-us-client:/projects/ipfs/china_study/data/downloaded_files/*.log data/experiment_0${experiment}/download_results/server_3/
rsync -av --progress ics-us-server:/projects/ipfs/china_study/data/downloaded_files/*.log data/experiment_0${experiment}/download_results/server_4/

rsync -av --progress ics-de-server:/projects/ipfs/china_study/data/downloads.csv data/experiment_0${experiment}/downloads_server_1.csv
rsync -av --progress ics-cn-client:/projects/ipfs/china_study/data/downloads.csv data/experiment_0${experiment}/downloads_server_2.csv
rsync -av --progress ics-us-client:/projects/ipfs/china_study/data/downloads.csv data/experiment_0${experiment}/downloads_server_3.csv
rsync -av --progress ics-us-server:/projects/ipfs/china_study/data/downloads.csv data/experiment_0${experiment}/downloads_server_4.csv

