#!/bin/bash

sudo apt-get update
sudo apt-get upgrade
sudo apt-get purge --auto-remove gvfs-backends gvfs-fuse
sudo apt-get install vim

# Install go-lang
wget https://storage.googleapis.com/golang/go1.7.3.linux-armv6l.tar.gz
sudo tar -C /usr/local -xzf go1.7.3.linux-armv6l.tar.gz

# Install OpenCV.
sudo apt-get install build-essential git cmake pkg-config
sudo apt-get install libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev
sudo apt-get install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install libxvidcore-dev libx264-dev
sudo apt-get install libatlas-base-dev gfortran
sudo apt-get install postgresql-9.4
sudo apt-get install nodejs npm
sudo npm install npm -g

wget https://github.com/Itseez/opencv/archive/3.1.0.zip
unzip 3.1.0.zip
cd opencv-3.1.0
mkdir release
cd release
cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=/usr/local ..
make -j4
sudo make install

cd ~
mkdir mtf
cd mtf
git clone https://github.com/MeasureTheFuture/CVBindings.git
cd CVBindings
cmake .
make
sudo cp CVBindings.h /usr/local/include/
sudo cp libCVBindings.a /usr/local/lib/

cd ..
mkdir mtf
mkdir mtf/src
cd mtf
export GOPATH=`pwd`
go get github.com/MeasureTheFuture/scout
export PGPASSWORD="${pg_password}"
sudo -E -u postgres psql -v pass="'${mtf_database_pass}'" -f db-bootstrap.sql &> /dev/null

go get github.com/MeasureTheFuture/mothership
go get -u github.com/mattes/migrate
./bin/migrate -url postgres://mothership_user:"${mtf_database_pass}"@localhost:5432/mothership -path ./src/github.com/MeasureTheFuture/mothership/migrations up

cd /mtf/mtf/src/github.com/MeasureTheFuture/mothership/frontend
npm install
npm run build

