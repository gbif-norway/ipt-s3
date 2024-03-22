# IPT-S3

IPT-S3 is a minimal extension of [GBIF](https://www.gbif.org)'s [IPT](https://hub.docker.com/r/gbif/ipt/) image that backs up automatically to an S3 bucket storage. The image itself only contains extra driver for Oracle database (needed for our MUSIT integration). Secondary sidecar image adds automatic backups to minio bucket (NIRD storage). Sidecar container also runs miscellaneous scripts for individual integrations that don't like to behave nicely on their own and need access to the ipt storage directly (e.g. COREMA).

## Required environmental variables
* S3_BUCKET_NAME - Name of the bucket. IPT-S3 will try to create the bucket before using it.
* S3_HOST - Host url of the bucket
* S3_ACCESS_KEY - Access Key for the bucket
* S3_SECRET_KEY - Secret Access Key for the bucket
* S3_ZIP_BUCKET_NAME - Optional. If there are DWCAs which need to regularly be synced to the IPT, this is that bucket name.

## Build image
to build both ipt image and its sidecar, from the root of the repo, run:
```zsh
docker compose build
```
This builds images with tags:
- gbifnorway/ipt-sidecar:latest
- gbifnorway/ipt-s3:latest

Then you can push them with `docker compose push`

## To update the IPT
1. Change the version number as desired in `ipt/Dockerfile`
2. Build the image and push it (see above)
3. Delete pod using `kubectl delete pod [ipt-podname]`

## Restore from a backup
In our case, to retrieve a particular backup do the following:
1. SSH into the NIRD server (login.nird-lmd.sigma2.no) using your meta credentials
2. Copy (using rsync, not cp) from the desired snapshot folder to a bucket folder. E.g. `rsync -av --delete /nird/projects/NS8095K/.snapshots/Sunday-07-May-2023/ipt-slovakia/ /nird/projects/NS8095K/ipt-slovakia/`
3. SSH into the desired IPT pod on the cluster using kubectl
4. Delete (or move) the contents of /srv/ipt so that /srv/ipt is empty
5. Copy from bucket to the local /srv/ipt: `s4cmd dsync --force --recursive --verbose --sync-check --num-threads=5 s3://$S3_BUCKET_NAME /srv/ipt --endpoint-url $S3_HOST`
6. Reset tomcat: `touch /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml`

## Individual deployments
### Slovakia
slovakia.ipt.gbif.no
`helm upgrade --install slovakia ./helm/ipt-s3`
pvc: `slovakia-pvc`
### Corema
corema.ipt.gbif.no
`helm upgrade --install corema ./helm/ipt-s3 --set zipBucket="corema-exports/gbif",persistentStorage=2Gi`
### Tajik
tajik.ipt.gbif.no
`helm upgrade --install tajik ./helm/ipt-s3 --set persistentStorage=1Gi`
### Armenia
armenia.ipt.gbif.no
`helm upgrade --install armenia ./helm/ipt-s3`
### Main IPT
ipt.gbif.no
`helm upgrade --install main ./helm/ipt-s3 --set hostName=ipt.gbif.no,persistentStorage=20Gi`
### Ukraine
ukraine.ipt.gbif.no
`helm upgrade --install ukraine ./helm/ipt-s3 --set persistentStorage=4Gi`
### Test IPT
test.ipt.gbif.no
`helm upgrade --install test ./helm/ipt-s3`

