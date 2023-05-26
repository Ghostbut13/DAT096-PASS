

---

<font size=4>***Version update***</font>

v2.0 We can pipeline ADC to simple algorithm to DAC using four mics
v2.1 We can also send the four channels data through Ethernet and read the actual data from the ADC to the computer

------

<font size=4>***DESCRIPTION***</font>



-- TOP.vhdl including:

- ACFC (ADC configuration flow controller)
- I2C
- New I2S receiver
- package ACFC
- package parameter
- **Simple-Algorithm including:**
  - _single register_
  - _shift register_
  - _power estimation_
  - _max_
  - _panning accumulator_
  - _fader_
  - _mixer_

- IP core - PLL
- **UDP_ethernet**
- CRC32_D8.v 
- DAC data-pipeline



-- TOP.vhdl workflow:

- ACFC decides how to configure ADC (using FSM)

- ACFC transmits value into I2C and launches I2C to push value into ADC

- PLL generates MCLK to ADC, such that ADC can generate BCLK and FSync from it.

- ADC working...

- I2S receiver collects DATA from ADC and sends the four channels -- ***left1 left2 right1 right2***-- to the algorithm.

- Ethernet supports 100M high speed for real-time audio data transmission every fsync.

- When both the datapath and Ethernet are enabled, audio data can be transmitted from the FPGA port to the PC port for further analysis.

- **Simlpe-Algorithm takes the inputs and enhances the audio with one output.**

- DAC outputs the audio processed by the algorithm.

  
-----

<font size=4>***if you want to run it in Vivado project***</font>

- Take the TOP bitstream file from bitsream folder, and put it on an SD card. Insert the SD card to the FPGA and fix the two jumpers on the FPGA to select SD mode. The project should now work if you insert power to the FPGA.