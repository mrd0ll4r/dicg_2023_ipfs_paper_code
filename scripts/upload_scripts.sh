#!/bin/bash -e

rsync -av --progress scripts/* ics-de-server:/projects/ipfs/china_study/scripts/
rsync -av --progress scripts/* ics-cn-client:/projects/ipfs/china_study/scripts/
rsync -av --progress scripts/* ics-us-client:/projects/ipfs/china_study/scripts/
rsync -av --progress scripts/* ics-us-server:/projects/ipfs/china_study/scripts/
rsync -av --progress scripts/* ics-cn-server:/projects/ipfs/china_study/scripts/
