## Default Ports for Geth

Geth (Go Ethereum) uses specific network ports for its operations, primarily for peer-to-peer (P2P) communication and the JSON-RPC API. Here are the default ports used by Geth:

1. **P2P Communication:**
    - **TCP/UDP Port 30303:** This is the default port used by Geth for P2P network connections with other Ethereum nodes. Both TCP and UDP protocols are used on this port.

2. **JSON-RPC API:**
    - **HTTP-RPC Port 8545:** This port is used for HTTP-based JSON-RPC API calls. It allows external applications to interact with the Geth node via HTTP requests.
    - **WebSocket Port 8546:** This port is used for WebSocket-based JSON-RPC API calls, providing a more interactive way to communicate with the Geth node.
   
3. **IPC (Inter-Process Communication):**
    - **IPC Path:** By default, Geth creates an IPC endpoint at a path like `geth.ipc` within the data directory. The IPC endpoint is a Unix domain socket on Linux/macOS or a named pipe on Windows.

### Example Commands to Specify Ports
You can customize these ports using Geth's command-line options:

- **P2P Port:**
  ```sh
  geth --port 30303
  ```

- **HTTP-RPC Port:**
  ```sh
  geth --http --http.port 8545
  ```

- **WebSocket Port:**
  ```sh
  geth --ws --ws.port 8546
  ```


### Summary of Default Ports
- **P2P:** TCP/UDP 30303
- **HTTP-RPC:** 8545
- **WebSocket:** 8546


These ports are critical for the operation of Geth and should be correctly configured to ensure proper communication and functionality within the Ethereum network.

!!! note "More informations"

    [https://geth.ethereum.org/docs/fundamentals/command-line-options](https://geth.ethereum.org/docs/fundamentals/command-line-options)


## Default Ports for Lighthouse

Lighthouse is an Ethereum 2.0 client developed by Sigma Prime. It is used for running the Beacon Chain, which is a key component of Ethereum 2.0. Here are the default network ports used by Lighthouse:


1. **P2P Communication:**
    - **TCP/UDP Port 9000:** This is the default port used by Lighthouse for peer-to-peer (P2P) communication with other Ethereum 2.0 nodes. Both TCP and UDP protocols can be used on this port.

2. **REST API:**
    - **HTTP Port 5052:** This port is used for the Lighthouse REST API, which provides endpoints for interacting with the Beacon Node.

### Example Commands to Specify Ports

You can customize these ports using command-line options when starting the Lighthouse Beacon Node:

- **P2P Port:**
  ```sh
  lighthouse bn --port 9000
  ```

- **REST API Port:**
  ```sh
  lighthouse bn --http --http-address 0.0.0.0 --http-port 5052
  ```

### Summary of Default Ports  

- **P2P:** TCP/UDP 9000
- **REST API:** 5052

These ports are essential for the operation and management of a Lighthouse Beacon Node, enabling it to communicate with other nodes in the Ethereum 2.0 network and allowing users to interact with and monitor the node.

!!! note "More informations"

    [https://lighthouse-book.sigmaprime.io/help_bn.html?highlight=default%20ports#beacon-node](https://lighthouse-book.sigmaprime.io/help_bn.html?highlight=default%20ports#beacon-node)



## Default Ports for Nimbus

Nimbus, an Ethereum 2.0 client developed by Status, uses specific network ports for various purposes including P2P communication, the HTTP API, and metrics. Here are the default network ports used by Nimbus:

1. **P2P Communication:**
    - **TCP/UDP Port 9000:** This is the default port used by Nimbus for peer-to-peer (P2P) communication with other Ethereum 2.0 nodes. Both TCP and UDP protocols are used on this port for Discovery v5 and other P2P activities.

2. **HTTP API:**
    - **HTTP Port 5052:** This port is used for the Nimbus HTTP API, which provides endpoints for interacting with the Beacon Node.

### Example Commands to Specify Ports

You can customize these ports using command-line options when starting the Nimbus Beacon Node:

- **P2P Port:**
  ```sh
  nimbus_beacon_node --tcp-port=9000 --udp-port=9000
  ```

- **HTTP API Port:**
  ```sh
  nimbus_beacon_node --rest=true --rest-address=0.0.0.0 --rest-allow-origin='*' --rest-port=5052
  ```

### Summary of Default Ports:

- **P2P:** TCP/UDP 9000
- **HTTP API:** 5052

These ports are essential for the operation and management of a Nimbus Beacon Node, enabling it to communicate with other nodes in the Ethereum 2.0 network, and allowing users to interact with and monitor the node effectively.

!!! note "More informations"

    [https://nimbus.guide/options.html](https://nimbus.guide/options.html)




## Set up port forwarding


If you're running on a home network and want to ensure you are able to receive incoming connections you may need to set up port forwarding (If UPnP is enabled - routers automagically set this up for you).

While the specific steps required vary based on your router, they can be summarised as follows:

1. Determine your [public IP address](#determine-your-public-ip-address)
2. Determine your [private IP address](determine-your-private-ip-address)
3. Browse to the management website for your home router ([http://192.168.1.1](http://192.168.1.1) for most routers)
4. Log in as admin
5. Find the section to configure port forwarding
6. Configure a port forwarding rule with the following values:
    - 9000 TCP and UDP (Nimbus/Lighthouse)
    - 9001 UDP (Lighthouse)
    - 30303 TCP and UDP (Geth)


## Determine your public IP address

To determine your public IP address, visit [http://v4.ident.me/](http://v4.ident.me/) or run this command:

```
curl v4.ident.me
```

## Determine your private IP address

To determine your private IP address, run the appropriate command for your OS:

```sh
ip addr show | grep "inet " | grep -v 127.0.0.1
```
