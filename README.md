
Table of Contents
=================

* [Experimenting with Raspberry Pi4 and Project25](#experimenting-with-raspberry-pi4-and-project25)
  * [Overview](#overview)
  * [Get an RPi 4](#get-an-rpi-4)
  * [Install Raspberry Pi OS](#install-raspberry-pi-os)
  * [Configure the RPi 4](#configure-the-rpi-4)
  * [Set SSH and VNC](#set-ssh-and-vnc)
  * [Install the GNU Software Defined Radio Receiver](#install-the-gnu-software-defined-radio-receiver)
  * [Connect the RTL\-SDR USB receiver](#connect-the-rtl-sdr-usb-receiver)
  * [Confirm the RTL\-SDR USB device is recognized](#confirm-the-rtl-sdr-usb-device-is-recognized)
  * [Determine the Project 25 Parameters](#determine-the-project-25-parameters)
  * [Confirm the control channel frequency for Project25](#confirm-the-control-channel-frequency-for-project25)
  * [Install LibreOffice (if not already present)](#install-libreoffice-if-not-already-present)
  * [Install the OP25 software](#install-the-op25-software)
  * [Configure OP25 trunk file and talkgroups](#configure-op25-trunk-file-and-talkgroups)
  * [Configure Liquidsoap with Icecast](#configure-liquidsoap-with-icecast)
  * [Install the Icecast server](#install-the-icecast-server)
  * [Run the server](#run-the-server)
  * [Archive the streams](#archive-the-streams)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc.go)

# Experimenting with Raspberry Pi4 and Project25

## Overview
Build a public safety radio scanner for under $100 using the Raspberry
Pi 4! This project walks though how to set up the hardware and
software on the RPi 4 to decode Project 25 radio traffic and stream
to an icecast server. The icecast server, running on a separate
Linux system provides client access to the stream and archives the
streams using systemd timers/services. You can use VLC on a laptop
or phone to connect over WiFi to the Icecast server and listen live
to public safety radio traffic.

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

When the RPi 4 is shutdown, disconnect the keyboard, mouse, and
monitor. Also, disconnect the power cable to power down the device.
From this point on, we'll be using SSH and VNC to work with the
RPi 4.

## Install the GNU Software Defined Radio Receiver
Power up the RPi 4. At this point there is nothing connected to the
device except for power.  Use a VNC client to connect to the RPi
4. On OSX, open `Finder` and then select `Go -> Connect to Server
...`. On the dialog, enter `vnc://192.168.1.17`, making sure to
change the IP address to match the IP address for your RPi 4. Enter
the VNC password when prompted and select `Sign in`. The Desktop
will appear for the RPi 4.

After logging in, select the Raspberry icon followed by `Preferences
-> Add / Remove Software`. Enter `gqrx` in the search text field.
When the results appear, select `Software defined radio receiver`
then `OK`. Enter the password when prompted.

Once the software is installed, power down the device using:

    sudo poweroff

## Connect the RTL-SDR USB receiver
Setup is very straightforward. You simply plug the USB RTL-SDR
dongle into the RPi 4 and then you connect the antenna to the coax
connector on the dongle. For the dipole antenna setup, I followed
the [dipole antenna guide](https://www.rtl-sdr.com/using-our-new-dipole-antenna-kit/).

That guide suggests a certain configuration for the antenna. I
mounted the smaller dipole telescopic antennas vertically on the
tripod mount. Connect the coax cable to both the antenna and the
USB dongle.

Power on the RPi 4.

## Confirm the RTL-SDR USB device is recognized
Sometimes when I boot my RPi 4, the RTL-SDR receiver does not appear
to be enabled. You can confirm that the USB radio receiver is
recognized by opening a terminal window and typing the following
command:

    lsusb

The output should resemble the following:

    Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
    Bus 001 Device 003: ID 0bda:2838 Realtek Semiconductor Corp. RTL2838 DVB-T
    Bus 001 Device 002: ID 2109:3431 VIA Labs, Inc. Hub
    Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

If the `Realtek` device does not appear in that list, poweroff the
RPi 4 using `sudo poweroff`, disconnect the power cable, reinsert
the device, and then try again.

## Determine the Project 25 Parameters
Browse to [Radio Reference](https://www.radioreference.com) and
click on `Reference Database`. Select your state and county on the
map and then select the same county under `County Quick Jumps`.
Click the link for the `Project 25 Phase I` link as shown below.

![P25 Example](/images/radio-ref-example.png)

There are several parameters you will need from this page which are
listed in the following table.

| Parameter | Description |
| --- | --- |
| Network Access Code | Three digit hexadecimal code that prefixes every packet sent (including voice packets). The radio breaks squelch when this code is received. |
| Primary Control Channel | The Project25 control channel frequency in MHz that carries instructions and status messages between the controller and the radios |
| Talkgroup | An identifier in both decimal (DEC) and hexadecimal (HEX) that is assigned dynamically to a send/receive frequency pair from a reusable pool |

Scroll down to `System ID List`. The `System ID` three digit
hexadecimal value corresponds to the Network Access Code (NAC).

Scroll down to `System Frequencies` and then look for the first
number in red with a `c` following it. This is the P25 primary
control channel frequency in MHz.

Scroll down to `System Talkgroups`. The value in the first column
is the decimal value for the talkgroup. Note the talkgroups that
you're interested in but be aware that talkgroups with an `E` in
the `Mode` column are encrypted and you will not be able to listen
to them.

Note the NAC, primary control channel frequency, and the desired
talkgroups. This information will be used later to configure the
Op25 software.

## Confirm the control channel frequency for Project25
With your properly connected and recognized software-defined radio
receiver, launch the radio receiver application by selecting the
Raspberry icon and then `Internet -> gqrx`.

The application will start in a few seconds. When the `Configure
I/O Devices` dialog appears, select `Realtek RTL2838UHIDIR SN:00000001`
in the `Device` pull-down. Click `OK` to launch the application.

Enter the Project 25 primary control channel frequency (in kHz) in
the `Frequency` text box and then click the save icon. Next, select
`File -> Start DSP` to see the waterfall display. There should be
a bright yellow line matching your control channel frequency as
shown in the image.

![Gqrx Waterfall](/images/gqrx-waterfall.png)

You can stop the waterfall display by selecting
`File -> Stop DSP`.  Exit the `gqrx` application.

## Install LibreOffice (if not already present)
Install the LibreOffice application by selecting the raspberry icon
and then `Preferences -> Recommended Software`. When the dialog
appears, select `Office` on the left-hand side and then check the
box for `LibreOffice` on the right hand side. Click `Apply` to
install the software. Click `Close` when the software is installed.

![Install LibreOffice](/images/install-libreoffice.png)

## Install the OP25 software
Click the terminal icon at the top of the RPi desktop. Install OP25 using:

    cd ~
    git clone https://github.com/boatbod/op25.git
    cd op25
    ./install.sh

## Configure OP25 trunk file and talkgroups
Clone this repository to get the configuration files and scripts using:

    cd ~
    git clone https://github.com/rlucente-se-jboss/rpi4-op25.git

Launch the `LibreOffice Calc` application by selecting the raspberry
icon and then `Office -> LibreOffice Calc`. Select `File -> Open
...` and then navigate to the `trunk.tsv` file in the directory
`/home/pi/rpi4-op25`. Click `Open` and then in the dialog make sure
that tab separation is selected as shown below.

![Open Tab-separated Values](/images/open-tsv-file.png)

This file consists of a header row and then one or more data rows.
Enter data in row 2 according to the table below.

| Column | Description |
| --- | --- |
| sysname | Assign a name to the system. The default name, `fcso`, is arbitrary and it corresponds to the Frederick, MD Sheriff's office |
| control_channel_list | The primary control channel frequency in MHz |
| offset | Some sort of frequency offset, but leave this at zero |
| nac | The three digit hexadecimal network access code preceded by `0x` |
| modulation | Set to `cqpsk` for Compatible Differential Offset Quadrature Phase Shift Keying (CQPSK) is another name for Differential Phase Shift Keying (DQPSK) with 4 bit styles: 00, 01, 10, and 11. This [article](https://en.wikipedia.org/wiki/Phase-shift_keying) dives deeper into this encoding. An alternative is `c4fm` for Continuous 4 level FM. |
| tgid_tags_file | File name containing tags associated with talkgroup identifiers. |
| whitelist | The only talkgroup identifiers you want to include in the stream, e.g. 5402 |
| blacklist | Talkgroup identifiers to exclude from the stream, e.g. 5442 |
| center_frequency | Leave blank for now. |

Make the appropriate modifications for the desired Project25 system
you'd like to listen to. Save the file using `File -> Save` and
then choose `Use Text CSV Format` when prompted. Select `File -> Close`.

Next, edit the `TGID Tags File` which in the example is named
`fcso.tsv`. In LibreOffice, select `File -> Open ...` and then
choose the `fcso.tsv` file. Once again confirm that the data is tab
separated.

This file simply lists the decimal value for a talkgroup in the
first column and it's description in the second column.  An optional
third column contains the trunk priority when simultaneous calls
are present on the system being monitored. Default priority is 3,
if not explicitly specified, with lower numeric values having higher
priority. Add all talkgroups that you're interested in and then
select `File -> Save` and make sure to choose `Use Text CSV Format`
when prompted. Select `File -> Exit LibreOffice`.

## Configure Liquidsoap with Icecast
Install the packages necessary to support sending streams to an
Icecast server.

    sudo apt install liquidsoap pulseaudio pulseaudio-utils

    cd ~/rpi4-op25

Review the files `op25.liq` and `meta.json` and make sure to replace
the following parameters:

| Parameter | Description |
| --- | --- |
| YOUR-ICECAST-SERVER-ADDRESS | The hostname or IP address of your Icecast server, e.g. 192.168.1.204 |
| YOUR-ICECAST-SERVER-ADDRESS-AND-PORT | The hostname and port of your Icecast server, e.g. 192.168.1.204:8080 |
| YOUR-ICECAST-SERVER-MOUNTPOINT | The mountpoint on your Icecast server, e.g. /op25 |
| YOUR-ICECAST-SERVER-PASSWORD | The password to access your Icecast server |
| YOUR-ICECAST-SERVER-PORT | The port of your Icecast server, e.g. 8080 |

## Install the Icecast server
I installed the icecast server on a separate system from the RPi
4. The host was running Fedora 34, so I installed Icecast using:

    sudo dnf -y install icecast

Next, edit the file `/etc/icecast.xml` and change the following
entries:

    <icecast>
       <limits>
          ...
          <burst-on-connect>0</burst-on-connect>
          ...
       </limits>
       ...
       <authentication>
          ...
          <source-password>CHANGE-THIS</source-password>
          <relay-password>CHANGE-THIS</relay-password>
          <admin-password>CHANGE-THIS</admin-password>
          ...
       </authentication>
       ...
       <hostname>MATCH-YOUR-HOST</hostname>
       ...
       <listen-socket>
          ...
          <bind-address>MATCH-YOUR-HOST</bind-address>
          <shoutcast-mount>MATCH-DESIRED-MOUNT</shoutcast-mount>
          ...
       </listen-socket>
    </icecast>

Set the icecast server to start at boot time:

    sudo systemctl enable --now icecast

## Run the server
The server can be set up to run automatically without user intervention.
Make sure to review the contents of both `op25-rx.sh` and `op25.liq`
to ensure that the options and parameters are correct for your
setup.

Two services need to be installed to launch the receiver application
with the appropriate parameters and then the `op25.liq` application
to send the stream to the icecast server. Type the following commands
in a terminal window on the RPi 4:

    mkdir -p ~/.config/systemd/user
    cd ~/rpi4-op25

    cp op25-liq.service op25-rx.service ~/.config/systemd/user

    systemctl --user daemon-reload
    systemctl --user enable --now op25-rx.service
    systemctl --user enable --now op25-liq.service

    loginctl enable-linger $USER

## Archive the streams
The streams can be easily archived using curl with systemd timers
and services. On the same system that you installed the icecast
server, run the following commands:

    git clone https://github.com/rlucente-se-jboss/rpi4-op25.git

    cd rpi4-op25
    mkdir -p ~/.config/systemd/user ~/bin ~/fcso

    cp archive*.timer archive*.service ~/.config/systemd/user

Modify the parameter `STREAM_URL` in the `archive-stream.sh` file
to match the URL for the mountpoint on the icecast server. This
needs to be the actual MP3 stream and not the M3U playlist file.
Then, run the following commands:

    cp archive-stream.sh ~/bin

    systemctl --user daemon-reload

    systemctl --user enable --now archive-stream-00.timer
    systemctl --user enable --now archive-stream-30.timer

    loginctl enable-linger $USER

The two systemd timers trigger at the top and bottom of the hour.
Since each systemd service archives thirty-one minutes of streaming
to ensure overlap, one timer would not work as the timer will not
retrigger if it's corresponding service is still active.

The last thing you may want to do when archiving files is to remove
files that are older than a specific time. Technically, files are
removed that have not been accessed, modified, or created within
the specified time period. Removing older files is easily done using
the systemd-tmpfiles-clean timer and service. Edit the file
`clean-stream.conf` and change `YOUR-USERID` to match the actual
user account being used to archive the streams (e.g. rlucente).
Once the file is edited, run the following commands:

    cp clean-stream.conf /etc/tmpfiles.d
    restorecon -vFr /etc/tmpfiles.d

TODO instructions on how to connect to web interface for op25, how to connect to icecast server to play streams
