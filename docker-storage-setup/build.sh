#!/bin/bash

set -xeuo pipefail

mkdir -p /tmp/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir /tmp/rpmbuild' > ~/.rpmmacros

git clone https://github.com/projectatomic/docker-storage-setup /tmp/docker-storage-setup

cd /tmp/docker-storage-setup

cp /tmp/docker-storage-setup/docker-storage-setup.sh /tmp/rpmbuild/SOURCES
cp /tmp/docker-storage-setup/docker-storage-setup.service /tmp/rpmbuild/SOURCES
cp /tmp/docker-storage-setup/docker-storage-setup.conf /tmp/rpmbuild/SOURCES
cp /tmp/docker-storage-setup/docker-storage-setup-override.conf /tmp/rpmbuild/SOURCES
cp /tmp/docker-storage-setup/libdss.sh /tmp/rpmbuild/SOURCES

sed -i "s|Version:.*|Version: %{version}|g" /tmp/docker-storage-setup/docker-storage-setup.spec
sed -i "s|Release:.*|Release: %{release}|g" /tmp/docker-storage-setup/docker-storage-setup.spec
sed -i "/Release:.*/a Epoch: %{epoch}" /tmp/docker-storage-setup/docker-storage-setup.spec

COMMIT="$(git rev-parse --short HEAD)"
VERSION="0.5"
RELEASE="${ITERATION}.git${COMMIT}%{?dist}"
EPOCH="1"

rpmbuild \
    --define="version ${VERSION}" \
    --define="release ${RELEASE}" \
    --define="epoch ${EPOCH}" \
    -bb \
    /tmp/docker-storage-setup/docker-storage-setup.spec

cp /tmp/rpmbuild/RPMS/x86_64/docker-storage-setup-${VERSION}*.rpm /tmp/fpmbuild
