# Installer

This installer configures the Measure the Future project on a Raspberry Pi 3 Model B. It installs both scout and mothership components.

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
