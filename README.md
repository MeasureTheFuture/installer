# Installer

This installer configures the Measure the Future project on an Intel Edison. It installs both scout and mothership components.

![alpha](https://img.shields.io/badge/stability-alpha-orange.svg?style=flat "Alpha")&nbsp;
 ![GPLv3 License](https://img.shields.io/badge/license-GPLv3-blue.svg?style=flat "GPLv3 License")

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
* Along the way you will get prompted to generate passwords and what not.
* Move into the mtf-build directory and start the scout up.
```
	# cd mtf-build/
	# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
	# ./scout &
```

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

## Notes:
OpenCV has been currently complied on the Intel Edison with:
```
	cmake -D WITH_IPP=OFF -D WITH_TBB=OFF -D BUILD_TBB=OFF -D WITH_CUDA=OFF -D WITH_OPENCL=OFF -D BUILD_SHARED_LIBS=ON -D BUILD_PERF_TESTS=OFF -D BUILD_TESTS=OFF -D WITH_V4L=ON -D WITH_LIBV4L=ON .
```

## TODO:
- [ ] Automatically spin up the scout on boot.
- [ ] Add instructions with what to do next after install is completed.
- [ ] mothership should start as www-data.
- [x] Automatically spin up postgres on boot.
- [x] Automatically spin up the mothership on boot.
- [x] Prompt the user for a Posgres/DB password.
- [x] Prompt the user for a wifi access point password.

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
