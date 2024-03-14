# OS Images

The image contains a preconfigured Linux distribution capable of running an **Ethereum Node**.

## Prerequisites
To write an image on an SD card, it is recommended to use the official tool provided by the Raspberry Pi Foundation:
- [Raspberry Pi Imager](https://www.raspberrypi.com/software/)

After installing it to your PC, you can download the newest **Ethereum on Pi** image. This image will be used on each of the devices, so only one copy is required:
- [Ethereum on Pi image for Raspberry Pi 5](https://github.com/Web3-Pi/Ethereum-On-Raspberry-Pi/releases/tag/Rpi5)

You can check the list of all images [here](https://github.com/viggith/ethereum-on-pi/releases).


## Writing Images
Follow the instructions below to write images o microSD card.

- Insert a blank SD Card into a card reader and connect the reader to your PC
- Open the Raspberry Pi Imager on your PC
- Choose device type: Raspberry Pi 5 
- Choose the downloaded image as a source image
- Choose the SD card reader as a target device
- Required custom configuration
  - Set hostname to _EthOnPi5_
  - Enable SSH authentication
  - Set username and password (e.g., _raspberry/raspberry_)
- Write the image to the SD card
- Eject the card and insert it into the first device
- Do not ommit verify step
  
\
An example screenshot with settings for the geth node:

![Sample Raspbberyy Pi Imager configuration](./img-raspberry-pi5-imager-example.png)


\
_If some steps remain unclear, you can visit the [Raspberry Pi "getting started" page](https://www.raspberrypi.com/documentation/computers/getting-started.html) for more information on Imager settings and usage._

## Next Step
