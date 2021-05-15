# Experimenting with Raspberry Pi4 and Project25

## Table of Contents

* [Experimenting with Raspberry Pi4 and Project25](#experimenting-with-raspberry-pi4-and-project25)
  * [Table of Contents](#table-of-contents)
  * [Get an RPi 4](#get-an-rpi-4)
  * [Install Raspberry Pi OS](#install-raspberry-pi-os)
  * [Configure the RPi 4](#configure-the-rpi-4)
    * [Locales](#locales)
    * [Wireless LAN](#wireless-lan)
    * [Update Password](#update-password)
    * [Network at Boot](#network-at-boot)
    * [Reboot the RPi4](#reboot-the-rpi4)
    * [Enable headless VNC desktop](#enable-headless-vnc-desktop)
    * [Update raspi\-config](#update-raspi-config)
    * [SSH](#ssh)
    * [VNC](#vnc)
    * [Update all packages](#update-all-packages)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc.go)

## Get an RPi 4
To make experimentation easier, I purchased a [Canakit Raspberry Pi 4 Starter Kit](https://www.canakit.com/raspberry-pi-4-starter-kit.html)
with 8GB RAM, 32 GB MicroSD card, heat sinks, fan, case, HDMI cable,
power supply, and MicroSD USB Reader.  I followed a simple [online tutorial](https://youtu.be/7rcNjgVgc-I)
to set all this up.

## Install Raspberry Pi OS
Get the latest Raspberry Pi operating system from  the [Raspberry Pi website](https://www.raspberrypi.org/software/operating-systems/).
For this project, I used the [latest Raspberry Pi OS Lite](https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-03-25/2021-03-04-raspios-buster-armhf-lite.zip) release.

After inserting the SD card into the Canakit included MicroSD USB
reader and then plugging that into my MacBook, I ran the following
commands on OSX:

    cd ~/Downloads
    unzip 2021-03-04-raspios-buster-armhf-lite.zip
    diskutil list

The 32 GB MicroSD card shows up as `/dev/disk2` but your mileage
may vary. Make sure to identify the correct device. Write the image
to the SD card using the following commands:

    diskutil unmountDisk /dev/disk2
    sudo dd if=2021-03-04-raspios-buster-armhf-lite.img of=/dev/rdisk2 bs=1m

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
`raspberry`. We'll change the password later.

Run the following command to configure the RPi:

    sudo raspi-config

### Locales
The Raspberry Pi Software Configuration Tool text interface will
be displayed. Let's start with `5 Localisation Options`. Select
that and hit `ENTER`. Next, select `L1 Locale` and hit `ENTER`.
You'll see a long list of locales in the `Configuring locales`
dialog.  Scroll through that and use the `SPACE` to only select the
locale(s) for your region. On my system, I de-selected `en_GB.UTF-8
UTF-8` and then selected `en_US.UTF-8 UTF-8` using `SPACE` for both.
When you're finished, `TAB` to `Ok` and press `ENTER`. Since you're
setting one locale for the RPi4, you'll be asked to confirm the
default language for the system. I selected `en_US.UTF-8` and then
`Ok` and `ENTER`.

At the main configuration screen, select `5 Localisation Options`
and then `L2 Timezone`. Scroll through to select your geographic
area and then `Ok` and `ENTER`. Next, scroll to select the timezone
for your geographic area followed by `Ok` and `ENTER`.

At the main configuration screen, select `5 Localisation Options`
and then `L3 Keyboard`. On my system, I selected `Generic 104-key
PC` then `Ok`. For keyboard layout on the next dialog, I chose
`English (US)` and then `Ok`. I then selected the defaults for the
next two dialogs. You'll need to tailor this to your specific
keyboard.

### Wireless LAN
At the main configuration screen, select `1 System Options` and
then `S1 Wireless LAN`. Scroll through to select your country and
then `Ok` and `ENTER`. I chose `US United States`. Confirm your
country by pressing `ENTER`. Next, enter the `SSID` for your wireless
network followed by the passphrase. After each, simply select `Ok`
and `ENTER`.

### Update Password
At the main configuration screen, select `1 System Options` and
then `S3 Password`. Provide a new password when prompted and hit
`ENTER` through the various confirmation dialogs to get back to the
main menu.

### Network at Boot
At the main configuration screen, select `1 System Options` and
then `S6 Network at Boot`. Choose `Yes` then `ENTER` to ensure the
network connection is available after boot up. Confirm the choice
to get back to the main menu.

### Reboot the RPi4
Let's reboot the RPi4 to make sure locales are fully updated before
adding packages for VNC later. Fully exit the configuration tool
and, if not prompted to reboot, type the following command at the
prompt:

    sudo reboot

### Enable headless VNC desktop
After the system has restarted, login with username `pi` and the
updated password and then issue the following command to install
packages that we'll need later for remote VNC access:

    sudo apt install lightdm lxsession

### Update raspi-config
Re-run the configuration tool using:

    sudo raspi-config

At the main configuration screen, select `8 Update`. The configuration
tool will automatically restart after pulling and installing necessary
updates.

### SSH
At the main configuration screen, select `3 Interface Options` and
then `P2 SSH`. Choose `Yes` then `ENTER` to enable the SSH server.
Confirm the choice to get back to the main menu.

### VNC
At the main configuration screen, select `3 Interface Options` and
then `P3 VNC`. Choose `Yes` then `ENTER` to enable the VNC server.
Reply `Y` to the prompt to install the packages. Confirm the choice
to get back to the main menu.

At the main configuration screen, select `2 Display Options` and
then `D1 Resolution`. Choose your desired resolution and then select
`Ok` and `ENTER`. Select `Ok` again to confirm and return to the
main menu.

At the main configuration screen, select `1 System Options` and
then `S5 Boot / Auto Login`. Choose `B4 Desktop Autologin` and then
`Ok` and `ENTER`.

Select `Finish` and `ENTER` to exit the configuration tool.

Type the following command to set the VNC password for the RPi:

    sudo vncpasswd -service

Provide a password when prompted. Next, create a custom config file
to set VNC authentication:

    echo "Authentication=VncAuth" | sudo tee /etc/vnc/config.d/common.custom

### Update all packages
Issue the following commands to fully update and upgrade all the
packages:

    sudo apt update
    sudo apt full-upgrade

When prompted, confirm the upgrade. When the upgrades complete,
issue the following command to determine the IP address of the
device:

    ip route get 8.8.8.8 | awk '{print $7}'

To poweroff, issue the command:

    sudo poweroff

When the RPi4 is shutdown, disconnect the keyboard and monitor.
From this point on, we'll be using SSH and VNC to work with the
RPi4.

