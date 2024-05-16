## JSON-RPC API
When JSON-RPC API is enabled, your **Ethereum Node** may serve as a Web3 Ethereum endpoint. For example, Ethereum Web3 library implementations require access to a Web3 endpoint to perform the blockchain queries.

### Web3 Endpoint
There are a few options for accessing Web3 endpoints, such as Infura, but more importantly, a local **Ethereum Node** may also serve this purpose. _Some use cases require firing thousands of Web3 requests to an endpoint which results in quick depletion of API calls in paid services providing those endpoints. Having a local one at your disposal solves this problem completely._

By default, the devices should be connected to a LAN and accessible by other devices in the same subnet. Using the naming convention from this document, the JSON-RPC Web3 endpoint is hosted as `http://geth-1.local:8545`.

Two examples of providing a local endpoint in a local network to a Web3 library can be found below:
- Python interface to Web3 (_web3.py_)
  ```python
  from web3 import Web3
  
  w3 = Web3(Web3.HTTPProvider("http://geth-1.local:8545"))
  ```
- JavaScript interface to Web3 (_web3.js_)
  ```js
  // In Node.js use: const Web3 = require('web3');
  
  const web3 = new Web3("http://geth-1.local:8545");
  ```

### Examples and Documentation
Here are a few different examples of how a local RPC endpoint may be used in existing applications:
- [Python example](https://web3py.readthedocs.io/en/stable/providers.html#httpprovider)
- [JavaScript example](https://www.quicknode.com/guides/ethereum-development/getting-started/connecting-to-blockchains/how-to-connect-to-ethereum-network-with-web3js#connecting-via-web3)
- [Metamask example](https://support.metamask.io/hc/en-us/articles/360015290012-Using-a-local-node)
