## SSH key-based authentication
SSH key-based authentication can be used to make it easier to access devices. A detailed description of the process can be found [here](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server). For Windows users, an additional tutorial for configuring [PuTTY](https://www.putty.org/) can be found [here](https://www.techtarget.com/searchsecurity/tutorial/How-to-use-PuTTY-for-SSH-key-based-authentication).

### Initial Configuration
To configure key-based access to the device without additional customization, follow the steps below (Linux only):
- Login to the machine that will be connecting to the **device** and generate an SSH key pair (do not change the default output directory)
  ```bash
  ssh-keygen
  ```
  
- Based on your security requirements, either enter a passphrase to additionally protect the private key or leave it without a passphrase
  
- Once the keys are generated, copy public keys to the device(s) to which you want to connect using key-based authentication
  ```bash
  ssh-copy-id username@remote_device
  ```
  Once this command is finished, the id_rsa.pub has been uploaded to the `remote_device`

- You can now log into the **remote device** without a password by typing `ssh username@remote_device` or simply by executing the command `ssh remote_device` if the current user already exists on the **remote device**

### Examples
You can conveniently copy keys across devices to make further configuration steps easier. A step-by-step example of setting up a two-way SSH key-based authentication between _geth-1_ and _lighthouse-1_ is shown below.

#### geth-1 device 
Valid for the default user: _ethereum_
- SSH login to _geth-1_
  
- Generate an SSH key pair **if necessary**
  ```bash
  ssh-keygen
  ```
  
- Copy public key to the _lighthouse-1_
  ```bash
  ssh-copy-id lighthouse-1.local
  ```

You can now SSH login from the _geth-1_ device into the _lighthouse-1_ device without the password.

#### lighthouse-1 device 
Valid for the default user: _ethereum_
- SSH login to _lighthouse-1_
- Generate an SSH key pair **if necessary**
  ```bash
  ssh-keygen
  ```
- Copy public key to the _geth-1_
  ```bash
  ssh-copy-id geth-1.local
  ``` 

You can now SSH access the _geth-1_ and _lighthouse-1_ devices from each other without the password.
