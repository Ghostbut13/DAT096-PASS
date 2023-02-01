FPGA implementation microphone system for a theatre stage:

-- Block diagram(demo from EDA234, instead of what we design)
![Block_Diagram](https://github.com/Ghostbut13/DAT096-PASS/blob/main/Diagram/Block_Diagram.png)





-- Description
*In the theatre it’s sometimes hard to hear what’s being said since the actors want to speak in a natural voice; shouting when acting in a play would be strange. Since this is a problem people have been looking into ways to solve this.

*An obvious solution is to use microphones but it will look awkward if the actors go round holding microphones, so we need another way. In most cases we don’t want to give full amplification of the voices but just some gentle boost and support to the voice coming from the stage.

*In this project you will use a small number of audio microphones. Our simple system will use four microphones that are being connected to hardware using AD converters, then processed by an FPGA and output through a DA converter.

*You will start by activating only  one microphone at a time but then you will move to a solution where the microphones are panned and have different levels of activation to make the transition between the sources more gentle.

*Some type of user interface to adjust settings will be required; it could be in the form of a terminal or a GUI.

*Optional parts of the project include filtering of the sound to enhance the quality and reduce noise. There are a several options such as: 
1.	High-pass and low-pass filter - optionally  with variable cutoff frequencies. 
2.	Sweepable filter with damping/amplification and variable Q.
3.	Adaptive filter for elimination of positive audio feedback from speaker to microphone