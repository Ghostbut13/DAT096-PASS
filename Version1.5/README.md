---------------------------

 **ver1.5**

---

****version update****

v1.1 can configurate ADC.

v1.2 can catch data from ADC to FPGA.

v1.4 can convert audio input into digital signals by ADC.

v1.5 can convert audio input into digital signals by ADC and pipelines data to DAC. Signal regenerated on DAC.

(v1.* only use one channel.)

------

****DESCRIPTION****

TOP.vhdl including:

- ACFC (ADC configuration flow controller)
- I2C
- I2S receiver
- package
- IP core - PLL
- DAC data-pipeline

TOP.vhdl workflow:

- ACFC decides how to configure ADC
- ACFC transmits value into I2C and launches I2C to push into ADC
- PLL generates MCLK
- ADC working
- I2S receiver collects DATA from ADC and outputs them on 4 channels signal (for v1.4, we only test 1 channel)

- because of no configuration for DAC, we pipeline the data directly to DAC 
- data types between ADC and DAC are diff, have to convert by pulsing a zero-bias.

-----

****if you want to run it in vivado project****

- make sure you download and add vivado to your system environment variables.
- click launch.bat, and automatically run synthesis and implementation on your local laptop.
- finally, open GUIi and you write bitstream into FPGA manually.