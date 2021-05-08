# Raspberry Pi4 Project25 Experiment

## Get an RPi 4
To make experimentation easier, I purchased a [Canakit Raspberry Pi 4 Starter Kit](https://www.canakit.com/raspberry-pi-4-starter-kit.html)
with 8GB RAM, 32 GB MicroSD card, heat sinks, fan, case, HDMI cable,
power supply, and MicroSD USB Reader.  I followed a simple [online
tutorial](https://youtu.be/7rcNjgVgc-I) to set all this up.

## Install RPi 4
Get the latest Raspberry Pi operating system from  the [Raspberry Pi website](https://www.raspberrypi.org/software/operating-systems/).
For this project, I used the [latest Raspberry Pi OS Lite](https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-03-25/2021-03-04-raspios-buster-armhf-lite.zip) release.

Determine the device matching your SD card. After inserting the SD
card into the Canakit included MicroSD USB reader and then plugging
that into my MacBook, I ran the following commands on  OSX:

    cd ~/Downloads
    unzip 2021-03-04-raspios-buster-armhf-lite.zip
    diskutil list

The 32 GB MicroSD card shows up as `/dev/disk2` but your mileage
may vary. Make sure to identify the correct device. Write the image
to the SD card:

    diskutil unmountDisk /dev/disk2
    sudo dd if=2021-03-04-raspios-buster-armhf-lite.zip of=/dev/rdisk2 bs=1m

Notice the `/dev/rdisk2` vs `/dev/disk2` which can significantly
speed up writes on OSX. From `man hdiutil` on OSX,

> /dev/rdisk nodes are character-special devices, but are "raw" in
> the BSD sense and force block-aligned I/O. They are closer to the
> physical disk than the buffer cache. /dev/disk nodes, on the other
> hand, are buffered block-special devices and are used primarily by
> the kernel's filesystem code.

When the command completes, eject the SD Card:

    diskutil eject /dev/disk2

Plug the SD Card into the Raspberry Pi 4, connect a USB keyboard
and an HDMI monitor, and power the device.

## Configure the RPi 4
Once the device boots up and everything is correctly connected, a
login prompt will appear. Log in with username `pi` and password
`raspberry`. We'll most certainly change those credentials later.

