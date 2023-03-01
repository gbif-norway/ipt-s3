#!/bin/bash
rsync -avzWS $IPT_DATA_DIR /root/s3data/ --delete-after --no-compress 
