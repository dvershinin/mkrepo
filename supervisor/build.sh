#!/bin/bash

set -xeuo pipefail

yum install -y \
  epel-release \
  python-setuptools \
  python-devel \
  rpm-build

mkdir -p /tmp/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
echo '%_topdir /tmp/rpmbuild' > ~/.rpmmacros

cd /tmp/fpmbuild

cp /tmp/fpmbuild/sources/supervisor*.tar.gz /tmp/rpmbuild/SOURCES
cp /tmp/fpmbuild/sources/supervisord.init /tmp/rpmbuild/SOURCES
cp /tmp/fpmbuild/sources/supervisord.conf /tmp/rpmbuild/SOURCES
cp /tmp/fpmbuild/sources/supervisor.logrotate /tmp/rpmbuild/SOURCES

VERSION="3.1.3"
RELEASE="${ITERATION}%{?dist}"
EPOCH="1"

rpmbuild \
    --define="version ${VERSION}" \
    --define="release ${RELEASE}" \
    --define="epoch ${EPOCH}" \
    -bb \
    /tmp/fpmbuild/sources/supervisor.spec

cp /tmp/rpmbuild/RPMS/noarch/supervisor-${VERSION}*.rpm /tmp/fpmbuild
