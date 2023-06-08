# IPT-S3

IPT-S3 is a minimal extension of [GBIF](https://www.gbif.org)'s [IPT](https://hub.docker.com/r/gbif/ipt/) image that backs up automatically to an S3 bucket storage.

## Required environmental variables
* S3_BUCKET_NAME - Name of the bucket. IPT-S3 will try to create the bucket before using it.
* S3_HOST - Host url of the bucket
* S3_ACCESS_KEY - Access Key for the bucket
* S3_SECRET_KEY - Secret Access Key for the bucket
* S3_ZIP_BUCKET_NAME - Optional. If there are DWCAs which need to regularly be synced to the IPT, this is that bucket name.

## Build image
```zsh
docker build --platform=linux/amd64 -t michaltorma/ipt-s3:ipt-main ./src
docker build -t gbifnorway/ipt-s3:ipt-main ./src
docker push gbifnorway/ipt-s3:ipt-main
```

## Restore from a backup
In our case, to retrieve a particular backup do the following: 
1. SSH into the NIRD server (login.nird-lmd.sigma2.no) using your meta credentials 
2. Copy (using rsync, not cp) from the desired snapshot folder to a bucket folder. E.g. `rsync -av --delete /nird/projects/NS8095K/.snapshots/Sunday-07-May-2023/ipt-slovakia/ /nird/projects/NS8095K/ipt-slovakia/`
3. SSH into the desired IPT pod on the cluster using kubectl 
4. Delete (or move) the contents of /srv/ipt so that /srv/ipt is empty
5. Copy from bucket to the local /srv/ipt: `s4cmd dsync --force --recursive --verbose --sync-check --num-threads=5 s3://$S3_BUCKET_NAME $IPT_DATA_DIR --endpoint-url $S3_HOST`
6. Reset tomcat: `touch /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml`
