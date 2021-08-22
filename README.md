# SOGo Debian packaging

## Requirements
+ Docker: https://docs.docker.com/install/

## Building SOGo deb packages
+ `cp .env.example .env` and adjust `.env` to your needs
+ Run `docker run --rm -it -v $(pwd):/data debian:buster /data/build.sh`
+ Find the packages inside the `vendor` directory

## Older Debian releases
See the respective branches for older Debian releases

## GitLab CI support
See `.gitlab-ci.yml` for integration with GitLab CI
