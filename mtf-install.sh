#!/bin/bash

# Update opkg.
opkg update
opkg upgrade
opkg install git

# Install golang.
if [ ! -f go1.6.3.linux-386.tar.gz ]; then
	wget https://storage.googleapis.com/golang/go1.6.3.linux-386.tar.gz
fi
mkdir /usr/local
tar -C /usr/local -xzf go1.6.3.linux-386.tar.gz
echo "PATH=$PATH:/usr/local/go/bin" >> /etc/profile

# Install OpenCV
opkg install http://reprage.com/ipkgs/opencv_3.0.0_x86.ipk
opkg install http://reprage.com/ipkgs/cvbindings_3.0.0_x86.ipk

# Create mtf project environment
mkdir mtf
mkdir mtf/src
echo "GOPATH=`pwd`/mtf" >> /etc/profile
echo "export GOPATH" >> /etc/profile
source /etc/profile

# Get and build everything we need for the scout.
go get github.com/onsi/ginkgo
go get github.com/onsi/gomega
go get github.com/shirou/gopsutil
go get github.com/MeasureTheFuture/scout
go build github.com/MeasureTheFuture/scout

# Configure the postgreSQL database.
opkg install http://reprage.com/ipkgs/postgres_9.4.5_x86.ipk
echo "PATH=$PATH:/usr/local/pgsql/bin/" >> /etc/profile
source /etc/profile
useradd postgres
mkdir /usr/local/pgsql/data
chown -R postgres:posgres /usr/local/pgsql
su - postgres
initdb -D /usr/local/pgsql/data -A md5 -W
posgres -D /usr/local/pgsql/data &
psql -v pass="'password'" -f db-bootstrap.sql
exit

# Get and build everything we need for the mothership.
opkg install nodejs
npm install npm -g



