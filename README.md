# Installer

This installer configures the Measure the Future project on an Intel Edison. It installs both scout and mothership components.

![alpha](https://img.shields.io/badge/stability-alpha-orange.svg?style=flat "Alpha")&nbsp;
 ![GPLv3 License](https://img.shields.io/badge/license-GPLv3-blue.svg?style=flat "GPLv3 License")

## Regular Installation (Raspberry Pi)

* Install Raspbian

Download [Raspbian Jessie (2016-11-25)](https://www.raspberrypi.org/downloads/raspbian/) and follow the installation instructions for [installing images](https://www.raspberrypi.org/documentation/installation/installing-images/).

* Enable SSH

Place a file named 'ssh', without any extension, onto the boot partition of the SD card.

* Configure the Raspberry Pi
```
	$ sudo raspi-config
```
* Update the Raspberry Pi
```
	$ sudo apt-get update
	$ sudo apt-get -y upgrade
```
* Download and run the mtf-pi-install script.
```
	$ wget https://raw.githubusercontent.com/MeasureTheFuture/installer/master/mtf-pi-install.sh
	$ chmod +x mtf-pi-install.sh
	$ sudo ./mtf-pi-install.sh
```

## Regular Installation (Edison)

* [Download the latest Edison Installer from Intel](https://software.intel.com/en-us/iot/hardware/edison/downloads)
* Update your Edison to the latest firmware version (3.5 at the time of writing).
* Open up a terminal and run 'screen' to access your Edison (the xxx part will differ for your board)
```
	$ screen -L /dev/cu.usbserial-XXXXXXXX 115200 –L
```
* Use 'root' for the login.
* Configure the Intel Edison to connect to the Internet over a wifi network.
```
	# configure_edison --setup
```
* Download and run the mtf-install script.
```
	# wget https://raw.githubusercontent.com/MeasureTheFuture/installer/master/mtf-install.sh
	# chmod +x mtf-install.sh
	# ./mtf-install.sh
```
* Along the way you will be prompted to create passwords for different components.
* When completed, the Edison will be running as a self-contained wireless access point:
    * The network is the same as the *Device Name* you supplied to configure_edison
    * The password is the same as the *Device Password* you supplied to configure_edison
	* Visit *http://192.168.42.1* in your web browser to measure the future

## Developer Installation (Edison)

* [Download the latest Edison Installer from Intel](https://software.intel.com/en-us/iot/hardware/edison/downloads)
* Update your Edison to the latest firmware version (3.5 at the time of writing).
* Open up a terminal and run 'screen' to access your Edison (the xxx part will differ for your board)
```
	$ screen -L /dev/cu.usbserial-XXXXXXXX 115200 –L
```
* Use 'root' for the login.
* Configure the Intel Edison to connect to the Internet over a wifi network.
```
	# configure_edison --setup
```
* Download and run the mtf-install-dev script.
```
	# wget https://raw.githubusercontent.com/MeasureTheFuture/installer/master/mtf-install-dev.sh
	# chmod +x mtf-install-dev.sh
	# ./mtf-install-dev.sh
```

## Developer Notes:
OpenCV has been currently complied on the Intel Edison with:
```
	cmake -D WITH_IPP=OFF -D WITH_TBB=OFF -D BUILD_TBB=OFF -D WITH_CUDA=OFF -D WITH_OPENCL=OFF -D BUILD_SHARED_LIBS=ON -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D WITH_V4L=ON -D WITH_LIBV4L=ON .
```

## License

Copyright (C) 2016, Clinton Freeman

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
