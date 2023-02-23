ADC wrapper without i2s

-------

-test
-design
-vivado
|--bits
|--constraints

---------------



2023/02/01

create for storing finished compiled design and bitstream. not for isolated design.



2023/02/09

controller-i2c are finished. logical analyser said good.



2023/02/10 - 11

successfully configurate ADC by

- add PLL in FPGA to generate MCLK of 16MHz 

- add control-flow for ADC: I2S output + master mode + GPIO config + FSYNC_BCLK config
- correct timing in i2c
- rewrite fsm's order