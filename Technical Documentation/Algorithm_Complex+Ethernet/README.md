
---

<font size=4>***Complex Algorithm***</font>

V3.0 and forwards. We connect ADC-DAC blocks with the complex algorithm which is based on cross-correlation to calculate the position of an actor.
The distance in pixels is displayed on the FPGA 7-segment display. Ethernet is still present, we can send real captured ADC data to a PC through the Ethernet. 

------

<font size=4>***DESCRIPTION***</font>



-- TOP.vhdl including:

- ACFC (ADC configuration flow controller)
- I2C
- New I2S receiver
- package ACFC
- package parameter
- **Complex-Algorithm including:**
  - _parameter_
  - _BRAM_
  - _shift register_
  - _xcorr_
  - _PositionSolverImager_
  - _LUT.coe_
  - _maxLUT_
  - _Attenuation compensation_
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

- **Complex-Algorithm takes the inputs and enhances the audio with one output.**

- DAC outputs the audio processed by the algorithm.

  
-----

<font size=4>***if you want to run it in Vivado project***</font>

- Take the TOP bitstream file from bitsream folder, and put it on an SD card. Insert the SD card to the FPGA and fix the two jumpers on the FPGA to select SD mode. The project should now work if you insert power to the FPGA.