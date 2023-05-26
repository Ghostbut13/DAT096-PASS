# <font size=6>**Speech Enhancement for Theatre Stages Using Linear Microphone Array:**</font>

----------------



## <font size=5>**Specification**</font>

- This project aims to capture audio using a linear microphone array and process it using a FPGA finally output the processed audio. The linear array consists of four microphones that are being connected to hardware using AD converters, then processed by an FPGA and output through a DA converter.

- There is two different implementations of audio combination labeled as a simple and a complex algorithm.

The simple algorithm uses power estimation to determine the best source microphone. The complex algorithm calculates the position of an actor to compensate for attenuation.


<br>

----



## <font size=5>**What is our project NOT for...?**</font>
- ...Any aim for commercial application since it is a ***prototype*** on FPGA only.

- ...Application in strong noise scenes since we have no ***tested-well filter*** yet.

- ...Application in small closed space since ***audio feedback***.

- ...Arbitrary amount of data in audio for 100MHz Ethernet communication since we need to send all of data in one sample-rate (_FSYNC_) clk.

- ...Ethernet configuration in the software/abstract layers.

  

## <font size=5>**What is our project for...?**</font>

- ...An Education, research platform for hardware and MATLAB algorithm design.
- ...Simple 4-channel "_Stereo Panorama_" rebuilding in open scenes (like big lecture room, theater) thanks to good channel select/pan algorithm.
- ...Good extensible controller for _PCM6240_Q1_ ADC.
- ...100MHz high-speed audio realtime communication to PC through Ethernet in 48KHz FSYNC.
- ...Environment data set collecting and sequential analyzing since Ethernet.
- ...Two alternative channel select/pan algorithms.



## <font size=5>**What can be better in future?**</font>

- **Branch A**  --- Algorithm in MATLAB

  - "_Any algorithm substitution ??_ ". 
  - Suitable ***filter*** cutting up ***audio feedback***.
  - Suitable filter improving noise.
  - Suitable quantization parameters for testing. 

- **Branch B**  --- Algorithm mapping into VHDL

  - Improving the quality of code to get ***lower hardware utilization***.
  - Better testbench for more coverage.
  - Pipeline design for better performance.

