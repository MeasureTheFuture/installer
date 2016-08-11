#!/bin/bash

# Uninstall Java as it hogs up space and we don't need it.
opkg remove tinyb-dev
opkg remove tinyb
opkg remove openjdk-8-jdk
opkg remove openjdk-8-jre
opkg remove openjdk-8-java
opkg remove openjdk-8-common

# Uninstall random IoT platforms that hog space and we don't use.
opkg remove upm-dev
opkg remove upm
opkg remove mraa-doc
opkg remove mraa-dev
opkg remove wyliodrin-server
opkg remove libwyliodrin
opkg remove iotivity-sensorboard
opkg remove mraa
opkg remove iotivity-dev
opkg remove iotiviy
opkg remove iotivity-plugins-samples
opkg remove iotivity-plugins-staticdev
opkg remove iotivity-resource-dev
opkg remove iotivity-resource-samples
opkg remove iotivity-resource-thin-staticdev
opkg remove iotivity-tests
opkg remove iotivity-service-samples
opkg remove iotivity-service
opkg remove iotivity-simple-client
opkg remove iotivity-resource
opkg remove iotivity-service-dev
opkg remove iotivity-service-staticdev
opkg remove oobe
opkg remove flex-dev
opkg remove flex

opkg remove cppzmq-dev
opkg remove zeromq-dev
opkg remove iotkit-comm-c-dev
opkg remove iotkit-comm-c
opkg remove iotkit-comm-js
opkg remove zeromq
opkg remove iotkit-agent
opkg remove iotkit-opkg

# Get the other elements of the installer
wget https://raw.githubusercontent.com/MeasureTheFuture/installer/master/db-bootstrap.sql

# Install OpenCV
opkg install http://reprage.com/ipkgs/opencv_3.0.0_x86.ipk
opkg install http://reprage.com/ipkgs/cvbindings_3.0.0_x86.ipk

# Configure the postgreSQL database.
opkg install http://reprage.com/ipkgs/postgres_9.5.3_x86.ipk
echo "PATH=$PATH:/usr/local/pgsql/bin/" >> /etc/profile
echo "export PATH" >> /etc/profile
source /etc/profile
useradd postgres

# Configure SSL keys for the postgreSQL database.
chown -R postgres:postgres /usr/local/pgsql
sudo -u postgres initdb -D /usr/local/pgsql/data -A md5 -W

cd /usr/local/pgsql/data
openssl req -new -text -out server.req
openssl rsa -in privkey.pem -out server.key
rm privkey.pem
openssl req -x509 -in server.req -text -key server.key -out server.crt
chmod og-rwx server.key
echo "ssl = on" >> /usr/local/pgsql/data/postgresql.conf
cd ~/

chown -R postgres:postgres /usr/local/pgsql
sudo -u postgres postgres -D /usr/local/pgsql/data &
sleep 10
sudo -u postgres psql -v pass="'password'" -f db-bootstrap.sql

# Install MTF.
opkg install http://reprage.com/ipkgs/mtf_0.0.2_x86.ipk

# Migrate database to the latest version.
cd ~/mtf-build/
./migrate -url postgres://mothership_user:password@localhost:5432/mothership -path ./migrations up
