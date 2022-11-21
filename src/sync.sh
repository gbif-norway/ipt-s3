#!/bin/bash
while inotifywait -r -e modify,create,delete,move $IPT_DATA_DIR; do
    rsync -avz $IPT_DATA_DIR /root/s3data/ --delete-after 
done