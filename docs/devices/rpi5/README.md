# Raspberry Pi 5
The following section describes a step-by-step process of configuring, deploying, and running a single **Ethereum Node** hosted on single Raspberry Pi 5 device.

⚠️ **To avoid errors during the first setup, please follow the instructions precisely.** ⚠️

## Device Setup
Here, you can find a full description of how to set up an **Ethereum Full Node** using a single Raspberry Pi 5 device. Following those steps will give you access to your Ethereum RPC.

### 1. Hardware requirements
The default setup requires the following hardware components
- 1 x Raspberry Pi 5 (8GB) with active cooling
- 1 x 2TB SSD drive (external USB SSD or NVMe m.2 with adapter) 
- 1 x SD Card reader/writer
- 1 x microSD memory card 32 GB or bigger
- 1 x Compatible power supply

### 2. Accessories and Network Setup
The basic setup requires the following steps
- Connecting Raspberry Pi 5 devices to the local network with Internet access (DHCP)
- Connecting the control device (PC) to the same network

### 3. OS Image
There are two steps to prepare an image:
- Download the latest release of the _Ethereum on Pi_ image for Raspberry Pi 5
- Write the image to an SD Card closely following the detailed instruction

### 4. Installation
The following instructions describe the configuration of a Raspberry Pi 5 device.
- Insert the previously prepared SD Card into the device
- Connect the 2TB NVMe or USB SSD drive
- Connect the Ethernet cable to the device
- Optionally: _Connect HDMI cable to the monitor and the device using HDMI 0 port_
- Connect the default Raspberry Pi 5 power supply to the device

Connect power and run the system only when every thing is properly connected.
After connecting power Raspberry Pi 5 starts booting automatically. During startup rc.local configure storage. There will be a reboot. Please give 5 min for the first-time boot.



---

## Troubleshooting
To go to the troubleshooting section, follow this [link](./troubleshooting.md).

If you have any problems related to **Ethereum on Pi** use, please feel welcome to post an issue on GitHub.
