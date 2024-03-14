# Installation
The Raspberry Pi 5 devices will be configured during the initial run, and their software will be updated. 
After this step, devices can be used to host an **Ethereum Node**.


### Warning
⚠️ **In most cases, the installation script erases the SSD content.** ⚠️


### Checklist before the installation
- Make sure that the device is configured correctly (i.e., it has a valid active cooling system installed)
- Make sure that you use the correct SSD (2TB or more)

### Installation
- Insert the previously prepared SD card into the device
- Connect the SSD to the USB 3.0 port or use NVMe m.2 drive with PCIe adapter
- Connect the Ethernet cable to the device
- Optionally: connect HDMI cable to the monitor and the device using HDMI 0 port (on the device)
- Make sure that all accessories are connected as shown below
\
\
![device setup](./img-rpi5-connection-diagram-1.png)
- Connect Raspberry Pi 5 power supply to the device

After the device is powered up, it will enter the process of updating the software and configuring itself to act as an **Ethereum Node**.

Device can restart automaticli during this process.
Wait 5 minutes and try to log in as _raspberry/raspberry_ via SSH. 


[Optional] To configure key-based authentication to access devices, follow this [guideline](./4a-ssh-key-based-authentication.md).

### Summary
At this point, both devices are configured and ready to host and **Ethereum Node**. A detailed procedure for running two devices as a single node is described in the following sections.
