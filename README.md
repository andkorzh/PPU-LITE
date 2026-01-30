The cheapest, clock-accurate FPGA replacement for PPU, created using reverse engineering.
I decided to develop a cheaper FPGA-based alternative to the RGB-PPU, as the original design called for a 4-layer PCB, which is quite expensive even from China.  
Therefore, I exclusively used a double-sided PCB. Also, board size was an initial concern, so to avoid reinventing the wheel, I used the NESRGB size, which, 
thanks to adapters, can be installed in any original console. The FPGA was the cheapest and oldest Cyclone I EP1C3T100C8N in a 100-pin package. 
Similar to the NESRGB, a discrete R2R-based DAC with resistor arrays, 6-bit plus one-bit emphasis per channel, was used instead of the ADV7125. 
All these measures are intended to significantly reduce the final cost and simplify the availability of certain components in these challenging times.  
Taking all of the above into account, a project was prepared in Quartus and successfully tested. It would have been possible to implement it on Lattice, 
thus eliminating the need for configuration flash memory, as it's integrated into the chips in Lattice FPGAs, but I'm not particularly keen on learning a new ecosystem. 
The prototype contains three built-in palettes that can be switched via jumpers on the board. 
This project can implement up to four palettes without increasing the number of currently used FPGA pins.

![IMG_4894](https://github.com/user-attachments/assets/9ada40e9-d883-4320-9fcf-176d6f9977e4)


resources used by the FPGA

<img width="368" height="247" alt="compreport" src="https://github.com/user-attachments/assets/06a608a1-2648-4466-9abd-d4cf4f819974" />

Video on YouTube:  https://www.youtube.com/watch?v=B2EgrhUERuM

Attention! The board only has a JTAG configuration interface. Please upload only the jic file. If you try to upload the pof file, you will receive an error.

Added project to Lattice Diamond 3.5 and Gerber PCB files for Lattice.

![IMG_4940](https://github.com/user-attachments/assets/40172f55-f539-4da1-b75b-03f9e6a6c7df)

Contains 8 palettes:

000 - NES CLASSIC
001 - NATURAL NESTOPIA YUV
010 - SMOOTH
011 - SONY CXA
100 - CDirect
101 - PC 10
110 - WaveBeam
111 - PWM Style
