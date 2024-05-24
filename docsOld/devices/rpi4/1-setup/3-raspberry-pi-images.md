# OS Images
There are two Raspberry Pi devices to set up; hence, we need to write two Linux images to two separate SD cards - one for each device.

The image contains a preconfigured Linux distribution capable of running an **Ethereum Node**. The first device will run the _Geth_ client, and the second will run the _Lighthouse_. Both devices must run in sync to host a single **Ethereum Node**.

## Prerequisites
To write an image on an SD card, it is recommended to use the official tool provided by the Raspberry Pi Foundation:
- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)

After installing it to your PC, you can download the newest **Ethereum on Pi** image. This image will be used on each of the devices, so only one copy is required:
- [Ethereum on Pi image](https://github.com/viggith/ethereum-on-pi/releases/tag/v0.0.1#:~:text=rpi4_e_eoa_22.04.00_v001.img.zip)

You can check the list of all images [here](https://github.com/viggith/ethereum-on-pi/releases).

---
_An option for advanced developers._

If you have some experience with the **Ethereum on Pi** project, you can prepare the most up-to-date image by yourself using the provided image generator:
- [Image builder instruction](./3-build-image.md)
---

## Writing Images
Follow the instructions below to write images to both devices.

### 1. Geth
- Insert a blank SD Card into a card reader and connect the reader to your PC
- Open the Raspberry Pi Imager on your PC
- Choose the downloaded image as a source image
- Choose the SD card reader as a target device
- Required custom configuration
  - Set hostname to _geth-1_
  - Enable SSH authentication
  - Set username and password (e.g., _raspberry/raspberry_)
- Write the image to the SD card
- Eject the card and insert it into the first device

\
An example screenshot with settings for the geth node:

![Sample Raspbberyy Pi Imager configuration](./img-raspberry-imager-example-geth.png)

### 2. Lighthouse
- Insert a blank SD Card into a card reader and connect the reader to your PC
- Open the Raspberry Pi Imager on your PC
- Choose the downloaded image as a source image
- Choose the SD card reader as a target device
- Required custom configuration
  - Set hostname to _lighthouse-1_
  - Enable SSH authentication
  - Set username and password (e.g., _raspberry/raspberry_)
- Write the image to the SD card
- Eject the card and insert it into the second device
   
\
An example screenshot with settings for the lighthouse node:

![Sample Raspbberyy Pi Imager configuration](./img-raspberry-imager-example-lighthouse.png)

\
_If some steps remain unclear, you can visit the [Raspberry Pi "getting started" page](https://www.raspberrypi.com/documentation/computers/getting-started.html) for more information on Imager settings and usage._

## Next Step

[➡️ Click here to move to next step & Run your Raspberry Pi for the first time ➡️](./4-installation.md)
