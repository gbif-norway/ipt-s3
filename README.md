# IPT-S3

IPT-S3 is a minimal extension of [GBIF](https://www.gbif.org)'s [IPT](https://hub.docker.com/r/gbif/ipt/) image that enables usage of S3 bucket storage.

> **_IMPORTANT:_**  Container requires to be run with elevated privileges because `s3fs` requires it.
> ```yml
>         securityContext:
>            privileged: true
>            capabilities:
>              add:
>                - SYS_ADMIN 
> ```

## Required environmental variables
* S3_BUCKET_NAME - name of the bucket. IPT-S3 will try to create the bucket before using it.
* S3_HOST - host url of the bucket
* S3_ACCESS_KEY - Access Key for the bucket
* S3_SECRET_KEY - Secret Access Key for the bucket

## Build image
```zsh
docker build --platform=linux/amd64 -t michaltorma/ipt-s3:main-ipt ./src
docker build -t gbifnorway/ipt-s3:main-ipt ./src
```