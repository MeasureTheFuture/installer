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

# Create mtf project environment
mkdir mtf
mkdir mtf/src
echo "GOPATH=`pwd`/mtf" >> /etc/profile
echo "export GOPATH" >> /etc/profile
source /etc/profile

go get github.com/onsi/ginkgo
go get github.com/onsi/gomega
go get github.com/shirou/gopsutil
go build github.com/MeasureTheFuture/scout

