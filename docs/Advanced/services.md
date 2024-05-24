## Systemd Services

All clients use Systemd services for running. Systemd takes care of the processes and automatically restarts them in case something goes wrong. It can enable a service to automatically start it on boot as well.

Systemd command systemctl manages all operations related to the services. The available options are as follows:

- **Enable** - Activate the service to start on boot
- **Disable** - Remove the service from boot start
- **Start** - Start the client process
- **Stop** - Stop the client process
- **Restart** - Restart the clients process

The general syntax is:

``` sh
sudo systemctl enable|disable|start|stop|restart service_name.service
```

To check service output use **journalctl**

``` sh
journalctl -u serviceName.service -b
```
or continuously print new entries as they are appended to the journal
``` sh
journalctl -xefu serviceName.service
```

Example:
``` sh
journalctl -xefu w3p_nimbus-beacon.service
```

## List of services

<!-- - w3p_geth.service
- w3p_lighthouse-beacon.service
- w3p_w3p_nimbus-beacon.service
- w3p_bsm.service
- w3p_bnm.service
- grafana.service
- influxDB.service -->

### w3p_geth.service

Geth - Ethereum execution client

The w3p_geth.service file is a configuration file used to define a systemd service for running the Geth (Go Ethereum) client as a background service on Linux systems. Using w3p_geth.service, you can ensure that Geth starts automatically on boot, restarts on failure, and runs with specified parameters.

This service runs script located: **/home/ethereum/clients/geth/geth.sh**

``` sh
#!/bin/bash
geth --authrpc.port=8551 --http --http.port 8545 --http.addr 0.0.0.0 --http.vhosts '*' --ws --ws.port 8546 --ws.addr 0.0.0.0 --ws.origins '*' --authrpc.jwtsecret /home/ethereum/clients/secrets/jwt.hex --state.scheme=path --discovery.port 30303 --port 30303
```

If you need to change geth startup parameters edit this file and then restart service.

### w3p_lighthouse-beacon.service

Lighthouse - Ethereum consensus client

Maecenas ut augue ipsum. Donec eu erat et sem placerat faucibus. Vivamus quis venenatis lorem. Interdum et malesuada fames ac ante ipsum primis in faucibus. Nunc hendrerit leo eget enim pharetra placerat. Vivamus blandit dapibus felis, quis ultricies enim sagittis non. Phasellus eleifend posuere sapien. In tellus lacus, fermentum sit amet egestas a, feugiat vitae sapien.

### w3p_w3p_nimbus-beacon.service

Nimbus - Ethereum light weight consensus client

Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Vivamus efficitur, nibh ac consectetur mollis, urna sapien ultricies nibh, sit amet posuere diam mauris vel orci. Vestibulum interdum eget diam in mattis. Curabitur vulputate massa tempus, mattis nulla ut, maximus ipsum. Sed ex mauris, ornare et libero sit amet, molestie viverra mi. Nullam et orci eget lacus molestie efficitur. Aliquam quis tempor diam.

### w3p_bsm.service

Basic System Monitor

Aenean egestas neque massa, ac euismod urna gravida a. Vestibulum venenatis rutrum placerat. Praesent a consectetur diam. In convallis aliquet vehicula. Ut in ipsum eu neque mollis posuere. In vitae rhoncus nisl, at maximus turpis. Nullam nisi eros, rhoncus vel semper at, tristique ac justo. Curabitur in scelerisque augue, ac accumsan mauris. In a metus sed elit rutrum consequat. Curabitur maximus bibendum ligula dignissim sollicitudin. Ut tempor eros a odio lacinia, viverra commodo libero tempor. Praesent vel diam sagittis, pellentesque lacus sed, blandit ante. Donec in elementum nibh.

### w3p_bnm.service

Basic Node Monitor

Pellentesque scelerisque viverra sapien. Nunc hendrerit sapien ut tellus aliquet sollicitudin. Etiam rutrum sit amet eros a auctor. Curabitur ullamcorper malesuada risus, sed gravida elit. Nulla eu venenatis nulla. Cras fermentum justo nec felis viverra pellentesque. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nulla vel arcu a lorem consectetur scelerisque in sed risus. Integer laoreet fringilla quam. Curabitur molestie tincidunt odio, non placerat quam convallis et. Duis dignissim varius metus finibus interdum. Cras a rutrum ante.

### grafana.service

Grafana service

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin id lacinia urna, ac elementum tellus. Nullam id arcu mauris. Ut molestie, sem ut ultrices tincidunt, sem orci hendrerit urna, a sagittis nunc ex nec massa. Suspendisse egestas scelerisque viverra. Nam convallis, arcu gravida feugiat cursus, massa neque tincidunt lorem, viverra imperdiet metus dolor non lorem. Donec vitae lectus non est lobortis consectetur ut aliquam ligula. Fusce porttitor mi a tellus efficitur volutpat. Donec rutrum lorem non arcu elementum facilisis. Nam volutpat nisi nulla, sed tempor lacus faucibus eu. Aliquam hendrerit fringilla justo sed tincidunt. Suspendisse potenti.

### influxDB.service

InfluxDB service

Aenean mauris ante, mollis a dui quis, condimentum varius turpis. Phasellus vitae lobortis dolor, ac bibendum tortor. Aliquam erat volutpat. Nulla tincidunt lobortis mattis. Vestibulum et tempus risus. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Sed at lorem orci. Morbi non consectetur nibh, id laoreet metus. Cras quis est nunc. Nulla tristique, purus eget tempus mattis, turpis leo rhoncus ante, luctus eleifend diam justo in nulla. Aenean tempus vestibulum ex, ut dictum lorem luctus venenatis. Sed rhoncus molestie dictum. Nunc iaculis interdum molestie. Praesent efficitur tempor finibus.