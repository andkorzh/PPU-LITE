A test version of the firmware with support for VGA output. Resolution: 640×480 at 60 Hz.
Important points for proper implementation:
This works only in NTSC mode (clock frequency 21.47727 MHz). To activate VGA mode, you must connect the pin to the ground, as shown in the image below. 
You also need to install 100-ohm 0805  resistors and jumpers for the HSYNC and VSYNC pins, as illustrated in the image.

<img width="1544" height="901" alt="VGA_OUT_ON" src="https://github.com/user-attachments/assets/48d051fc-c0be-4aa7-aed8-bc774885c689" />
