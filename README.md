# <font size=6>**FPGA implementation microphone system for a theatre stage:**</font>

----------------



## <font size=4>**Specification**</font>

- In the theatre it’s sometimes hard to hear what’s being said since the actors want to speak in a natural voice; shouting when acting in a play would be strange. Since this is a problem people have been looking into ways to solve this. An obvious solution is to use microphones but it will look awkward if the actors go round holding microphones, so we need another way. In most cases we don’t want to give full amplification of the voices but just some gentle boost and support to the voice coming from the stage.

- In this project, we will use a small number of audio microphones. Our system uses four microphones that are being connected to hardware using AD converters, then processed by an FPGA and output through a DA converter.

- We will start by activating only one microphone at a time but then we will move to a solution where the microphones are panned and have different levels of activation to make the transition between the sources more gentle. Some type of user interface to adjust settings is preferable. It could be in the form of a terminal or a GUI.

- Optional parts of the project include filtering of the sound to enhance the quality and reduce noise. There are several options such as: 
  1.	High-pass and low-pass filter - optionally with variable cutoff frequencies. 
  2.	Sweepable filter with damping/amplification and variable Q.
  3.	Adaptive filter for elimination of positive audio feedback from speaker to microphone.



----



## <font size=4>**What is our project NOT for...?**</font>

- ...Any aim for commercial application since it is a ***prototype*** on FPGA only.

- ...Application in strong noise scenes since we have no ***tested-well filter*** yet.

- ...Application in small closed space since ***audio feedback***.

- ...Arbitrary amount of data in audio for 100MHz Ethernet communication since we need to send all of data in one sample-rate (_FSYNC_) clk.

- ...Ethernet configuration in the software/abstract layers.

  

## <font size=4>**What is our project for...?**</font>

- ...An Education, research platform for hardware and MATLAB algorithm design.
- ...Simple 4-channel "_Stereo Panorama_" rebuilding in open scenes (like big lecture room, theater) thanks to good channel select/pan algorithm.
- ...Good extensible controller for _PCM6240_Q1_ ADC.
- ...100MHz high-speed audio realtime communication to PC through Ethernet in 48KHz FSYNC.
- ...Environment data set collecting and sequential analyzing since Ethernet.
- ...Two alternative channel select/pan algorithms.



##　\*<font size=4>**What can be better in future?**</font>

- **Branch A**  --- Algorithm in MATLAB

  - "_Any algo substitution ??_ ". 
  - Suitable ***filter*** cutting up ***audio feedback***.
  - Suitable filter improving noise.
  - Suitable quantization parameters for testing. 

- **Branch B**  --- Algorithm mapping into VHDL

  - Improving the quality of code to get ***lower occupied space***.
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




------



## <font size=4>**Block Diagram and System Introduction**</font>

