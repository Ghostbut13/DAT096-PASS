TOP.vhdl including:

- ACFC (ADC configuration flow controller)
- I2C
- I2S receiver
- pkg
- IP core - PLL



TOP.vhdl workflow:

- ACFC decides how to configure ADC
- ACFC transmits value into I2C and launches I2C to push into ADC
- PLL generates MCLK
- ADC working
- I2S receiver collects DATA from ADC and outputs them on 4 channels signal (for v1.4, we only test 1 channel)