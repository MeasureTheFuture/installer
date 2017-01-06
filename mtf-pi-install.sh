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
wget http://reprage.com/debs/mtf_0.0.16_armhf.deb &> /dev/null
sudo dpkg -i mtf_0.0.16_armhf.deb &> /dev/null

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
echo -ne "Starting Measure the Future..."
sudo wget https://raw.githubusercontent.com/MeasureTheFuture/installer/master/mtf-pi-mothership.service -P /lib/systemd/system &> /dev/null
sudo wget https://raw.githubusercontent.com/MeasureTheFuture/installer/master/mtf-pi-scout.service -P /lib/systemd/system &> /dev/null
sudo systemctl daemon-reload &> /dev/null
sudo systemctl start mtf-pi-mothership.service &> /dev/null
sudo systemctl enable mtf-pi-mothership.service &> /dev/null
sudo systemctl start mtf-pi-scout.service &> /dev/null
sudo systemctl enable mtf-pi-scout.service &> /dev/null
echo -ne " Done\n"

# Switch the Raspberry Pi into Access point mode.
echo -ne "Opening wireless access point... \n"
read -s -p "Create a wifi password (must be 8 to 63 characters): " APPASS
echo -ne "\n"
read -s -p "Create a name for the wifi network: "  APSSID
sudo apt-get -f install -y hostapd dnsmasq &> /dev/null
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
hw_mode=g
channel=10
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP
rsn_pairwise=CCMP
wpa_passphrase=$APPASS
ssid=$APSSID
EOF

sudo sed -i -- 's/allow-hotplug wlan0//g' /etc/network/interfaces
sudo sed -i -- 's/iface wlan0 inet manual//g' /etc/network/interfaces
sudo sed -i -- 's/    wpa-conf \/etc\/wpa_supplicant\/wpa_supplicant.conf//g' /etc/network/interfaces

sudo cat >> /etc/network/interfaces <<EOF
	wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
# Added by rPi Access Point Setup
allow-hotplug wlan0
iface wlan0 inet static
	address 10.0.0.1
	netmask 255.255.255.0
	network 10.0.0.0
	broadcast 10.0.0.255
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
