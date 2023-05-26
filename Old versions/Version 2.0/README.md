---------------------------

 **ver2.0**

---

****version update****

v2.0 We can pipeline ADC to simple algorithm to DAC using four mics

------

****DESCRIPTION****

TOP.vhdl including:

- ACFC (ADC configuration flow controller)
- I2C
- New I2S receiver
- package ACFC
- package parameter
- Simple algorithm including: singleregister, shiftregister, powerestimation, max, panningaccumulator, fader, mixer 
- IP core - PLL
- DAC data-pipeline

TOP.vhdl workflow:

- ACFC decides how to configure ADC
- ACFC transmits value into I2C and launches I2C to push into ADC
- PLL generates MCLK
- ADC working
- I2S receiver collects DATA from ADC and sends the four channels to the algorithm
- SimlpeAlgorithm takes the inputs and enhances the audio with one output
- DAC outputs the audio
-----

****if you want to run it in vivado project****

- Take the TOP bitstream file from bitsream folder, and put it on an SD card. Insert the SD card to the FPGA and fix the two jumpers on the FPGA to select SD mode. The project should now work if you insert power to the FPGA.