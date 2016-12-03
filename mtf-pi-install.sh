#!/bin/bash

# Tidy up the Raspbian installation.
echo -ne "Preparing Raspbian... "
sudo apt-get -y purge --auto-remove gvfs-backends gvfs-fuse &> /dev/null
sudo apt-get -y install vim &> /dev/null
echo -ne " Done\n"

# Install OpenCV.
echo -ne "Installing OpenCV... "
sudo apt-get -y install build-essential git cmake pkg-config &> /dev/null
sudo apt-get -y install libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev &> /dev/null
sudo apt-get -y install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev &> /dev/null
sudo apt-get -y install libxvidcore-dev libx264-dev &> /dev/null
sudo apt-get -y install libatlas-base-dev gfortran &> /dev/null
wget http://reprage.com/debs/cvbindings_3.1.0_armhf.deb &> /dev/null
sudo dpkg -i cvbindings_3.1.0_armhf.deb &> /dev/null

wget http://reprage.com/debs/opencv_3.1.0_armhf.deb &> /dev/null
sudo dpkg -i opencv_3.1.0_armhf.deb &> /dev/null
echo -ne " Done\n"

# Install Measure The Future
echo -ne "Installing Measure The Future... "
wget http://reprage.com/debs/mtf_0.0.13_armhf.deb &> /dev/null
sudo dpkg -i mtf_0.0.13_armhf.deb &> /dev/null

echo 'export PATH=$PATH:/usr/local/mtf/bin' >> .profile
source .profile
echo -ne " Done\n"

# Bootstrap the Database.
echo -ne "Installing postgreSQL... \n"
sudo apt-get -y install postgresql-9.4 &> /dev/null
read -s -p "Create a password for the MTF database: " mtf_database_pass
echo -ne "Configuring postgreSQL... \n"
sudo sed -i -e "s/password/${mtf_database_pass}/g" /usr/local/mtf/bin/mothership.json

wget https://raw.githubusercontent.com/MeasureTheFuture/installer/master/db-bootstrap.sql &> /dev/null
sudo -E -u postgres psql -v pass="'${mtf_database_pass}'" -f db-bootstrap.sql &> /dev/null
migrate -url postgres://mothership_user:"${mtf_database_pass}"@localhost:5432/mothership -path /usr/local/mtf/bin/migrations up &> /dev/null
echo -ne " Done\n"

# Spin up the mothership and scout.
# echo -ne "Starting Measure the Future..."
# cd ~/
# cp mtf-mothership.service /lib/systemd/system
# cp mtf-scout.service /lib/systemd/system
# systemctl daemon-reload &> /dev/null
# systemctl start mtf-mothership.service &> /dev/null
# systemctl enable mtf-mothership.service &> /dev/null
# systemctl start mtf-scout.service &> /dev/null
# systemctl enable mtf-scout.service &> /dev/null
# echo -ne " Done\n"

# Switch the Raspberry Pi into Access point mode.
# echo -ne "Opening access point..."
# systemctl stop wpa_supplicant &> /dev/null
# systemctl start hostapd &> /dev/null
# systemctl disable wpa_supplicant &> /dev/null
# systemctl enable hostapd &> /dev/null
# echo -ne " Done\n"

echo -ne "*******************\n"
echo -ne "INSTALL SUCCESSFUL!\n"
echo -ne "*******************\n\n"
# echo -ne "This unit is running as a self-contained wireless access point:\n\n"
# echo -ne "\t* The network is the same as the 'Device Name' you supplied to configure_edison\n"
# echo -ne "\t* The password is the same as the 'Device Password' you supplied to configure_edison\n"
# echo -ne "\t* Visit http://192.168.42.1 in your web browser to measure the future\n\n"