#!/bin/bash
echo "Install Tomcat ..."
#Start install Java
echo "Install Java 8"
yum -y update
yum -y install java-1.8.0-openjdk
regex=$(echo -ne '\n' | update-alternatives --config java | grep 1.8.0 | awk '{print $4}') 
javaHome=$(echo "$regex" | sed -e 's/(//g' -e 's/)//g')
echo "export JAVA_HOME=$javaHome" >> .bash_profile
source .bash_profile
echo "Install Java 8 SUCCESS"
#Start install Tomcat
#Create a dedicated user for Apache Tomcat
groupadd tomcat
mkdir /opt/tomcat
useradd -s /bin/nologin -g tomcat -d /opt/tomcat tomcat
#Download and install the latest Apache Tomcat
cd ~
wget http://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.61/bin/apache-tomcat-8.5.61.tar.gz
tar -zxvf apache-tomcat-8.5.61.tar.gz -C /opt/tomcat --strip-components=1
#Setup proper permissions
cd /opt/tomcat
chgrp -R tomcat conf
chmod g+rwx conf
chmod g+r conf/*
chown -R tomcat logs/ temp/ webapps/ work/
chgrp -R tomcat bin
chgrp -R tomcat lib
chmod g+rwx bin
chmod g+r bin/*
#Setup a Systemd unit file for Apache Tomcat
cat > /etc/systemd/system/tomcat.service <<EOF
[Unit]
Description=Apache Tomcat Web Application Container
After=syslog.target network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/bin/kill -15 $MAINPID

User=tomcat
Group=tomcat

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
#Start and test Apache Tomcat
systemctl start tomcat.service
systemctl enable tomcat.service
#Configure the Apache Tomcat web management interface
cat > /opt/tomcat/conf/tomcat-users.xml <<EOF
<user username="ptmduc" password="Minhduc7bB" roles="manager-gui,admin-gui"/>
EOF
#Restart Apache Tomcat
systemctl restart tomcat.service