#!/bin/bash -e

rsync -av --progress data/files/server_1/* ics-de-server:/projects/ipfs/china_study/data/files/
rsync -av --progress data/files/server_2/* ics-cn-client:/projects/ipfs/china_study/data/files/
rsync -av --progress data/files/server_3/* ics-us-client:/projects/ipfs/china_study/data/files/
rsync -av --progress data/files/server_4/* ics-us-server:/projects/ipfs/china_study/data/files/
rsync -av --progress data/files/server_5/* ics-cn-server:/projects/ipfs/china_study/data/files/
