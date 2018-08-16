#!/bin/bash

# Tidy up the Raspbian installation.
echo -ne "Preparing Raspbian... "
sudo apt-get -y purge --auto-remove gvfs-backends gvfs-fuse &> /dev/null
sudo apt-get -y install vim &> /dev/null
sudo iplink set wlan0 up
echo -ne " Done\n"

# Install OpenCV Dependencies
echo -ne "Installing OpenCV Dependencies... "
sudo apt-get -y install build-essential git cmake pkg-config &> /dev/null
sudo apt-get -y install libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev &> /dev/null
sudo apt-get -y install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev &> /dev/null
sudo apt-get -y install libxvidcore-dev libx264-dev &> /dev/null
sudo apt-get -y install libatlas-base-dev gfortran &> /dev/null
sudo apt-get -y install libgtk2.0-dev
sudo apt-get -y install python2.7-dev python3-dev
sudo apt-get -y install -f
sudo apt-get -y install hostapd
sudo mkdir /etc/hostapd
sudo touch /etc/hostapd/hostapd.conf
#Install OpenCV and OpenCV_Contrib from Official Git Repository
echo -ne "Installing OpenCV from Official Git Repository"
git clone https://github.com/opencv/opencv_contrib.git
git clone https://github.com/opencv/opencv.git
pip install numpy
cd opencv
mkdir build
cd build
#Check build
echo -ne "Checking enviornment and generating make file headers, this might take a minute or two"
cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
    -D BUILD_EXAMPLES=ON ..

#Generate make file
echo -ne "Generating make file, this will take at least an hour, grab a coffee and take a deep breath"
make -j4
#Install package 
echo -ne "Installing package"
sudo make install
sudo ldconfig
echo -ne "Symlinking package for import"
ln -s /usr/local/lib/python2.7/dist-packages/cv2.so cv2.so

echo -ne "Begin Measure The Future Installation instructions"
wget https://github.com/MeasureTheFuture/CVBindings/releases/download/3.4.1/cvbindings_3.4.1_armhf.deb &> /dev/null
sudo dpkg -i cvbindings_3.4.1_armhf.deb &> /dev/null

wget https://github.com/MeasureTheFuture/Pi-OpenCV/releases/download/3.4.1/opencv_3.4.1_armhf.deb &> /dev/null
sudo dpkg -i opencv_3.4.1_armhf.deb &> /dev/null
echo -ne " Done\n"

# Install Measure The Future
echo -ne "Installing Measure The Future... "
wget https://github.com/MeasureTheFuture/scout/releases/download/v0.0.24/mtf_0.0.24_armhf.deb &> /dev/null
sudo dpkg -i mtf_0.0.24_armhf.deb &> /dev/null

echo 'export PATH=$PATH:/usr/local/mtf/bin' >> .profile
source .profile
echo -ne " Done\n"

# Bootstrap the Database.
echo -ne "Installing postgreSQL... \n"
sudo apt-get -y install postgresql &> /dev/null
read -s -p "Create a password for the MTF database: " mtf_database_pass
echo -ne "Configuring postgreSQL... \n"
sudo sed -i -e "s/password/${mtf_database_pass}/g" /usr/local/mtf/bin/scout.json

sudo cat > /home/pi/db-bootstrap.sql <<EOF
CREATE DATABASE mothership;
CREATE DATABASE mothership_test;
CREATE USER mothership_user WITH password :pass;
ALTER ROLE mothership_user SET client_encoding TO 'utf8';
ALTER ROLE mothership_user SET default_transaction_isolation TO 'read committed';
ALTER ROLE mothership_user SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE mothership to mothership_user;
GRANT ALL PRIVILEGES ON DATABASE mothership_test TO mothership_user;
\connect mothership;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

EOF

sudo -E -u postgres psql -v pass="'${mtf_database_pass}'" -f db-bootstrap.sql &> /dev/null
migrate -database postgres://mothership_user:"${mtf_database_pass}"@localhost:5432/mothership -path /usr/local/mtf/bin/migrations up &> /dev/null
echo -ne " Done\n"

# Spin up the mothership and scout.
echo -ne "Starting Measure the Future..."
sudo cat > /lib/systemd/system/mtf-pi-scout.service <<EOF
[Unit]
Description=The Measure the Future scout
After=postgresql.service

[Service]
Environment=LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
WorkingDirectory=/usr/local/mtf/bin
ExecStart=/usr/local/mtf/bin/scout

[Install]
WantedBy=multi-user.target

EOF

sudo systemctl daemon-reload &> /dev/null
sudo systemctl start mtf-pi-scout.service &> /dev/null
sudo systemctl enable mtf-pi-scout.service &> /dev/null
echo -ne " Done\n"

# Switch the Raspberry Pi into Access point mode.
echo -ne "Opening wireless access point... \n"
passlen=0
while [ "$passlen" -lt "8" ]
do
	read -s -p "Create a wifi password: " APPASS
	passlen=${#APPASS}

	if [ "$passlen" -lt "8" ]
	then
		echo "must be 8 to 63 characters long."
	fi
done

echo -ne "\n"
read -s -p "Create a name for the wifi network: "  APSSID
sudo apt-get -f install -y hostapd dnsmasq &> /dev/null
sudo cat >> /etc/dhcpcd.conf <<EOF
interface wlan0
	static ip_address=10.0.0.1/24
EOF

sudo cat >> /etc/default/hostapd <<EOF
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF

sudo cat > /lib/systemd/system/hostapd.service <<EOF
[Unit]
Description=Hostapd IEEE 802.11 Access Point
After=sys-subsystem-net-devices-wlan0.device
BindsTo=sys-subsystem-net-devices-wlan0.device

[Service]
Type=forking
PIDFile=/var/run/hostapd.pid
ExecStart=/usr/sbin/hostapd -B /etc/hostapd/hostapd.conf -P /var/run/hostapd.pid

[Install]
WantedBy=multi-user.target

EOF

sudo cat > /etc/dnsmasq.conf <<EOF
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.5,255.255.255.0,12h
EOF

sudo cat > /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
driver=nl80211
hw_mode=g
channel=10
wmm_enabled=0
macaddr_acl=0
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
wpa_passphrase=$APPASS
ssid=$APSSID
EOF

sudo sed -i -- 's/allow-hotplug wlan0//g' /etc/network/interfaces
sudo sed -i -- 's/iface wlan0 inet manual//g' /etc/network/interfaces
sudo sed -i -- 's/    wpa-conf \/etc\/wpa_supplicant\/wpa_supplicant.conf//g' /etc/network/interfaces

sudo cat >> /etc/network/interfaces <<EOF
	wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
EOF

sudo systemctl daemon-reload &> /dev/null
sudo systemctl start hostapd &> /dev/null
sudo systemctl enable hostapd &> /dev/null

echo -ne " Done\n"

echo -ne "*******************\n"
echo -ne "INSTALL SUCCESSFUL!\n"
echo -ne "*******************\n\n"
echo -ne "Please reboot.\n This unit will run as a self-contained wireless access point:\n\n"
echo -ne "\t* The network name is '${APSSID}'\n"
echo -ne "\t* The password is '${APPASS}'\n"
echo -ne "\t* Visit http://10.0.0.1 in your web browser to measure the future\n\n"
