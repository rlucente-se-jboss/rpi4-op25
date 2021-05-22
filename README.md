Table of Contents
=================

* [Experimenting with Raspberry Pi4 and Project25](#experimenting-with-raspberry-pi4-and-project25)
  * [Get an RPi 4](#get-an-rpi-4)
  * [Install Raspberry Pi OS](#install-raspberry-pi-os)
  * [Configure the RPi 4](#configure-the-rpi-4)
  * [Set SSH and VNC](#set-ssh-and-vnc)
  * [Determine the Project 25 Primary Control Frequency](#determine-the-project-25-primary-control-frequency)
  * [Connect the RTL\-SDR USB receiver](#connect-the-rtl-sdr-usb-receiver)
  * [Confirm the control channel frequency for Project25](#confirm-the-control-channel-frequency-for-project25)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc.go)

# Experimenting with Raspberry Pi4 and Project25

## Get an RPi 4
To make experimentation easier, I purchased a [Canakit Raspberry Pi 4 Starter Kit](https://www.canakit.com/raspberry-pi-4-starter-kit.html)
with 8GB RAM, 32 GB MicroSD card, heat sinks, fan, case, HDMI cable,
power supply, and MicroSD USB Reader.  I followed a simple [online tutorial](https://youtu.be/7rcNjgVgc-I)
to set all this up.

## Install Raspberry Pi OS
Get the latest Raspberry Pi operating system from  the [Raspberry Pi website](https://www.raspberrypi.org/software/operating-systems/).
For this project, I used the [latest Raspberry Pi OS with desktop](https://downloads.raspberrypi.org/raspios_armhf/images/raspios_armhf-2021-03-25/2021-03-04-raspios-buster-armhf.zip)
release.

After inserting the SD card into the Canakit included MicroSD USB
reader and then plugging that into my MacBook, I ran the following
commands on OSX:

    cd ~/Downloads
    unzip -q 2021-03-04-raspios-buster-armhf.zip
    diskutil list

The 32 GB MicroSD card appears on my system as `/dev/disk2` but
your mileage may vary. Make sure to identify the correct device.
Write the image to the SD card using the following commands:

    diskutil unmountDisk /dev/disk2
    sudo dd if=2021-03-04-raspios-buster-armhf.img of=/dev/rdisk2 bs=1m

Notice the `/dev/rdisk2` vs `/dev/disk2` which can significantly
speed up writes on OSX. From `man hdiutil` on OSX,

> /dev/rdisk nodes are character-special devices, but are "raw" in
> the BSD sense and force block-aligned I/O. They are closer to the
> physical disk than the buffer cache. /dev/disk nodes, on the other
> hand, are buffered block-special devices and are used primarily by
> the kernel's filesystem code.

When the command completes, eject the SD Card:

    diskutil eject /dev/disk2

Plug the SD Card into the Raspberry Pi 4, connect a USB keyboard,
mouse, and an HDMI monitor, and power the device.

## Configure the RPi 4
Once the device boots up, you'll see a `Welcome to Raspberry Pi`
dialog. Simply click `Next`.

Set your country, language, and timezone. I also checked the box
`Use US keyboard`. Click `Next`.

Enter a password for user `pi` and then click `Next`.

Check the box if your screen has a black border around it. Click
`Next`.

Select your WiFi network from the list and click `Next` to connect.
Enter the password for the WiFi network if prompted and click `Next`.

Click `Next` to update the software. Click `OK` when notified the
system is up to date.

Select `Restart` to reboot the RPi 4 with the new settings.

## Set SSH and VNC
After the system restarts, click on the `Raspberry Pi` icon for the
main menu and then select `Preferences -> Raspberry Pi Configuration`.

The `Raspberry Pi Configuration` dialog will appear. On the `System`
tab, select `Network at Boot: Wait for network`.

On the `Interfaces` tab, enable both `SSH` and `VNC`. Click `OK`.

Click the terminal icon on the top bar and then type the following
command to set the VNC password for the RPi:

    sudo vncpasswd -service

Provide a password when prompted. Next, create a custom config file
to set VNC authentication by typing the commands:

    echo "Authentication=VncAuth" | sudo tee /etc/vnc/config.d/common.custom

Set the screen resolution when no monitor is connected. Run the
following command:

    sudo raspi-config

Select `2 Display Options` and then `D1 Resolution`. Select a desired
screen resolution that will be in effect for VNC and then select
`Ok`. Select `Ok` again to confirm and then `Finish` to close the
app. When asked to reboot, click `No`.

Issue the following command to determine the IP address of the
device:

    ip route get 8.8.8.8 | awk '{print $7}'

To poweroff, issue the command:

    sudo poweroff

When the RPi4 is shutdown, disconnect the keyboard, mouse, and
monitor. Also, disconnect the power cable to power down the device.
From this point on, we'll be using SSH and VNC to work with the
RPi4.

## Determine the Project 25 Primary Control Frequency
Browse to [Radio Reference](https://www.radioreference.com) and
click on `Reference Database`. Select your state and county on the
map and then select the same county under `County Quick Jumps`.
Click the link for the `Project 25 Phase I` link. Scroll down to
`System Frequencies` and then look for the number in red with a `c`
following it. This is the P25 primary control channel frequency in
MHz.

## Connect the RTL-SDR USB receiver
TODO talk about antenna and receiver here

TODO Power on the RPi 4 with only the USB software-defined radio connected.

## Confirm the control channel frequency for Project25
First, use a VNC client to connect to the RPi 4. On OSX, open
`Finder` and then select `Go -> Connect to Server ...`. On the
dialog, enter `vnc://192.168.1.17`, making sure to change the IP
address to match the IP address for your RPi 4. Enter the VNC
password when prompted and select `Sign in`. The Desktop will appear
for the RPi 4.

After logging, select the Raspberry icon followed by `Preferences
-> Add / Remove Software`. Enter `gqrx` in the search text field.
When the results appear, select `Software defined radio receiver`
then `OK`. Enter the password when prompted.

After the application is installed, launch it by selecting the
Raspberry icon and then `Internet -> gqrx`.

The application will start in a few seconds. When the `Configure
I/O Devices` dialog appears, select `Realtek RTL2838UHIDIR SN:00000001`
in the `Device` pull-down. Click `OK` to launch the application.

Enter the Project 25 primary control channel frequency (in kHz) in
the `Frequency` text box and then click the save icon. Next, select
`File -> Start DSP` to see the waterfall display. There should be
a bright yellow line matching your control channel frequency. You
can stop the waterfall display by selecting `File -> Stop DSP`.
Exit the `gqrx` application.

