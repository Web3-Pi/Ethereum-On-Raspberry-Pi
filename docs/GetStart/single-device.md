The following section describes a step-by-step process of configuring, deploying, and running a full Ethereum Node hosted on single Raspberry Pi device.
For this configuration Raspbery Pi 5 is recommended but Pi 4 and CM4 can be used too.

⚠️ To avoid errors during the first setup, please follow the instructions precisely. ⚠️


## Device Setup
Here, you can find a full description of how to set up an **Ethereum Full Node** using a single Raspberry Pi 5 device. Following those steps will give you access to your Ethereum RPC.

### Hardware requirements

The default setup requires the following hardware components

- 1 x [Raspberry Pi 5 (8GB)](https://botland.store/raspberry-pi-5-modules-and-kits/23905-raspberry-pi-5-8gb-5056561803326.html) with [Active colling](https://botland.com.pl/elementy-montazowe-raspberry-pi-5/23925-raspberry-pi-active-cooler-aktywne-chlodzenie-radiator-wentylator-do-raspberry-pi-5-5056561803357.html)
- 1 x 2TB SSD drive (external USB SSD or NVMe m.2 with adapter) - [recommended storage](../Hardware/storage.md)
- 1 x SD Card reader/writer 
- 1 x [microSD Card](../Hardware/microSD.md)
- 1 x [Power supply](https://botland.store/raspberry-pi-5-power-supply/23907-raspberry-pi-27w-usb-c-power-supply-official-51v-5a-psu-for-raspberry-pi-5-black-5056561803418.html)

### Storage
2 TB fast drive is required. 
With Raspberry Pi 5 you have three options for storage:

- external USB SSD drive (wide availability)
- m.2 NVMe drive with NVMe HAT for Raspberry Pi 5 (max performance)
- m.2 NVMe drive with USB m.2 adapter 

Raspberry Pi 5 has a PCIe x1 connector on board so with a special adapter m.2 NVMe drive can be used.
This option gives the maximum possible performance.
For more information visit: [recommended storage](./1a-recommended-storage.md)

> **If you use USB always choose USB 3.0 ports (blue)**

### Power supply
As a power supply, we recommend an [official PSU 5,1V / 5A](https://botland.store/raspberry-pi-5-power-supply/23907-raspberry-pi-27w-usb-c-power-supply-official-51v-5a-psu-for-raspberry-pi-5-black-5056561803418.html) for Raspberry Pi 5.
Raspberry Pi 5 + 2TB drive can use a significant amount of power so a sufficient power supply is important for stability.

### Cooling
[Active colling](https://botland.com.pl/elementy-montazowe-raspberry-pi-5/23925-raspberry-pi-active-cooler-aktywne-chlodzenie-radiator-wentylator-do-raspberry-pi-5-5056561803357.html) is required to avoid throttling and keep sufficient performance/stability of the system.


### microSD Card

Flashing a microSD card takes time, but it can be reduced by using a fast device. Additionally, using a fast micro SD card results in a shorter booting time. A few examples:

- [Silicon Power 3D NAND](https://www.tomshardware.com/best-picks/raspberry-pi-microsd-cards#section-best-microsd-card-overall)
- [SanDisk Extreme Pro](https://www.tomshardware.com/best-picks/raspberry-pi-microsd-cards#section-great-speeds-best-for-pi-3)
- [Kingston Canvas React](https://www.tomshardware.com/best-picks/raspberry-pi-microsd-cards#section-fastest-booting-raspberry-pi-microsd)

!!! note "More informations"
    [https://www.tomshardware.com/best-picks/raspberry-pi-microsd-cards](https://www.tomshardware.com/best-picks/raspberry-pi-microsd-cards).


## Connection Diagram

Once you have all the hardware collected, you will need to unbox the Raspberry Pi device and connect it according to the specifications below:

![Image title](/img/img-rpi5-connection-diagram-1.png)


## Photos

Below, you can see photos of an example setup:

### Sample configuration with USB drive
![Sample configuration with USB drive](/img/img-example-setup-USB.jpg)


### Sample configuration with NVMe drive
![Sample configuration with NVMe drive](/img/img-example-setup-NVMe.jpg)


## OS Images

The image contains a preconfigured Linux distribution capable of running an **Ethereum Node**.

### Prerequisites
To write an image on an SD card, it is recommended to use the official tool provided by the Raspberry Pi Foundation:

- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)

After installing it to your PC, you can download the newest **Ethereum on Pi** image. This image will be used on each of the devices, so only one copy is required:

- [Ethereum on Pi image for Raspberry Pi](../downloads.md)


### Writing Images
Follow the instructions below to write images o microSD card.

- Insert a blank SD Card into a card reader and connect the reader to your PC
- Open the Raspberry Pi Imager on your PC
- Choose device type
- Choose the downloaded image as a source image
- Choose the SD card reader as a target device
- Required custom configuration
  - Set hostname to _eop-1_
  - Enable SSH authentication
  - Set username and password (e.g., _raspberry/raspberry_)
  - uncheck "Eject media when finished"
- Write the image to the SD card
- Eject the card and insert it into the device
- Do not ommit verify step

!!! note "Remember the hostname" 
    We use mDNS so after proper istalation user can connect to Raspberry Pi using hostname istead IP adress.
    
    ``` sh
    eop-1.local
    
    ```

An example screenshot with settings for the geth node:

![Sample Raspbberyy Pi Imager configuration](/img/img-raspberry-imager-example-eop-1.png)

_If some steps remain unclear, you can visit the [Raspberry Pi "getting started" page](https://www.raspberrypi.com/documentation/computers/getting-started.html) for more information on Imager settings and usage._


## Initial configuration

Ethereum On Rapberry Pi image use clasic /boot/firmware/config.txt as config file. This way you can customize your setup before first run.
After writing image to SD card you shold see new drive in your PC.
There is config.txt file. This config is for Raspberry Pi but Ethereum On Raspberry Pi adds own sections to it. 

``` sh
# Web3Pi config
[web3pi]
geth=true
nimbus=true
lighthouse=false

# Monitoring
influxdb=true
grafana=true
bsm=true
bnm=true
```

it is recommended to always leave  bsm=true

!!! note "More informations about config file"
    [config_txt.md](../Advanced/config_txt.md)

Here you can choose witch services will automaticly start during boot.

true = service enable  
false = service disable  
other value or no value = no change

!!! tip "Lighthous vs. Nimbus"

    Nimbus need less resurces so it is ideal for devices like Raspeberry Pi




## Installation

The Raspberry Pi 5 device will be configured during the initial run, and their software will be updated. 
After this step, devices can be used to host an **Ethereum Node**.


### Warning
⚠️ **In most cases, the installation script erases the SSD content.** ⚠️


### Checklist before the installation
- Make sure that the device is configured correctly (i.e., it has a valid active cooling system installed)
- Make sure that you use the correct SSD (2TB or more)
- Internet access is required (default DHCP)

The contents will not be erased if you have already configured **Ethereum on Pi** using this SSD. If you want, however, to force the installer to erase the configured disk, connect it to any device that you can access and follow these commands:
```bash
cd /home/ethereum
touch .format_me
```
The installer will forcefully erase the SSD if the file _.format\_me_ exists in the `/home/ethereum` directory.


### Installation
- Insert the previously prepared SD card into the device
- Connect the SSD to the USB 3.0 port or use NVMe m.2 drive with PCIe adapter
- Connect the Ethernet cable to the device
- Optionally: connect HDMI cable to the monitor and the device using HDMI 0 port (on the device)
- Connect the Raspberry Pi 5 power supply to the device

After the device is powered up, it will enter the process of updating the software and configuring itself to act as an **Ethereum Node**.

This process can take up to 15 minutes.


### Installation verification

Chceck when it is finish by opening 
[http://eop-1.local:7197/node/system/status](http://eop-1.local:7197/node/system/status)

If instalation is completed you will see JSON like that
``` sh
{"host_name": "eos-1", "num_cores": 4, "cpu_percent": 14.9, "mem_total": 8324055040, "mem_used": 6542295040, "mem_free": 503726080, "mem_percent": 81.8, "swap_total": 0, "swap_used": 4642058240, "swap_free": 12537806848, "swap_percent": 27.0, "disk_used": 1207331737600}
```

If site is not anavaible **please wait and try again**. Instalation can take up to 15 minutes.

!!! note "mDNS"
    mDNS service needs some time to start.  
    Raspberry Pi over IP address will be accesible quicker than using host name "eop-1.local"  
    mDNS should be available in less than 15 min from the start. 


#### Grafana Monitoring verification

Chceck if Grafana is working. Open at webbrowser:
[http://eop-1.local:3000](http://eop-1.local:3000)

default login and password is: "admin"
You need to change it at first login.

Go to Dashboards menu and then "Ethereum Nodes Monitor" panel.

=== "Node just started"

    Grafana dashboard at node just started
    ![Ethereum Nodes Monitor](/img/GrafanaPanelAtStart.png)
    

=== "During syncing node"

    Grafana dashboard during syncing node
    ![Ethereum Nodes Monitor](/img/GrafanaPanelSyncing.png)

=== "Node is synced"

    Grafana dashboard at node synced state
    ![Ethereum Nodes Monitor](/img/GrafanaPanelSynced.png)



#### Account verification
- SSH login into the device as _ethereum/ethereum_
  - If the _ethereum_ user does not exist, it means that the installation failed unexpectedly (in such case, _contact the support_)
- By default, _ethereum_ user is forced to change the password during the first login

#### Network configuration verification
- From Raspberry Pi device run the command:
  ```bash
  ping google.com
  ```

### Summary
At this point, device is configured and ready to host and **Ethereum Node**.

If you have default config.txt Geth, Nimbus and monitoring software will start automaticly as a service.

For more information how to configure/modify elements of Ethereum On Raspberry Pi read "Reference" part of this documentation.

