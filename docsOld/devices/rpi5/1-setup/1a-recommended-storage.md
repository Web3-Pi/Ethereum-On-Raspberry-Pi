# Devices

You can use different storage configurations:
- External USB SSD drive (recommended)
- m.2 NVMe drive with PCIe x1 to m.2 adapter for Rpi 5 (recommended - max. performance)
- m.2 NVMw drive with USB ro m.2 adapter
- USB to SATA adapter + SSD 2.5" drive
 
List of possible hardware:


## External USB SSD drive

| Brand   | Storage | Model                              | Link*                                                                                     | comment                            |
| ------- | ------- | ---------------------------------- | ---------------------------------------------------------------------------------------- | ---------------------------------- |
| Samsung | 2 TB    | T7 2TB USB 3.2                     | https://tweakers.net/pricewatch/1560668/samsung-portable-ssd-t7-2tb-grijs/specificaties/ | **recommended for most users**     |

> [!TIP]
> Some external disks consume more power than Raspberry Pi can deliver via USB. 
> For Raspberry Pi 5 max power output of USB ports is 600mA if using a 3A supply, 1600mA if using a 5A supply. 
> You can edit /boot/firmware/config.txt and add usb_max_current_enable=1 to disable current limit. 
> Please read the documentation: https://www.raspberrypi.com/documentation/computers/raspberry-pi.html



## m.2 NVMe drive
Those drives need adapters

| Brand   | Storage | Model                              |
| ------- | ------- | ---------------------------------- |
| Kingston    |         | KC3000 
| AData   |         | XPG Gammix S70
| Crucial    |         | P5 Plus
| Samsung    |         | 980 Pro


[Full compatibility list for Ethereum node](https://gist.github.com/yorickdowne/f3a3e79a573bf35767cd002cc977b038)
[Full compatibility list for Pimoroni adapter](https://shop.pimoroni.com/products/nvme-base?variant=41219587178579)



## NVMe HAT for Raspberry Pi 5:

| Brand   | Link*                                                                                       |
| ------- | ------------------------------------------------------------------------------------------ |
| Pimoroni | https://shop.pimoroni.com/products/nvme-base?variant=41219587178579 | **recommended**     |
| Pineberrypi  | https://pineberrypi.com/products/hatdrive-bottom-2230-2242-2280-for-rpi5 |   |
| Waveshare  | https://www.waveshare.com/product/raspberry-pi/boards-kits/raspberry-pi-5/pcie-to-m.2-board-c.htm |   |



## USB to NVMe adapters:

| Brand   | Link*                                                                                       |
| ------- | ------------------------------------------------------------------------------------------ |
| ZenWire | https://zenwire.eu/pl/p/Adapter-SSD-M2-NVMESATA-kieszen-na-dysk-obudowa-M.2-USB-C-10-GBs-Zenwire/289|
| RIITOP  | https://www.amazon.nl/dp/B0B1HVGBZ3?ref_=pe_28126711_487767311_302_E_DDE_dt_1|
| QOLTEC  | https://www.tme.eu/en/details/qoltec-50311/hdd-ssd-accessories/qoltec/50311/|

or other similar


> [!IMPORTANT]
> Some M.2 disks are not compatible. Please check the availability list on [Pimoroni NVMe Base description](https://shop.pimoroni.com/products/nvme-base?variant=41219587178579).


---
_*Sample links result from a quick Google search mainly for the reader's convenience & quick price reference; we invite you to do your own research and find local hardware providers._

