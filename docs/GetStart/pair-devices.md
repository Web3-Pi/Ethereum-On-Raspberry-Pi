The following section describes a step-by-step process of configuring, deploying, and running a full Ethereum Node hosted on two Raspberry Pi devices.

You can use:

- Two Rpi 4
- Two Rpi 5
- Rpi 5 + Rpi 4

or any other configuration including CM4.

Device with execution client needs 2TB+ fast storage.
Device with consensus client needs 256GB+ fast storage.


## Device Setup
The following section describes a step-by-step process of configuring, deploying, and running a single Ethereum Node hosted on two Raspberry Pi devices.

⚠️ To avoid errors during the first setup, please follow the instructions precisely. ⚠️

### Hardware requirements
The default setup requires the following hardware components:

  - 2 x Raspberry Pi (8GB) starter kits
  - 2 x SSD (one for each device)
  - 1 x SD Card reader/writer
  - 2 x Fast MicroSD Card

#### Raspberry Pi

You can use:

- [Raspberry Pi 5](https://botland.store/raspberry-pi-5-modules-and-kits/23905-raspberry-pi-5-8gb-5056561803326.html) with [Active cooling](https://botland.com.pl/elementy-montazowe-raspberry-pi-5/)
- [Raspberry Pi 4](https://botland.store/raspberry-pi-4b-modules-and-kits/16579-raspberry-pi-4-model-b-wifi-dualband-bluetooth-8gb-ram-18ghz-5056561800356.html) with [Active cooling](https://botland.store/raspberry-pi-4b-cases/15106-case-justpi-for-raspberry-pi-4b-aluminum-with-dual-fan-black-lt-4b02-5903351242660.html)
- CM4 with motherboard

8GB RAM is required.

#### Storage
**2 TB** fast drive is required for device running **execution** client (Geth)  
**256 GB+** fast drive is required for device running **consensus** client (Nimbus/Lighthouse)

With **Raspberry Pi 5** you have three options for storage:

- external USB SSD drive (wide availability)
- m.2 NVMe drive with NVMe HAT for Raspberry Pi 5 (max performance)
- m.2 NVMe drive with USB m.2 adapter 

Raspberry Pi 5 has a PCIe x1 connector on board so with a special adapter m.2 NVMe drive can be used.
This option gives the maximum possible performance.
For more information visit: [recommended storage](./1a-recommended-storage.md)

With **Raspberry Pi 4** you have two options for storage:

- external USB SSD drive (wide availability)
- m.2 NVMe drive with USB m.2 adapter 

> **If you use USB always choose USB 3.0 ports (blue)**

#### Power supply
As a power supply, we recommend an [official 15W PSU](https://www.raspberrypi.com/products/type-c-power-supply/) for Raspberry Pi 4 or [official 27W PSU](https://www.raspberrypi.com/products/27w-power-supply/) for Raspberry Pi 5.

#### Cooling
Active colling is required to avoid throttling and keep sufficient performance/stability on the system. Please see "Hardware" section for more information.

#### microSD Card

Flashing a microSD card takes time, but it can be reduced by using a fast device. Additionally, using a fast micro SD card results in a shorter booting time. A few examples:

- [Silicon Power 3D NAND](https://www.tomshardware.com/best-picks/raspberry-pi-microsd-cards#section-best-microsd-card-overall)
- [SanDisk Extreme Pro](https://www.tomshardware.com/best-picks/raspberry-pi-microsd-cards#section-great-speeds-best-for-pi-3)
- [Kingston Canvas React](https://www.tomshardware.com/best-picks/raspberry-pi-microsd-cards#section-fastest-booting-raspberry-pi-microsd)

!!! note "More information"
    [https://www.tomshardware.com/best-picks/raspberry-pi-microsd-cards](https://www.tomshardware.com/best-picks/raspberry-pi-microsd-cards).


## Connection Diagram

Once you have all the hardware collected, you will need to unbox the Raspberry Pi device and connect it according to the specifications below:

![Image title](/img/img-rpi4-connection-diagram-1.png)


⚠️ **For the mDNS mechanism to work, it is crucial that all devices are connected within the same local network.** ⚠️

_Optimally using one network switch._


## Photos

Below, you can see photos of an example setup:

![Sample configuration with USB drive](/img/img-example-setup-1.jpg)

## OS Images

The image contains a preconfigured Linux distribution capable of running an **Ethereum Node**.

### Prerequisites
To write an image on an SD card, it is recommended to use the official tool provided by the Raspberry Pi Foundation:

- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)

After installing it on your PC, you can download the newest Ethereum on Pi image. 

You need two image files:

  - one for execution client ([download](https://github.com/Web3-Pi/Ethereum-On-Raspberry-Pi/releases/download/v0.5.2/EthOnRpi_v0_5_2-execution.img.xz))
  - second for consensus client ([download](https://github.com/Web3-Pi/Ethereum-On-Raspberry-Pi/releases/download/v0.5.2/EthOnRpi_v0_5.2-consensus.img.xz))

List of all images: [Ethereum on Raspberry Pi images](../downloads.md)


### Writing Images
Follow the instructions below to write images to both devices.

### 1. Execution client
- Insert a blank SD Card into a card reader and connect the reader to your PC
- Open the Raspberry Pi Imager on your PC
- Choose device type
- Choose the downloaded image for execution client as a source image
- Choose the SD card reader as a target device
- Required custom configuration
  - Set hostname to _eop-exec_
  - Enable SSH authentication
  - Set username and password (e.g., _raspberry/raspberry_)
  - uncheck "Eject media when finished"
- Write the image to the SD card
- Eject the card and insert it into the first device
- Do not ommit verify step

!!! note "Remember the hostname" 
    We use mDNS so after proper installation user can connect to Raspberry Pi using hostname instead of IP address.
    
    ``` sh
    eop-exec.local
    
    ```

An example screenshot with settings for the geth node:
![Sample Raspbberyy Pi Imager configuration](/img/img-raspberry-imager-example-exec.png)


### 2. Consensus client

- Insert a blank SD Card into a card reader and connect the reader to your PC
- Open the Raspberry Pi Imager on your PC
- Choose device type
- Choose the downloaded image for consensus client as a source image
- Choose the SD card reader as a target device
- Required custom configuration
  - Set hostname to _eop-consensus_
  - Enable SSH authentication
  - Set username and password (e.g., _raspberry/raspberry_)
  - uncheck "Eject media when finished"
- Write the image to the SD card
- Eject the card and insert it into the first device
- Do not ommit verify step


!!! note "Remember the hostname" 
    We use mDNS so after proper installation user can connect to Raspberry Pi using hostname instead of IP address.
    
    ``` sh
    eop-consensus.local
    
    ```

![Sample Raspbberyy Pi Imager configuration](/img/img-raspberry-imager-example-consensus.png)

_If some steps remain unclear, you can visit the [Raspberry Pi "getting started" page](https://www.raspberrypi.com/documentation/computers/getting-started.html) for more information on Imager settings and usage._

## Installation

The Raspberry Pi devices will be configured during the initial run, and their software will be updated. 
After this step, devices can be used to host an **Ethereum Node**.

### Warning
⚠️ **In most cases, the installation script erases the SSD content.** ⚠️

### Checklist before the installation
- Make sure that the device is configured correctly (i.e., it has a valid active cooling system installed)
- Make sure that you use the correct SSD (Geth device: 2TB, Lighthouse device: 0.5TB)

### Installation
- Insert the previously prepared SD card into the device
- Connect the SSD to the USB 3.0 port or use NVMe m.2 drive with PCIe adapter
- Connect the Ethernet cable to the device
- Optionally: connect HDMI cable to the monitor and the device using HDMI 0 port (on the device)
- Connect the Raspberry Pi power supply to the device

After the device is powered up, it will enter the process of updating the software and configuring itself to act as an **Ethereum Node**.

⚠️ **This process can take up to 15 minutes.** ⚠️

Repeat this for both devices.


### Installation verification

Check when it is finished by opening:  

[http://eop-exec.local:7197/node/system/status](http://eop-exec.local:7197/node/system/status)

and

[http://eop-consensus.local:7197/node/system/status](http://eop-consensus.local:7197/node/system/status)

When installation is completed you will see JSON like this:
``` sh
{"host_name": "eop-exec", "num_cores": 4, "cpu_percent": 14.9, "mem_total": 8324055040, "mem_used": 6542295040, "mem_free": 503726080, "mem_percent": 81.8, "swap_total": 0, "swap_used": 4642058240, "swap_free": 12537806848, "swap_percent": 27.0, "disk_used": 1207331737600}
```

If the site is not available, **please wait and try again**. Installation can take up to 15 minutes.

!!! note "mDNS"
    mDNS service needs some time to start.  
    Raspberry Pi over IP address will be accesible quicker than using host name.  
    mDNS should be available in less than **15 min** from the start. 


### Secure Communication
Both devices have to establish a secure communication channel. This is achieved by creating a common JWT secret file shared by clients.

The installation script has already generated a common directory structure to store the JWT secret file.  
To finish the configuration, the secret file has to be populated across devices.  
Finish the process by executing the following commands.

Copy the secret file from consensus device to the execution device:

1. Login to _eop-consensus.local_ using ssh client
2. User: _ethereum_ Pass: _ethereum_ (password change is required at first login)
3. 
``` sh
cd
scp clients/secrets/jwt.hex eop-exec.local:~/clients/secrets
```

SCP command will ask you for password (_eop-exec.local_ device). Default is "ethereum". But on first login user is forced to change it.

After executing the above action, the devices can be connected and run as a single **Ethereum Node**.


### Running execution client

The consensus client starts automatically but the execution client on the second device does not because it can be done after copying the secret file from the preview step.

1. Login to _eop-exec.local_ using ssh client
2. User: _ethereum_ Pass: _ethereum_ (password change is required at first login)
3. Enable w3p_geth.service (auto start)
``` sh
sudo systemctl enable w3p_geth.service
```
4. Start w3p_geth.service
``` sh
sudo systemctl start w3p_geth.service
```

!!! tip "TIP: service monitoring"
    Service output can be monitored using command:  
    ``` sh
    journalctl -xefu w3p_geth.service 
    ```


#### Grafana Monitoring verification

Grafana, InfluxDB, and Basic Node Monitor (BNM) are disabled in pair devices mode.
After providing manual configuration they can be enabled and used. More information at - [Monitoring](../Monitoring/monitoring.md)

#### Account verification
- SSH login into the device as _ethereum/ethereum_
  - If the _ethereum_ user does not exist, it means that the installation failed unexpectedly (in such case, _contact support_)
- By default, _ethereum_ user is forced to change the password during the first login

#### Network configuration verification
- From Raspberry Pi device run the command:
  ```bash
  ping google.com
  ```

### Summary

At this point, devices are configured and ready to host an **Ethereum Node**.

If you have default config.txt Geth, Nimbus software will start automatically as a service.

For more information on how to configure/modify elements of Ethereum On Raspberry Pi, please read the "Reference" part of this documentation.
