#!/bin/bash

# Define an associative array for mapping zip files to directories
declare -A dir_map
dir_map=(
    ["NHMO-BI.zip"]="/srv/ipt/resources/birds/source/"
    ["NHMO-DAR.zip"]="/srv/ipt/resources/o_dna_arthropods/source/"
    ["NHMO-DFH.zip"]="/srv/ipt/resources/o_dna_fish_herptiles/source/"
    ["O-DFL.zip"]="/srv/ipt/resources/o_dna_fungi_lichens/source/"
    ["NHMO-DOT.zip"]="/srv/ipt/resources/o_dna_other/source/"
    ["O-DP.zip"]="/srv/ipt/resources/o_dna_plants/source/"
    ["NHMO-DMA.zip"]="/srv/ipt/resources/o_mammals/source/"
)

# For each key in the dir_map array
for zip_file in "${!dir_map[@]}"; do
    # Download the zip file
    s4cmd get "s3://$S3_ZIP_BUCKET_NAME/$zip_file" "$zip_file" --endpoint-url $S3_HOST

    # If the download was successful, unzip the file into the correct directory, overwriting any files with the same name there already
    if [ $? -eq 0 ]; then
        unzip -o "$zip_file" -d "${dir_map[$zip_file]}"

        # If the unzip was successful, log to /var/log/unzip.log
        if [ $? -eq 0 ]; then
            echo "$(date '+%Y-%m-%d %T'): Successfully unzipped $zip_file to ${dir_map[$zip_file]}" >> /var/log/unzip.log
        else
            echo "$(date '+%Y-%m-%d %T'): Failed to unzip $zip_file" >> /var/log/unzip.log
        fi

        # Remove the downloaded zip file
        rm "$zip_file"
    else
        echo "$(date '+%Y-%m-%d %T'): Failed to download $zip_file" >> /var/log/unzip.log
    fi
done
