#!/bin/bash

# Define an associative array for mapping zip files to directories
declare -A dir_map
dir_map=(
    ["NHMO-BI.zip"]="/srv/ipt/resources/birds/sources/"
    ["NHMO-DAR.zip"]="/srv/ipt/resources/o_dna_arthropods/sources/"
    ["NHMO-DFH.zip"]="/srv/ipt/resources/o_dna_fish_herptiles/sources/"
    ["O-DFL.zip"]="/srv/ipt/resources/o_dna_fungi_lichens/sources/"
    ["NHMO-DOT.zip"]="/srv/ipt/resources/o_dna_other/sources/"
    ["O-DP.zip"]="/srv/ipt/resources/o_dna_plants/sources/"
    ["NHMO-DMA.zip"]="/srv/ipt/resources/o_mammals/sources/"
    ["NHMO-IN.zip"]="/srv/ipt/resources/nhmo-hm/sources/"
)

send_to_discord() {
    local message="$1"
    local webhook_url=$DISCORD_WEBHOOK_URL # Use the environment variable
    curl -H "Content-Type: application/json" \
         -d "{\"content\": \"$message\"}" \
         $webhook_url
}

# For each key in the dir_map array
for zip_file in "${!dir_map[@]}"; do
    # Download the zip file
    /root/minio-binaries/mc cp "sigma2/$S3_ZIP_BUCKET_NAME/$zip_file" "$zip_file"

    # If the download was successful, unzip the file into the correct directory, overwriting any files with the same name there already
    if [ $? -eq 0 ]; then
        unzip -o "$zip_file" -d "${dir_map[$zip_file]}"

        # If the unzip was successful, log to /var/log/unzip.log
        if [ $? -eq 0 ]; then
            message="$(date '+%Y-%m-%d %T'): Successfully unzipped $zip_file to ${dir_map[$zip_file]}"
            echo "$message" >> /var/log/unzip.log
            send_to_discord "$message"
        else
            message="$(date '+%Y-%m-%d %T'): Failed to unzip $zip_file"
            echo "$message" >> /var/log/unzip.log
            send_to_discord "$message"
        fi

        # Remove the downloaded zip file
        rm "$zip_file"
    else
        message="$(date '+%Y-%m-%d %T'): Failed to download $zip_file"
        echo "$message" >> /var/log/unzip.log
        send_to_discord "$message"
    fi
done
echo "-----" >> /var/log/unzip.log
