#!/bin/bash
PCRE_version=8.43
ZLIB_version=1.2.11
OPENSSL_version=1.1.1c
NGINX_version=1.17.6
yum -y update
yum group install "Development Tools"
echo "Install PCRE"
wget https://ftp.pcre.org/pub/pcre/pcre-$PCRE_version.tar.gz && \
            tar -zxf pcre-$PCRE_version.tar.gz && \
            cd pcre-$PCRE_version  && \
            ./configure && \
            make && \
            make install
cd
echo "Install zlib"
wget http://zlib.net/zlib-$ZLIB_version.tar.gz && \
             tar -zxf zlib-$ZLIB_version.tar.gz && \
             cd zlib-$ZLIB_version && \
             ./configure && \
             make && \
             make install
cd
echo "Install OpenSSL"
wget http://www.openssl.org/source/openssl-$OPENSSL_version.tar.gz && \
             tar -zxf openssl-$OPENSSL_version.tar.gz && \
             cd openssl-$OPENSSL_version && \
             ./Configure linux-x86_64 --prefix=/usr && \
             make && \
             make install
cd
echo "Install Nginx"
wget https://nginx.org/download/nginx-$NGINX_version.tar.gz && \
             tar zxf nginx-$NGINX_version.tar.gz && \
             cd nginx-$NGINX_version && \
             ./configure \
             --sbin-path=/usr/local/nginx/nginx \
             --conf-path=/usr/local/nginx/nginx.conf \
             --pid-path=/usr/local/nginx/nginx.pid \
             --with-pcre=../pcre-$PCRE_version  \
             --with-zlib=../zlib-$ZLIB_version \
             --with-http_ssl_module \
             --with-stream \
             --with-mail && \
             make  && \
             make install
