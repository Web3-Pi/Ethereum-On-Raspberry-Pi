The config.txt file is a configuration file used by the Raspberry Pi to set various system parameters and options before the operating system boots. This file is located on the boot partition of the SD card and is critical for hardware configuration and behavior. 

The config.txt file is a powerful tool to customize the behavior and performance of your Raspberry Pi, allowing you to tailor it to your specific needs and use cases.

The `config.txt` file on a Raspberry Pi can include sections that allow for conditional configuration based on the model of the Raspberry Pi or other conditions. These sections help to apply specific settings only to certain models or under certain circumstances. This feature is particularly useful when the same SD card is used across different Raspberry Pi models, ensuring that each model gets the appropriate settings.

### Sections in `config.txt` aka. Conditional filters

#### `[all]`  
- **Purpose:** Settings under this section are applied to all Raspberry Pi models.
- **Usage:** General settings that should be universally applied, regardless of the specific model.
  
```ini
[all]
disable_splash=1
dtparam=spi=on
```

#### `[pi4]`
- **Purpose:** Settings under this section are applied specifically to Raspberry Pi 4 models.
- **Usage:** Model-specific settings, such as those related to hardware unique to the Raspberry Pi 4.

```ini
[pi4]
arm_freq=1500
gpu_mem=256
```

#### `[cm4]`
- **Purpose:** Settings under this section are applied specifically to the Compute Module 4.
- **Usage:** Model-specific settings for the Compute Module 4.

```ini
[cm4]
arm_freq=1500
gpu_mem=256
```

#### `[other]`
- **Purpose:** This is a catch-all section for any Raspberry Pi models that don't match the specified sections.
- **Usage:** General fallback configurations.

```ini
[other]
arm_freq=800
gpu_mem=64
```

### Eth On Rpi extension

Ethereum On Raspberry Pi extends this file by adding new section:

#### `[web3pi]`  
- **Purpose:** Settings under this section are applied to Ethereum On Raspberry Pi software.
- **Usage:** Ethereum On Raspberry Pi services settings.
  
```ini
[web3pi]
geth=true
#nimbus_light=true
nimbus=true
lighthouse=false

# Monitoring
influxdb=true
grafana=true
bsm=true
bnm=true
```

#### `[nimbus]`  
- **Purpose:** Settings under this section are applied to Nimbus software.
- **Usage:** Settings for Nimbus software.
  
```ini
[nimbus]
# Choose how to run Nimbus by setting "nimbus_run_mode" to one of the below options: 
# full_sync   - before run Nimbus sync db with trusted node
# quick_sync  - before run Numbus sync only head and backfill later
# run         - do not sync before run Numbus. Just run Nimbus client
nimbus-run-mode=full_sync
nimbus-trusted-node-url=http://18.194.243.122:30307
```


### Conclusion

By using these sections and conditional filters, you can create a versatile and adaptable `config.txt` file that automatically applies the correct settings for each Raspberry Pi model and configuration.
