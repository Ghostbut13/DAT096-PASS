<font size=6>**FPGA implementation microphone system for a theatre stage:**</font>

----------------



<font size=4>**Specification**</font>

- In the theatre it’s sometimes hard to hear what’s being said since the actors want to speak in a natural voice; shouting when acting in a play would be strange. Since this is a problem people have been looking into ways to solve this. An obvious solution is to use microphones but it will look awkward if the actors go round holding microphones, so we need another way. In most cases we don’t want to give full amplification of the voices but just some gentle boost and support to the voice coming from the stage.

- In this project, we will use a small number of audio microphones. Our system uses four microphones that are being connected to hardware using AD converters, then processed by an FPGA and output through a DA converter.

- We will start by activating only one microphone at a time but then we will move to a solution where the microphones are panned and have different levels of activation to make the transition between the sources more gentle. Some type of user interface to adjust settings is preferable. It could be in the form of a terminal or a GUI.

- Optional parts of the project include filtering of the sound to enhance the quality and reduce noise. There are several options such as: 
  1.	High-pass and low-pass filter - optionally with variable cutoff frequencies. 
  2.	Sweepable filter with damping/amplification and variable Q.
  3.	Adaptive filter for elimination of positive audio feedback from speaker to microphone.



------



<font size=4>**Block Diagram and System Introduction**</font>

![Block_Diagram](https://github.com/Ghostbut13/DAT096-PASS/blob/main/Diagram/DAT096-Block_Diagram.png)

The system consists of FPGA, peripheral ADC + DAC. Four microphones as Left1/2-Right1/2 channels sample analog audio and ADC will convert data to digital. **I$2$S receiver **operates at a sample rate of 48Khz and a BCLK-FSYNC ratio of 256, splitting the audio into four 16-bit wordlengths. We prepare two **algorithms** for panning channels according to acoustic source distance off each microphone. A virtual distribution figure shows the correct position estimation out of ***timing-delay*** or ***power estimation***, respectively in two algorithms.  Align with enhancement and filter modules, the algorithm part enhances the acoustic performance. DAC, the end of the **data path**, can output the processed audio stream. 

To customize the peripheral ADC parameters, such as the I$2$S protocol and differential input, it is necessary to configure the relative registers in the ADC using **control path**. The I$2$C slave in the ADC provides valid control information writing mechanisms, and the **ADC-Configuration-Flow-Controller (_ACFC_) module** manages the priority, location, and implicit value of the register writes based on the datasheet and datapath requirements. MCLK generated from **PLL module** as the source clock for ADC.



<font size=4>**MATLAB algorithm design** </font>

As core of the system, we have designed and tested the algorithm's structure consisting of multiple sub-modules.



<font size=4>**Communication between MATLAB and FPGA**</font>

The 100 MHz high-speed **Ethernet** port supported by Nexys 100T, facilitates the efficient transmission of audio streams to a PC. An Ethernet frame comprises headers, data, and Cyclic Redundancy Check (CRC). The headers are parsed by the PC receiver to extract information such as MAC and IP addresses, as well as the transmission protocol. The ***User Datagram Protocol (UDP)*** provides a concise and reliable transmission mechanism for real-time audio data, making it the preferred option over ***Transmission Control Protocol (TCP)***. Additionally, the received data and the checksum can be verified using the CRC.

FPGA 

MATLAB provides a toolbox to receive



