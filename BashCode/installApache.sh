#!/bin/bash
httpdVersion=2.4.46
aprVersion=1.7.0
aprUtilVersion=1.6.1
yum -y install wget
yum install epel-release -y
yum install autoconf expat-devel libtool libnghttp2-devel pcre-devel -y
wget https://mirror.downloadvn.com/apache//httpd/httpd-$httpdVersion.tar.gz
wget https://mirror.downloadvn.com/apache//apr/apr-$aprVersion.tar.gz
wget https://mirror.downloadvn.com/apache//apr/apr-util-$aprUtilVersion.tar.gz
tar -zxvf httpd-$httpdVersion.tar.gz
tar -zxvf apr-$aprVersion.tar.gz
tar -zxvf apr-util-$aprUtilVersion.tar.gz
cp -r apr-$aprVersion httpd-$httpdVersion/srclib/apr
cp -r apr-util-$aprUtilVersion httpd-$httpdVersion/srclib/apr-util
cd httpd-$httpdVersion
./buildconf
./configure --enable-ssl --enable-so --with-mpm=event --with-included-apr --prefix=/usr/local/apache2
make
make install
httpd -v
cat > /etc/profile.d/httpd.sh <<EOF
pathmunge /usr/local/apache2/bin
EOF
cat >  /etc/systemd/system/httpd.service <<EOF
[Unit]
Description=The Apache HTTP Server
After=network.target

[Service]
Type=forking
ExecStart=/usr/local/apache2/bin/apachectl -k start
ExecReload=/usr/local/apache2/bin/apachectl -k graceful
ExecStop=/usr/local/apache2/bin/apachectl -k graceful-stop
PIDFile=/usr/local/apache2/logs/httpd.pid
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
sudo groupadd www
sudo useradd httpd -g www --no-create-home --shell /sbin/nologin

systemctl start httpd
systemctl enable httpd
