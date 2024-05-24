## Building Image
To build a new image, you have to run a custom image-building tool.

### Default
To generate the image from the newest Ethereum On Arm Image template, use the following commands from the directory where the Ethereum On Pi repository is cloned:
```bash
cd tools/images/raspberry_pi/rpi4
./image_builder.sh
```

The _image_builder.sh_ executed without arguments will:
- Download the latest Ethereum On Arm image
- Reconfigure the downloaded image as a new Ethereum On Pi image
- Write and zip-compress the resulting image

\
_Bear in mind that the above script was only **tested on Ubuntu**._

### Advanced

The _image_builder.sh_ tool can be used with custom input arguments to specify input image, output image, and even _rc.local_ installation script that will be used by the image during initial device configuration.
To list all the options, run the command:
```bash
./image_builder.sh -h
```

🚧 TODO: more details to follow  🚧 
