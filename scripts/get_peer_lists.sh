#!/bin/bash -e

mkdir -p data/peer_lists/server_{1,2,3,4,5}

rsync -av --progress ics-de-server:/projects/ipfs/china_study/data/swarm_peers/* data/peer_lists/server_1/
rsync -av --progress ics-cn-client:/projects/ipfs/china_study/data/swarm_peers/* data/peer_lists/server_2/
rsync -av --progress ics-us-client:/projects/ipfs/china_study/data/swarm_peers/* data/peer_lists/server_3/
rsync -av --progress ics-us-server:/projects/ipfs/china_study/data/swarm_peers/* data/peer_lists/server_4/
