# SOGo 4 Debian packaging

## Requirements
+ Docker: https://docs.docker.com/install/

## Building SOGo deb packages
+ Run `docker run --rm -it -v $(pwd):/data debian:stretch /data/build.sh`
+ Find the packages inside the `vendor` directory