![Block_Diagram](https://github.com/Ghostbut13/DAT096-PASS/blob/main/Diagram/DAT096-Block_Diagram.png)

The system consists of FPGA, peripheral ADC + DAC. Four microphones as Left1/2-Right1/2 channels sample analog audio and ADC will convert data to digital. **I^2^S receiver **operates at a sample rate of 48Khz and a BCLK-FSYNC ratio of 128, splitting the audio into four 16-bit wordlengths. We prepare two **algorithms** for panning channels according to acoustic source distance off each microphone. A virtual distribution figure shows the correct position estimation out of *timing-delay* or *power estimation*, respectively in two algorithms.  Align with enhancement and filter modules, the algorithm part enhances the acoustic performance. DAC, the end of the *data path*, can output the processed audio stream. 

To customize the peripheral ADC parameters, such as the I$2$S protocol and differential input, it is necessary to configure the relative registers in the ADC using *control path*. The **I$2$C master** provides valid control information writing mechanisms to ADC, and the **ADC-Configuration-Flow-Controller (_ACFC_) module** manages the priority, location, and implicit value of the register writes based on the datasheet and datapath requirements. MCLK is generated from **PLL module** as the source clock for ADC.

\* _ADC is PCM6240_Q1, DAC is DC2459C, FPGA is Nexys 100T._





## <font size=4>**MATLAB algorithm design** </font>

As core of the system, we have designed and tested the algorithm's structure consisting of multiple sub-modules.

(add more)



##  <font size=4>**Communication between MATLAB and FPGA**</font>

The 100 MHz high-speed **Ethernet** port supported by Nexys 100T, facilitates the efficient transmission of 64-bit audio streams in LAB environment to a PC to polish up our algorithm design. An Ethernet frame comprises headers, data, and Cyclic Redundancy Check (CRC). The headers are parsed by the PC receiver to extract information such as MAC and IP addresses, as well as the transmission protocol. The ***User Datagram Protocol (UDP)*** provides a concise and reliable transmission mechanism for real-time audio data, making it the preferred option over ***Transmission Control Protocol (TCP)***. Additionally, the received data and the checksum can be verified using the CRC.

MATLAB provides a toolbox to receive streams through UDP, also, like what we used, there is a free but powerful tool '**_Wireshark_**'  monitoring all traffic visible on PC interface. Time stamps and source/destination will help us to analyze data.



## <font size=4>**KEY Parameter**</font>

- Audio : I$2$S audio format with 48kHz FSYNC, 6.144MHz BCLK, and 16-bit wordlength
- Ethernet : 100MHz
- 

-----



## <font size=4>**VHDL Design Details**</font>

A file tree to show our project design here (_also in the newest released version folder_): 

\***<font size=4>TOP.vhdl </font>**

​	&ensp;|— **Control unit:**

​			&ensp;&ensp;&ensp;&ensp;|— ACFC (ADC configuration flow controller)

​	&ensp;|— **Interface in control path**

​			&ensp;&ensp;&ensp;&ensp;|— I2C master

​	&ensp;|— **Interface in datapath**:

​			&ensp;&ensp;&ensp;&ensp;|— I2S receiver

​			&ensp;&ensp;&ensp;&ensp;|— UDP_ethernet

​					&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;&ensp;|—CRC

​	&ensp;|— **Simple-Algorithm :**

​			&ensp;&ensp;&ensp;&ensp;|— _single register_

​			&ensp;&ensp;&ensp;&ensp;|— _shift register_

​			&ensp;&ensp;&ensp;&ensp;|— _power estimation_

​			&ensp;&ensp;&ensp;&ensp;|— _max_

​			&ensp;&ensp;&ensp;&ensp;|— _panning accumulator_

​			&ensp;&ensp;&ensp;&ensp;|— _fader_

​			&ensp;&ensp;&ensp;&ensp;|—_mixer_

​	&ensp;|—**other files**

​			&ensp;&ensp;&ensp;&ensp;|—PLL



FSM design is used widely in the control unit and interfaces. A **_half-fixed_ **big FSM in ACFC decides WHERE and WHAT we need to write to registers in ADC to configure it (so common in any chip configuration way). We fixed the order of key-configuration states like ***START***, ***RELEASE_ SOFT_SHUTDOWN***, ***ENABLE_CHANNEL,*** etc... apart from which, like decides FSYNC, BCLK, MASTER_MODE, AUDIO_FORMAT, is in ***unfixed code region***. That means we hew a stall state (region) up to wait for configuration by out-of-order switches. Each of the states in this ***FSM*** will call a small ‘***fsm***’ which implements I2C (master) protocol with fixed timing and format,   to write value into ADC. The relation between ***FSM*** and ***fsm*** is analog to Brain and Hand - the brain makes decisions and controls the Hand to write.

```vhdl
--The Brain
.
    .
    .
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
	.
	.
	.
	.
	
```

----


So we provide the '_start_',  '_config\_addr_', and '_config\_value_' input ports as Brain's commands in I2C. And the '_done_' output port will tell ACFC when I2C writing process is over.

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

<img src="https://github.com/Ghostbut13/DAT096-PASS/blob/main/Diagram/ACFC_and_I2C_fsm.png"  width="400"  height = "300" />

## <font size=4>**TOP.vhdl workflow** (_newest version_)</font>

- ACFC decides how to configure ADC (using FSM)

- ACFC transmits value into I2C and launches I2C to push value into ADC

- PLL generates MCLK to ADC, such that ADC can generate BCLK and FSync from it.

- ADC working...

- I2S receiver collects DATA from ADC and sends the four channels -- ***left1 left2 right1 right2***-- to the algorithm.

- Ethernet supports 100M high speed for real-time audio data transmission every fsync.

- When both the datapath and Ethernet are enabled, audio data can be transmitted from the FPGA port to the PC port for further analysis.

- **Simlpe-Algorithm takes the inputs and enhances the audio with one output.**

- DAC outputs the audio processed by the algorithm.

  

---



## <font size=4>**Test Environment**</font>





