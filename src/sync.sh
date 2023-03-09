#!/bin/bash
rsync -avzWS /root/s3data/resources/o_dna_arthropods/sources $IPT_DATA_DIR/resources/o_dna_arthropods/sources --delete-after --no-compress
rsync -avzWS /root/s3data/resources/o_dna_fish_herptiles/sources $IPT_DATA_DIR/resources/o_dna_fish_herptiles/sources --delete-after --no-compress
rsync -avzWS /root/s3data/resources/o_dna_fungi_lichens/sources $IPT_DATA_DIR/resources/o_dna_fungi_lichens/sources --delete-after --no-compress
rsync -avzWS /root/s3data/resources/o_dna_other/sources $IPT_DATA_DIR/resources/o_dna_other/sources --delete-after --no-compress
rsync -avzWS /root/s3data/resources/o_dna_plants/sources $IPT_DATA_DIR/resources/o_dna_plants/sources --delete-after --no-compress
rsync -avzWS /root/s3data/resources/o_mammals/sources $IPT_DATA_DIR/resources/o_mammals/sources --delete-after --no-compress
rsync -avzWS /root/s3data/resources/birds/sources $IPT_DATA_DIR/resources/birds/sources --delete-after --no-compress
rsync -avzWS $IPT_DATA_DIR /root/s3data/ --delete-after --no-compress
echo $(date) "Backup complete" >> /var/log/backup.log
echo $(date) "Backup complete"
