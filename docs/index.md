
!!! note "DOCUMENTATION UNDER CONSTRUCTION"

Web3 Pi provides simple, step-by-step instructions to build your own Ethereum node using Raspberry Pi 4. With affordable options, you can run your Ethereum node efficiently, focusing resources on one task with low power consumption. Own your RPC for faster access to Ethereum data, with clear guidance on hardware choices and setup costs, so you can make informed decisions and start benefiting from your own node in no time.

The main goal of this project is to provide a lightweight image creation suite that can be used to deploy Ethereum nodes on various devices from the Raspberry Pi family, including:

- [Raspberry Pi 5 ](https://www.raspberrypi.com/products/raspberry-pi-5/) with 8GB of RAM
- [Raspberry Pi 4 Model B](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) with 8GB of RAM


## Why Raspberry Pi

!!! warning "Teskt z EOA"

    https://ethereum-on-arm-documentation.readthedocs.io/en/latest/ethereum-on-arm/why-arm-boards.html

ARM boards are a great choice for running an Ethereum Full/Archive/Staking node. Among others:

- Ethereum On Pi Plug&Play image, just flash & power up
- Affordable: you can run a Full Ethereum EL / Ethereum CL nodes for less than $300
- Efficient, resources are focused on 1 task: run the node
- Low power consumption. An ARM64 boar consumes ~10w
- Small factor size: Great for running at home as it fits in any corner
- Great for running 24/7: Small, affordable and low power comsuption

## Main Features

!!! warning "Teskt z EOA"

    https://ethereum-on-arm-documentation.readthedocs.io/en/latest/ethereum-on-arm/why-arm-boards.html

These are the main features of Ethereum on ARM images:

- Based on Ubuntu 24.04 LTS for ARM64
- Automatic configuration (network, user account, etc)
- Automatic USB disk partitioning and formatting
- Manages and configure swap memory in order to avoid memory problems
- Automatically starts Ethereum 1.0 sync (Geth)
- Includes an APT repository for installing and upgrading Ethereum software
- Includes monitoring dashboards based on Grafana / InfluxDB
- Includes UFW firewall