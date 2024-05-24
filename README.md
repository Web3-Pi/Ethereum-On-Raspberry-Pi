## Ethereum On Raspberry Pi

Basic suite of tools and references to existing projects to create and host Ethereum Nodes on the devices from the Raspberry Pi family.

The main goal of this project is to provide a lightweight image creation suite that can be used to deploy Ethereum nodes on various devices from the Raspberry Pi family, including:

- [Raspberry Pi 5 ](https://www.raspberrypi.com/products/raspberry-pi-5/) with 8GB of RAM
- [Raspberry Pi 4 Model B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) with 8GB of RAM
- [Compute Module 4](https://www.raspberrypi.com/products/compute-module-4/) with 8GB of RAM

Additionally, this project is supposed to:

- Allow node customization (multidevice support with custom networking setup)
- Simplify building clusters of Ethereum nodes deployed on multiple Raspberry Pi-based devices

### Ethereum on ARM

This project is based on the project [Ethereum on ARM](https://github.com/EOA-Blockchain-Labs/ethereumonarm) and, more specifically, on [EOA image for Raspberry Pi](https://ethereumonarm-my.sharepoint.com/:u:/p/dlosada/Ec_VmUvr80VFjf3RYSU-NzkBmj2JOteDECj8Bibde929Gw?download=1). The provided images are designed to make the configuration of a node as easy as possible; from the [Ethereum on ARM](https://github.com/EOA-Blockchain-Labs/ethereumonarm):

> **The image takes care of all the necessary steps to run a node, from setting up the environment and formatting the disk to installing, managing, and running the Execution and Consensus clients.**

### Development Environment

Scripts provided by **Ethereum On Pi** have been developed on **Ubuntu 20.04.6 LTS** and tested on **Ubuntu 20.04.6 LTS** and **Ubuntu 23.10** _(scripts to build Raspberry Pi images and edit rc.local file)_.

## 🚀 Node Setup 🚀

To configure an **Ethereum Node**, follow the [instructions](https://web3-pi.github.io/setup-guide/) from the installation manual.

You can also follow the instructions for a particular device setup:

- [Single device](https://web3-pi.github.io/setup-guide/GetStart/single-device/)
- [Pair device](https://web3-pi.github.io/setup-guide/GetStart/pair-devices/)


## Acknowledgements
Thanks to [Ethereum on ARM](https://github.com/EOA-Blockchain-Labs/ethereumonarm) project and its community.

