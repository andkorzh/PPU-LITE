A test version of the firmware with support for VGA output. Resolution: 1280×960 at 60 Hz.
Important points for proper implementation:
This works only in NTSC mode (clock frequency 21.47727 MHz). To activate VGA mode, you must connect the pin to the ground, as shown in the image below. 
You also need to install 100-ohm resistors and jumpers for the HSYNC and VSYNC pins, as illustrated in the image.
