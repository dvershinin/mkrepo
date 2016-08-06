#!/bin/bash

set -xeuo pipefail

NGINX_VERSION="1.10.1"
NGINX_EPOCH=1
NJS_SHAID="1c50334fbea6"

MODSEC_VERSION="2.9.1"

yum install -y \
    perl-devel \
    perl-ExtUtils-Embed \
    pcre-devel \
    zlib-devel \
    openssl-devel \
    GeoIP-devel \
    libxslt-devel \
    gd-devel \
    httpd \
    httpd-devel \
    pcre \
    pcre-devel \
    libxml2-devel \
    yajl-devel \
    lua-devel \
    ssdeep-devel

cd /opt/

git clone https://github.com/SpiderLabs/ModSecurity

cd /opt/ModSecurity

git checkout v${MODSEC_VERSION}

./autogen.sh

rm -rf /opt/ModSecurity/nginx/modsecurity/config
cp /tmp/fpmbuild/config.in /opt/ModSecurity/nginx/modsecurity/config.in

./configure \
    --with-yajl \
    --enable-pcre-match-limit=no \
    --enable-pcre-match-limit-recursion=no \
    --enable-pcre-jit \
    --enable-pcre-study \
    --enable-standalone-module \
    --disable-mlogc \
    --with-ssdeep \
    --enable-lua-cache \
    --enable-shared

make CFLAGS=" -g -O2  -I/usr/include/apr-1 -fPIC"

cd /opt/

wget -O nginx-$NGINX_VERSION.tar.gz http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz
tar -xvzf nginx-$NGINX_VERSION.tar.gz
cd /opt/nginx-$NGINX_VERSION

mkdir -p /tmp/installdir

tar xvfz /tmp/fpmbuild/build/njs-${NJS_SHAID}.tar.gz -C /opt/nginx-$NGINX_VERSION

./configure \
    --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib64/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_xslt_module=dynamic \
    --with-http_image_filter_module=dynamic \
    --with-http_geoip_module=dynamic \
    --with-http_perl_module=dynamic \
    --add-dynamic-module=njs-1c50334fbea6/nginx \
    --with-threads \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_slice_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-ipv6 \
    --with-http_v2_module \
    --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic' \
    --add-dynamic-module=/opt/ModSecurity/nginx/modsecurity \

make modules

cd /tmp/fpmbuild

VERSION="${NGINX_VERSION}.${MODSEC_VERSION}"

VENDOR="Trustwave"
MAINTAINER="Michal Kubenka <mkubenka@gmail.com>"
SUMMARY="ModSecurity is an open source, cross platform web application firewall (WAF) engine"
DESCRIPTION="ModSecurity is an open source, cross platform web application firewall (WAF) engine for Apache, IIS and Nginx that is developed by Trustwave's SpiderLabs. It has a robust event-based programming language which provides protection from a range of attacks against web applications and allows for HTTP traffic monitoring, logging and real-time analys..."
URI="http://www.modsecurity.org"

fpm -s dir -t rpm -n nginx-module-modsecurity \
    --verbose \
    --vendor "$VENDOR" --maintainer "$MAINTAINER" --rpm-summary "$SUMMARY" --description "$DESCRIPTION" --url "$URI" \
    -v "$VERSION" \
    --iteration "$ITERATION" \
    --depends "nginx = ${NGINX_EPOCH}:${NGINX_VERSION}" \
    --depends apr \
    --depends apr-util \
    --depends yajl \
    --depends ssdeep-libs \
    -C /opt/nginx-$NGINX_VERSION/objs \
    --prefix /usr/lib64/nginx/modules \
    ngx_http_modsecurity.so

