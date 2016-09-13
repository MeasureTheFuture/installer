#!/bin/bash

delete_packages=(
	tinyb-dev
	tinyb
	openjdk-8-jdk
	openjdk-8-jre
	openjdk-8-java
	openjdk-8-common
	upm-dev
	upm
	mraa-doc
	mraa-dev
	wyliodrin-server
	iotivity-sensorboard
	mraa
	iotivity-dev
	iotiviy
	iotivity-plugins-samples
	iotivity-plugins-staticdev
	iotivity-resource-dev
	iotivity-resource-samples
	iotivity-resource-thin-staticdev
	iotivity-tests
	iotivity-service-samples
	iotivity-service
	iotivity-simple-client
	iotivity-resource
	iotivity-service-dev
	iotivity-service-staticdev
	oobe
	flex-dev
	flex
	cppzmq-dev
	zeromq-dev
	iotkit-comm-c-dev
	iotkit-comm-c
	iotkit-comm-js
	zeromq
	iotkit-agent
	iotkit-opkg
)

openCV_packages=(
	http://reprage.com/ipkgs/libv4l-dev_1.10.1_x86.ipk
	http://reprage.com/ipkgs/opencv_3.1.0_x86.ipk
	http://reprage.com/ipkgs/cvbindings_3.1.0_x86.ipk
)

# Download the other parts to the installer
echo ""
echo -ne "Downloading installer... "
wget https://raw.githubusercontent.com/MeasureTheFuture/installer/master/db-bootstrap.sql &> /dev/null
wget https://raw.githubusercontent.com/MeasureTheFuture/installer/master/postgresql.service &> /dev/null
wget https://raw.githubusercontent.com/MeasureTheFuture/installer/master/mtf-mothership.service &> /dev/null
echo -ne "Done\n"

# Remove unused packages and tidy up a bit of space
echo -ne "Cleaning up space"
for pkg in "${delete_packages[@]}"
do
	opkg remove "${pkg}" &> /dev/null
	echo -ne "."
done
echo -ne " Done\n"

# Install OpenCV
echo -ne "Installing OpenCV"
for pkg in "${openCV_packages[@]}"
do
	opkg install "${pkg}" &> /dev/null
	echo -ne "."
done
echo -ne " Done\n"

# Configure the postgreSQL database.
echo -ne "Installing postgreSQL... "
opkg install http://reprage.com/ipkgs/postgres_9.5.3_x86.ipk &> /dev/null
echo "PATH=$PATH:/usr/local/pgsql/bin/" >> /etc/profile
echo "export PATH" >> /etc/profile

echo "LD_LIBRARY_PATH=/usr/local/lib" >> /etc/profile
echo "export LD_LIBRARY_PATH" >> /etc/profile

source /etc/profile
useradd --system --no-create-home postgres
chown -R postgres:postgres /usr/local/pgsql
echo -ne " Done\n"

echo -ne "Configuring postgreSQL... \n"
read -s -p "Create a password for the postgreSQL administrator: " pg_password
echo -ne "\n"
read -s -p "Create a different password for the MTF database: " mtf_database_pass
echo -ne "\n"

echo "${pg_password}" >> post_pass
sudo -u postgres initdb -D /usr/local/pgsql/data -A md5 --pwfile=post_pass &> /dev/null
rm post_pass

# Configure SSL key for the postgreSQL database.
cd /usr/local/pgsql/data
openssl req -new -newkey rsa:2048 -nodes -x509 -subj "/C=AU/ST=Queensland/L=Cairns/O=MTF/CN=www.measurethefuture.net" -keyout server.key -out server.crt &> /dev/null
chmod og-rwx server.key
echo "ssl = on" >> /usr/local/pgsql/data/postgresql.conf
cd ~/
chown -R postgres:postgres /usr/local/pgsql

# Start up postgreSQL and bootstrap the database.
cp postgresql.service /lib/systemd/system
systemctl daemon-reload &> /dev/null
systemctl start postgresql.service &> /dev/null
systemctl enable postgresql.service &> /dev/null

sleep 10
export PGPASSWORD="${pg_password}"
sudo -E -u postgres psql -v pass="'${mtf_database_pass}'" -f db-bootstrap.sql &> /dev/null
echo -ne "Configuring postgreSQL... Done\n"

# Install MTF.
echo -ne "Installing MTF..."
opkg install http://reprage.com/ipkgs/mtf_0.0.7_x86.ipk &> /dev/null
echo -ne " Done\n"

# Migrate database to the latest version.
echo -ne "Initalising Database..."
cd ~/mtf-build/
./migrate -url postgres://mothership_user:"${mtf_database_pass}"@localhost:5432/mothership -path ./migrations up &> /dev/null
sed -i -e "s/password/${mtf_database_pass}/g" ~/mtf-build/mothership.json
echo -ne " Done\n"

# Spin up the mothership.
echo -ne "Starting Measure the Future..."
cd ~/
cp mtf-mothership.service /lib/systemd/system
systemctl daemon-reload &> /dev/null
systemctl start mtf-mothership.service &> /dev/null
systemctl enable mtf-mothership.service &> /dev/null
echo -ne " Done\n"

# Switch the Edison into Access point mode.
echo -ne "Opening access point..."
systemctl stop wpa_supplicant &> /dev/null
systemctl start hostapd &> /dev/null
systemctl disable wpa_supplicant &> /dev/null
systemctl enable hostapd &> /dev/null
echo -ne " Done\n"

echo -ne "*******************\n"
echo -ne "INSTALL SUCCESSFUL!\n"
echo -ne "*******************\n"