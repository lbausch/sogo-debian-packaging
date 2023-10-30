#!/usr/bin/env bash

set -e

# https://stackoverflow.com/a/246128
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Path to config file
CONFIG_FILE="${BASE_DIR}/.env"

# shellcheck disable=SC2086
if [ ! -f "$CONFIG_FILE" ] && [ -z ${CI+x} ]; then
    echo "Error: You need to create a .env file. See .env.example for reference."
    exit 1
fi

# When running in CI do not source configuration file
# shellcheck disable=SC2086
if [ -z ${CI+x} ]; then
    set -a
    # shellcheck source=.env disable=SC1091
    . "$CONFIG_FILE"
    set +a
fi

REPOSITORY_SOGO="https://github.com/Alinto/sogo.git"
REPOSITORY_SOPE="https://github.com/Alinto/sope.git"
SOGO_GIT_TAG="SOGo-${VERSION_TO_BUILD}"
SOPE_GIT_TAG="SOPE-${VERSION_TO_BUILD}"

PACKAGES_DIR="${BASE_DIR}/vendor"
PACKAGES_TO_INSTALL="git zip wget make debhelper gnustep-make libssl-dev libgnustep-base-dev libldap2-dev libytnef0-dev zlib1g-dev libpq-dev libmariadbclient-dev-compat libmemcached-dev liblasso3-dev libcurl4-gnutls-dev devscripts libexpat1-dev libpopt-dev libsbjson-dev libsbjson2.3 libcurl4 liboath-dev libsodium-dev libzip-dev"

export DEBIAN_FRONTEND=noninteractive

cd "$PACKAGES_DIR"

# Do not install recommended or suggested packages
echo 'APT::Get::Install-Recommends "false";' >> /etc/apt/apt.conf
echo 'APT::Get::Install-Suggests "false";' >> /etc/apt/apt.conf

# Install required packages
# shellcheck disable=SC2086
apt-get update && apt-get install -y $PACKAGES_TO_INSTALL

# Download and install libwbxml2 and libwbxml2-dev
wget -c https://packages.sogo.nu/nightly/5/debian/pool/bookworm/w/wbxml2/libwbxml2-dev_0.11.8-1_amd64.deb
wget -c https://packages.sogo.nu/nightly/5/debian/pool/bookworm/w/wbxml2/libwbxml2-0_0.11.8-1_amd64.deb

dpkg -i libwbxml2-0_0.11.8-1_amd64.deb libwbxml2-dev_0.11.8-1_amd64.deb

# Install any missing packages
apt-get -f install -y

# Install Python
apt-get install -y python3 python-is-python3

# Checkout the SOPE repository with the given tag
git clone --depth 1 --branch "${SOPE_GIT_TAG}" $REPOSITORY_SOPE
cd sope

cp -a packaging/debian debian

dch --newversion "4.9.r1664.$VERSION_TO_BUILD" "Automated build for version 4.9.r1664.$VERSION_TO_BUILD"

./debian/rules

dpkg-checkbuilddeps && dpkg-buildpackage

cd "$PACKAGES_DIR"

# Install the built packages
dpkg -i libsope*.deb

# Checkout the SOGo repository with the given tag
git clone --depth 1 --branch "${SOGO_GIT_TAG}" $REPOSITORY_SOGO
cd sogo

cp -a packaging/debian debian

dch --newversion "$VERSION_TO_BUILD" "Automated build for version $VERSION_TO_BUILD"

# cp packaging/debian-multiarch/control-no-openchange debian

./debian/rules

dpkg-checkbuilddeps && dpkg-buildpackage -b

cd "$PACKAGES_DIR"

# Install the built packages
dpkg -i "sope4.9-gdl1-mysql_4.9.r1664.${VERSION_TO_BUILD}_amd64.deb"
dpkg -i "sope4.9-libxmlsaxdriver_4.9.r1664.${VERSION_TO_BUILD}_amd64.deb"
dpkg -i "sogo_${VERSION_TO_BUILD}_amd64.deb"
