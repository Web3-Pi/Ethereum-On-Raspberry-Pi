## mDNS (Multicast DNS)

Multicast DNS (mDNS) is a protocol that allows devices on a local network to perform DNS-like operations without requiring a dedicated DNS server. It enables the resolution of hostnames to IP addresses within small networks using multicast IP address 224.0.0.251 and UDP port 5353.

### Key Points:

- **Local Network Name Resolution:** mDNS is primarily used for resolving hostnames to IP addresses within the same local network segment, making it easier to discover devices and services without a central DNS server.
- **Zero Configuration:** mDNS is part of the Zeroconf (Zero Configuration Networking) suite, allowing devices to automatically configure themselves and discover other devices without manual setup.
- **Multicast Communication:** It uses multicast communication to send DNS queries to all devices on the local network, and the device with the matching hostname responds with its IP address.
- **Compatibility:** mDNS is widely implemented in consumer and enterprise devices, often seen in technologies like Apple's Bonjour, which uses mDNS for service discovery.

### Technical Details:

- **Multicast Address:** 224.0.0.251
- **Port:** UDP 5353
- **Standards:** Defined in RFC 6762

In summary, mDNS provides a way for devices to discover and communicate with each other on a local network without the need for manual configuration or a central DNS server, making it an essential protocol for modern networking environments.