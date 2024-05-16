### My external monitor is not working with Raspberry Pi
- Make sure that yout external monitor is connected to Raspberry Pi Hdmi0 port before Raspberry Pi is turned on
- Make sure that yout external monitor is powered on before Raspberry Pi is turned on
- Try using different Monitor / Hdmi cable

---

### How much Internet bandwidth will be used for the syncing process?
🚧 TBA 🚧

---

### How much Internet bandwidth is used daily for the node to remain up-to-date (assuming it was already synced to newest block)
It is recomended to have 10 Mbps uplink & downlink for the Full Node to remain synchronized

---

### How do I know if first/init run was successful?
If you are able to login on Raspberry Device with ethereum credentials and command `pwd` returns `/home/ethereum` that means typically that init was successful.
(External drive /dev/sda1 was mounted as /home and rc.local script was finished successfuly)

---

### Do I need to update anything?
🚧 TBA 🚧

---

### My external disk is not working
- Use one of disks from [recommended storage](./devices/rpi4/1-setup/1a-recomended-storage.md) section.
- Try inserting USB Hub with external power supply between Raspberry Pi & Disk Adapter 
- Erase partition on a disk using another PC


---
