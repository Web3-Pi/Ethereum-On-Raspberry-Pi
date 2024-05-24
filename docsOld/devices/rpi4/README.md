# Raspberry Pi 4
The following section describes a step-by-step process of configuring, deploying, and running a single **Ethereum Node** hosted on two Raspberry Pi 4 devices.

⚠️ **To avoid errors during the first setup, please follow the instructions precisely.** ⚠️

## Device Setup
Here, you can find a full description of how to set up an **Ethereum Full Node** using two separate Raspberry Pi devices. Following those steps will give you access to your Ethereum RPC.

### 1. Hardware requirements
The default setup requires the following hardware components
- 2 x Raspberry Pi 4 (8GB) starter kits
- 2 x SSD (one for each device)
- 2 x SD Card reader/writer
- 2 x Fast MicroSD Card
- 1 x LAN switch

➡️ [Details and examples](./1-setup/1-hardware-requirements.md)

### 2. Accessories and Network Setup
The basic setup requires the following steps
- Connecting the switch to the Internet
- Connecting the control device (PC) to the switch
- Connecting both Raspberry Pi 4 devices to the switch

➡️ [Detailed explanation](./1-setup/2-connection-diagram.md)

### 3. OS Image
There are two steps to prepare an image:
- Download the latest release of the _Ethereum on Pi_ image or generate the image using the provided script
- Write the image to an SD Card closely following the detailed instruction

➡️ [Necessary details](./1-setup/3-raspberry-pi-images.md)

### 4. Installation
The following instructions describe the configuration of a single Raspberry Pi 4 device. As **Ethereum Node** deployed to Raspberry Pi 4 comprises two devices, the procedure below has to be applied to both devices independently:
- Insert the previously prepared SD Card into the device
- Connect the SSD to the USB 3.0 port (_Geth_ device: 2TB, _Lighthouse_ device: 0.5TB)
- Connect the Ethernet cable to the device
- Optionally: _Connect HDMI cable to the monitor and the device using HDMI 0 port_
- Connect the default Raspberry Pi 4 power supply to the device

➡️ [Installation details](./1-setup/4-installation.md)

### 5. Overclocking
First, the **Ethereum Node** configured as described above will operate properly. However, Raspberry Pi 4 devices can be overclocked easily, improving the CPU speed and transfer to/from the SSD (at the cost of slightly higher energy consumption). To OC the device:
- Login to the device
- Go to `/boot/firmware/`
- Edit the _config.txt_ file with OC settings to apply

➡️ [Detailed instruction](./1-setup/5-overclocking.md)


---


## Ethereum Node Configuration
Running an **Ethereum Node** requires two correctly configured Raspberry Pi 4 devices operating in sync. The node configuration described in this document has the following properties: 
- It serves the default JSON-RCP API API provided by Geth (via HTTP)
- It uses the newest Geth's database scheme (_path_)
- It uses _checkpoint sync_ to synchronize Lighthouse
- It does not support ETH 2.0 staking

⚠️ **Follow precisely the steps below to deploy and run Ethereum Node.** ⚠️

### 1. Prerequisites
There are a few prerequisites that have to be fulfilled to execute the procedure successfully. This section is pretty verbose, making it easier to complete all the steps without errors.
Prerequisites include:
- Correctly setting up two Raspberry Pi 4 Devices
- Assigning unique names to the devices
- Assuring a valid network configuration

➡️ [Prerequisites details](./2-run/1-prerequisites.md)

### 2. Set up a communication channel between devices
Running the Ethereum 2.0 node requires establishing a secure communication channel between the execution client (_Geth_) and the consensus client (_Lighthouse_), even if both clients are run on the same device.

In the current scenario, the communication channel has to be configured on two devices. It is based on JSON Web Token and requires two steps:
- Generate JWT secret file
- Copy the JWT secret file to both devices

Now, devices are configured to cooperate and host as a single **Ethereum Node**.

➡️ [Detailed instruction](./2-run/2-secure-communication.md)

### 3. Geth Node
Geth is an Ethereum execution client written in Go and founded by the Ethereum Foundation. The installation script has already created all the directories and tools necessary to run a geth client on a device. To run _geth_, you must edit these scripts and execute the geth screen launcher.

➡️ [Follow this link to learn how to start Geth](./2-run/3-geth-node.md)

### 4. Lighthouse Node
Lighthouse is an open-source Ethereum consensus client written in Rust that has to run together with an execution client (for now, it is Geth). Both clients must run in sync to serve as an **Ethereum Node**.

➡️ [Follow this link to learn how to start Lighthouse](./2-run/4-lighthouse-node.md)

### 5. Additional Information
Please find information about using and monitoring the **Ethereum Node** below.

#### 5.a Client Lifecycle
Resetting either device does not require the second one to be shut down. To reboot a device: 
- Stop geth / lighthouse
- Reboot / shutdown device

➡️ [Detailed instruction](./2-run/5a-rebooting-device.md)

#### 5.b Basic Monitoring
The installation script configures three basic screen sessions for monitoring, namely temp, freq, and iotop. All sessions are automatically created during subsequent reboots.

➡️ [Detailed information](./2-run/5b-monitoring.md)

#### 5.c Blockchain Synchronization
During the initial launch, the node has to synchronize with the Ethereum blockchain. Assuming that the whole state has to be recreated from scratch and that the internet connection is moderately fast, this process may take up to **three days**.

You may also want to consult the [Geth Documentation](https://geth.ethereum.org/docs) and the [Lighthouse Book](https://lighthouse-book.sigmaprime.io/) for more details about the expected network load and the networking resources consumed by both clients.

#### 5.d JSON-RPC API
An important benefit of hosting an **Ethereum Node** is the ability to access the Ethereum blockchain locally by calling the appropriate API. In the case of the Ethereum blockchain, this can be achieved via the JSON-RPC API provided by the Geth client.

➡️ [Accessing JSON-RPC API](./2-run/5d-rpc.md)

#### 5.e SSH Key-Based Authentication
During the lifetime of a local node, logging into the Raspberry Pi 4 devices may become a routine procedure. It is convenient to set up an SSH key-based authentication to cut down on the time required to authorize devices.

➡️ [Setting up SSH key-based authentication](./1-setup/4a-ssh-key-based-authentication.md)

## Summary
After following the instructions from this document, you should be able to configure and run an **Ethereum Node** hosted by two synced Raspberry Pi 4 devices with installed **Ethereum On Pi** images. By default, the configured node can be a local **Web3 endpoint**.

---

## Troubleshooting
To go to the troubleshooting section, follow this [link](./troubleshooting.md).

If you have any problems related to **Ethereum on Pi** use, please feel welcome to post an issue on GitHub.