- **Branch C**  --- Communication

  - Add a control unit for all blocks (or only for Ethernet).

  - Better ***Big/small endian converting*** in Ethernet datapath (header, data and CRC).

  - Linear Feedback Shift Register (**_LFSR_**) for CRC in Ethernet.

  - Improving the interface between ADC and FPGA by using hardware design techniques.

    (https://www.analog.com/en/technical-articles/interfacing-fpgas-to-an-adcs-digital-data-output.html)

  - Suitable encoding and checksum in the audio data path.

- **Branch D**  --- Others

  - Reducing switches.
  - Add display terminal.

<br>


------



## <font size=5>**Block Diagram and System Introduction**</font>

![Block_Diagram](https://github.com/Ghostbut13/DAT096-PASS/blob/main/Diagram/DAT096-Block_Diagram.png)

(Fig.1 Block Diagram)

The system consists of FPGA, peripheral ADC + DAC. Four microphones as Left1/2-Right1/2 channels sample analog audio and ADC will convert data to digital. **I<sup>2</sup>S receiver** operates at a sample rate of 48Khz and a BCLK-FSYNC ratio of 256, splitting the audio into four 16-bit word length. We prepare two **algorithms** for panning channels according to acoustic source distance off each microphone. A virtual distribution figure shows the correct position estimation out of ***timing-delay*** or ***power estimation***, respectively in two algorithms.  Align with enhancement and filter, the algorithm part enhances the acoustic performance. DAC, the end of the *data path*, can output the processed audio stream. 

To customize the peripheral ADC parameters, such as the I<sup>2</sup>S protocol and differential input, it is necessary to configure the relative registers in the ADC using *control path*. The **I<sup>2</sup>C master** provides valid control information writing mechanisms to ADC, and the **ADC-Configuration-Flow-Controller (_ACFC_) ** manages the priority, location, and implicit value of the register writes based on the datasheet and datapath requirements. MCLK is generated from **PLL module** as the source clock for ADC.

\* _ADC is PCM6240_Q1, DAC is DC2459C, FPGA is Nexys 100T._

<br>


## <font size=5>**ADC Wire connection to FPGA Installation and Setup** </font>
![Block_Diagram](https://github.com/Ghostbut13/DAT096-PASS/blob/main/Diagram/ADC_connection.jpeg)
(Fig. The connection of the ADC)

We can see that only J11, 12, 13, 14 and J27 are installed for the input signals of the ADC. The rest  are uninstalled. MCLK is connected to the left pin of GPIO1, because we have the ADC as master. You should also resolder a zero ohm resistor on the back, to allow the ADC to run in master mode. Remove R21 and replace it to R22. 

## <font size=5>**Installation and Setup** </font>
To run the project by your own, you need to establish the communication with ADC. You need to push the switches in order. The switches on the FPGA (From 1 to 6):
{ SW_vdd_ok } —— Start ACFC.  Let be on logical 1

{ SHDNZ_ready }  ——  Shutdown ADC. Set to 1 then switch to 0 . 

{ GPIO_MCLK }  —— configure GPIO1 as MCLK input.  Set to 1 then switch to 0 . 

{ master_mode }  —— configure device as master. Set to 1 then switch to 0 .

{ FS_48k_256_BCLK }  —— FS: 48K, BCLK: 12.288M. Set to 1 then switch to 0 . This set the relationship between BCLK and FSYNC  

{ I2S_mode }  —— output data I2S. Set to logical 1.
After doing the last step, you should start getting audio data from the DOUT pin of the ADC. This can then be mapped through the audio capturing protocol.

For exact connection between the ADC and FPGA, check the constraint file.

To start the algorithm, you need to first set the switch number 14 to 1. This sets ENABLE_ALGORITHM to one. Then set switch 15 to 1 to enable I2S. If you want to send data through Ethernet, set switch 15 to one.

## <font size=5>**Algorithm Design (Extraction + Addressing + Combination)** </font>


As the core of the system, we designed and tested the algorithms' structure consisting of multiple entities.

The key thought is that algorithms should **extract** acoustic information from audio in each channel and **combine** them into "_join force_". It is possible to **calculate** the 2D position profile according to this _force_.

- The _cross-correlation_ extracts the signal similarity between 1-2, 2-3, 3-4 channels.
- Calculation resources are rarely such that we pre-store all possible 2D positions in ROM, rather than real-time calculation. In other words, we replace calculation with **addressing** operations by sacrificing the performance (refresh rate = 0.5 ms) in an acceptable range.
- The _Picture Creator_ is a control unit to **address** the ROM.
- The _ADD_ and _MAX_ ***combine*** the output from _Picture Creator_.

![Block_Diagram](https://github.com/Ghostbut13/DAT096-PASS/blob/main/Diagram/complex_algo_description.png)

(Fig.2 Complex algorithm)

<br>

##  <font size=5>**Communication between MATLAB and FPGA**</font>

The 100 MHz high-speed **Ethernet** port supported by Nexys 100T, facilitates the efficient transmission of 64-bit audio streams in Lab environment to a PC to polish up our algorithm design. An Ethernet frame comprises headers, data, and Cyclic Redundancy Check (CRC). The headers are parsed by the PC receiver to extract information such as MAC and IP addresses, as well as the transmission protocol. The ***User Datagram Protocol (UDP)*** provides a concise and reliable transmission mechanism for real-time audio data, making it the preferred option over ***Transmission Control Protocol (TCP)***. Additionally, the received data and the checksum can be verified using the CRC.

MATLAB provides a toolbox to receive streams through UDP, also, like what we used, there is a free but powerful tool '**_Wireshark_**'  monitoring all traffic visible on PC interface. Time stamps and source/destination will help us to analyze data.



<br>

## <font size=5>**KEY Parameters**</font>

- Audio: I<sup>2</sup>S audio format with 48kHz FSYNC, 12.288MHz BCLK, and 16-bit word length. Input is in two's complement.
- Ethernet: 100MHz; the frame is 50  + 18 + 4 = 72 bytes, takes in 5.76 us.
- I<sup>2</sup>C: 




<br>

-----



## <font size=5>**VHDL Design Details**</font>

A file tree to show our project design: 

### \***<font size=4>TOP.vhdl </font>**

- **Control unit:**
  - ACFC (ADC configuration flow controller)

- **Interface in control path**

  - I<sup>2</sup>C master

-  **Interface in datapath**:
   - I<sup>2</sup>S receiver



-  **Interface in Ethernet**:

   - UDP_ethernet

   - CRCr

 - **Simple-Algorithm :**
    - single register
    - shift register
	- power estimation
    - MAX
   - panning accumulator			
   - fader
   - M​ixer

- **Complex algorithm**:
  - High pass filter
  - BRAM 
  - cross-correlationn
  - Positionor
  - Attenuation compensation
  - Mixer
  - Low pass filter
  - 7segment



- **other files**

PLL12M : This is done by using the clocking_wizard IP block
LUTv : This is done by using the block memory generator IP block
LUT.coe is the file that is used in the block. This is a ROM.
PictureFrame : This is done by using the block memory generator IP block. This is BRAM.

<br>

<br>

### <font size=4>FSM in ACFC, I<sup>2</sup>C, and Ethernet</font>

FSM design is used widely in the control unit and interfaces. A **_half-fixed_ **big FSM in ACFC decides WHERE and WHAT we need to write to registers in ADC to configure it (so common in any chip configuration way). We fixed the order of key-configuration states like ***START***, ***RELEASE_ SOFT_SHUTDOWN***, ***ENABLE_CHANNEL,*** etc... apart from which, like decides FSYNC, BCLK, MASTER_MODE, AUDIO_FORMAT, is in ***unfixed code region***. That means we hew a stall state (region) up to wait for configuration by out-of-order switches.

```vhdl
--The Brain
case state is
  when idle_state =>  
	....         
  when woke_state =>              
	....  
  -----------------------------------------------------------------------
  - unfixed code region
  -----------------------------------------------------------------------
  when config_and_programm_state =>  
    if flag_finish_config_progr = '1' then
      next_state <= powerdown_state;
    else
      next_state <= config_and_programm_state;
    end if;
  -----------------------------------------------------------------------

  when powerdown_state  =>   
   	....
  when  config_channel_1_state =>   
  	.
  	.
  	.
  	.
  when stop_state =>
    next_state <=  waiting_state;
  when waiting_state =>
    next_state <=  waiting_state;

```

Each of the states in this ***FSM*** will call a small ‘***fsm***’ which implements I<sup>2</sup>C (master) protocol with fixed timing and format,   to write value into ADC. The relation between ***FSM*** and ***fsm*** is analog to Brain and Hand - the brain makes decisions and controls the Hand to write.
<br>



<div align=center><img src="https://github.com/Ghostbut13/DAT096-PASS/blob/main/Diagram/ACFC_and_I2C_fsm.png"    height = "500" /></div>

(Fig.3 FSM-fsm)

<br>

So we provide the '_start_',  '_config\_addr_', and '_config\_value_' input ports as Brain's commands for I<sup>2</sup>C. And the '_done_' output port will tell ACFC when I<sup>2</sup>C writing process is over. 

```vhdl
--The hand
entity I2C_Interface is
  port (
    clk  : in std_logic;
    rstn : in std_logic;
    -- signals between i2c and ACFC
    start : in std_logic;
    done : out std_logic;
    config_addr : in  std_logic_vector(7 downto 0);
    config_value : in  std_logic_vector(7 downto 0);
    -- i2c communication
    SDA : inout std_logic;
    SCL : out std_logic
    );
end entity I2C_Interface;
```

<br>

SCL provides the clock reference for I<sup>2</sup>C communication from a master. SDA falls when SCL = '1' represents a _launch_ then SCL will pulse at a fixed frequency to transmit data through SDA in every 8 bits PLUS 1 bit, to receive acknowledge. In other words, we set 9 states to send 8 bits and the last state is ACK state. 

Registers' addresses and values are 8 bits that 2×9 states in two launch-set can configure one register in PCM6240_Q1. Before this two-launch, however, we also need one more launch-set to appoint to the I<sup>2</sup>C slave address (fixed in datasheet) in case there are any other slaves sharing common bus (see in Fig.3).

<br>

### <font size=4>Serial-to-Parallel in I<sup>2</sup>S</font>

Serial stream mixtures 4 channels audio in SDOUT. Simple counter or fsm design can parallel channels in one FSYNC cycle since the channels' wordlength and BCLK is same one. NOTE: The audio captured is in  two's complement, with the MSB as first bit.

```vhdl
--The hand
ENTITY I2S IS
  PORT  (
    bclk:IN STD_LOGIC ;
    start:IN STD_LOGIC ;
    reset:IN STD_LOGIC ;
    fsync:IN STD_LOGIC ;
    DIN : IN STD_LOGIC;
    L1_out : out std_logic_vector (15 downto 0); --mic 1
    L2_out : out std_logic_vector (15 downto 0);
    R1_out : out std_logic_vector (15 downto 0);
    R2_out : out std_logic_vector (15 downto 0)  --mic 4
    );
END ENTITY I2S;

if (start = '1') and (reset /= '0') then
          if fsync='0' then
            go to left_channel_1_state;
          when left_channel_1_state
            count to 16 then left_channel_2_state
          when left_channel_2_state
            wait for fsync = '1' then count to 16 then 	
            right_channel_1_state
          when right_channel_1_state
           count to 16 then wait for fsync='0'
          when fsync = '0' 
           release all register values to the algorithm       
```
<br>

### <font size=4> IP core design in PLL, ROM and BRAM</font>

Xilinx provides IP core to assistant design.  

We use the clocking_wizard IP to generate an exact 12.288MHz clock that is used to synchronize the captured data by I2S. In the IP GUI, we only use in1, reset_n and out1. This means that the reset should be active low. The input clock is 100MHz and the desired output should be set to 12.228MHz.

 LUTv is a ROM to give the algorithm a fixed picture of the stage. It is look-up-table with vectors for each pixel in each correlation line. 12 bits of position data (6 bit X and 6 bit for Y), 95(128) points per line, 140 lines (17920). It's generated using block memory generator IP. Set as single port ROM. width: 12 bits, length 17920. Load LUTv.coe as inital value. Always enabled.


PictureFrame block: Picture frame to store image from each cross-correlation.  32 bit depth of grayscale value, 64 by 128 pixels. It's also generated using block memory generator IP.  Set as simple dual port RAM. Read first. width: 32, length 8192. common clock. Always enabled.

<br>

<br>





## <font size=5>**TOP.vhdl workflow** (_Final version_)</font>



- ACFC decides how to configure ADC (using FSM)

- ACFC transmits value into I<sup>2</sup>C and launches I<sup>2</sup>C to push value into ADC

- PLL generates MCLK to ADC, such that ADC can generate BCLK and FSYNC from it.

- ADC working...

- I<sup>2</sup>S receiver collects DATA from ADC and sends the four channels -- ***left1 left2 right1 right2***-- to the algorithm. Note: The signal is in two's complement.

- Ethernet supports 100M high speed for real-time audio data transmission every FSYNC.

- When both the datapath and Ethernet are enabled, audio data can be transmitted from the FPGA port to the PC port for further analysis.

- **Simple-Algorithm takes the inputs and enhances the audio with one output. That is based on power estimation**

- **Complex-Algorithm takes the inputs, puts them through low-pass filter, then does cross-correlation and prints the correlation lines on a LUT.  One output is combined from the four attenuation compensation blocks..**

- DAC takes the audio signal in two's complement, inverts it to unsigned, then outputs the audio processed by the algorithm.

<br>


---



## <font size=5>**Test Environment**</font>
There are input files found. These files can be used for behavioral verification. To verify the output, you could save the output in big file, then plot the result in MATLAB and verify the behavior.

### <font size=4>Switches Assignment</font>

(fig here)

As introduced before, switches work in unfix region but also to start (or reset) some modules like Ethernet and Algorithm. 



<br>

### <font size=4>Signal Stimuli and Speaker</font>

Wave generator was used to test the pipeline between the ADC and DAC. Without a working path, the algorithm will not perform as expected. The ADC data was captured through the Ethernet, and then saved as input files. This can help the developer make a testbench that takes them as input and verify the algorithm.

<br>

### <font size=4>Microphone and Data</font>



<br>




