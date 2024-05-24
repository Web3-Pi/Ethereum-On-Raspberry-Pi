### Devices
Raspberry Pi 4 provides limited power output with its USB ports; only some of the external disks will work without the necessity of an external power source.

#### Geth
We recommend the following disks for the Geth Node:

| Brand   | Storage | Model                              | Link*                                                                                     | comment                            |
| ------- | ------- | ---------------------------------- | ---------------------------------------------------------------------------------------- | ---------------------------------- |
| Samsung | 2 TB    | T7 2TB USB 3.2                     | https://tweakers.net/pricewatch/1560668/samsung-portable-ssd-t7-2tb-grijs/specificaties/ | **recommended for most users**     |
| Sabrent | 2 TB    | 2TB M.2 2242 PCIe 3.0 NVMe TLC SSD | https://sabrent.com/products/sb-1342-2tb                                                 | needs an additional USB-NVMe [adapter](#usb-nvme-adapters:) |

#### Lighthouse
We recommend the following disks for the Lighthouse Node:

| Brand   | Storage | Model            | Link*                                                                                       |
| ------- | ------- | ---------------- | ------------------------------------------------------------------------------------------ |
| Samsung | 0.5 TB  | T7 0.5TB USB 3.2 | https://tweakers.net/pricewatch/1559020/samsung-portable-ssd-t7-500gb-grijs/specificaties/ |


### USB-NVMe adapters:

| Brand   | Link*                                                                                       |
| ------- | ------------------------------------------------------------------------------------------ |
| ZenWire | https://zenwire.eu/pl/p/Adapter-SSD-M2-NVMESATA-kieszen-na-dysk-obudowa-M.2-USB-C-10-GBs-Zenwire/289|
| RIITOP  | https://www.amazon.nl/dp/B0B1HVGBZ3?ref_=pe_28126711_487767311_302_E_DDE_dt_1

\
**Important information**

Some M.2 disks consume more power than Raspberry Pi 4 can deliver via USB; therefore, the adapter would need an external power supply. That can be solved, for example, by USB 3 Hub with an external power supply (e.g., https://www.amazon.com/powered-usb-3-0-hub/s?k=powered+usb+3.0+hub)

---
_*Sample links result from a quick Google search mainly for the reader's convenience & quick price reference; we invite you to do your own research and find local hardware providers._
_It is also worth mentioning that the accessories mentioned above were tested by our team and were proven to be working correctly with Raspberry Pi 4._
