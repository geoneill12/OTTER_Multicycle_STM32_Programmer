# OTTER Multicycle STM32 Programmer

This project was motivated by the tediousness of having to re-synthesize an entire hardware design in Vivado everytime I wanted to load a new program onto the OTTER's memory. This can sometimes take 10-15 minutes depending on the design, and makes software testing extremely slow. Even if I just wanted to change a single variable and see how it behaved on the OTTER, I still had to re-synthesize everything and generate a new bitstream.

By integrating a programming module onto the OTTER, we can access the memory directly, and overwrite the contents with the help of a microcontroller. This project uses the NUCLEO-L476RG board to do exactly that, and can over-write memory at a data rate of 1.65 MB/s! (Megabytes!).

Refer the to file "OTTER_Programmer_Procedure.pdf" for a step-by-step breakdown on how to set everything up.

Happy programming!
