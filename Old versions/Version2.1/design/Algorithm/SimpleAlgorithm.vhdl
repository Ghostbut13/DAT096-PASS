library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;


entity SimpleAlgorithm is 
 port( LC1_in 			: in std_logic_vector(16 downto 1);
	   LC2_in 			: in std_logic_vector(16 downto 1);
	   RC1_in			: in std_logic_vector(16 downto 1);
	   RC2_in 			: in std_logic_vector(16 downto 1);
	   clk 			: in std_logic;
	   start_SA 	: in std_logic; -- this work as a system reset. We can use it as a switch on the FPGA
	   OUTPUT 		: out std_logic_vector(16 downto 1); -- goes to DAC
	   INDEX_OUT	: out std_logic_vector(2 downto 0 ) -- goes to LEDs
      );

end SimpleAlgorithm;



architecture ArchSimpleAlgorithm of SimpleAlgorithm is

--------component decleration--------
-- shif register component
component shiftregister is 
  PORT(clk: IN STD_LOGIC;
	   rst_n : IN std_logic;
       din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
       dout: OUT outputdata);
END component shiftregister;


-- power estimation
component power_estimation is
	port(clk:in std_logic;
		reset_n: in std_logic;
		data_in: in outputdata;
		power_data: out std_logic_vector(SIGNAL_WIDTH-1 downto 0)
	);
end component power_estimation;


-- get max vector
component MAX is
  GENERIC ( WORD_LENGHT : integer := 16);
  PORT  (
    rstn 	: IN std_logic;
    clk		: IN std_logic;
    DIN1 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN2 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN3 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN4 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    max 	: OUT std_logic_vector (2 downto 0)
    );
END component MAX;


-- Panning accumulator
component PA is
  port(
	CLK:			in STD_LOGIC; --48kHz clock
	TargetIndex:	IN STD_LOGIC_VECTOR(3 DOWNTO 1);
	Indexer:		OUT STD_LOGIC_VECTOR(16 DOWNTO 1)
    );
end component PA;


-- fader component
component fader is
  port(
	CLK:			in STD_LOGIC; --48kHz clock
	SampleIn:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	sampleOut:		out STD_LOGIC_VECTOR(16 DOWNTO 1);
	Indexer:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	RefIndex:		in STD_LOGIC_VECTOR(3 DOWNTO 1);
	Multiout:		out STD_LOGIC_VECTOR(16 downto 1)
    );
end component fader;


-- add the signals together
component mixer is
  port(
	CLK:		in STD_LOGIC; --48kHz clock
	Input1:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input2:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input3:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input4:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Output:		OUT STD_LOGIC_VECTOR(16 DOWNTO 1)
    );
end component mixer;





 --------signal decleration-------- 
 type ARRAY16bits is array (0 to 3) of std_logic_vector(SIGNAL_WIDTH-1 DOWNTO 0); 
 type ARRAY3D is array (0 to 3) of outputdata; 

 
 -- commong signals
 signal rstn_sa_signal : std_logic;
 signal clk48_sa_signal : std_logic;
 
 -- shift register signals
 signal dout_sa_signal : ARRAY3D := (others => (others => (others =>'0')));

 
 -- power estimation
 signal power_out_sa_signal : ARRAY16bits := (others => (others=>'0'));
 
 -- max funtion
 signal MaxIndexer_sa_signal : std_logic_vector(2 downto 0);
 
 -- Panning accumulator
 signal PAIndexer_sa_signal : std_logic_vector (SIGNAL_WIDTH-1 DOWNTO 0);
 
 
 --fader 
 signal FaderMultiOut_sa_signal : ARRAY16bits;
 signal FaderOut_sa_signal : ARRAY16bits; 
 
 -- Algorithm PinOuts signals 
 signal input_sa_signal : ARRAY16bits;
 signal OUTPUT_sa_Signal : std_logic_vector(SIGNAL_WIDTH-1 DOWNTO 0);

------ start architecture here!-----
 begin  
 
 
 -- generate instances of shift register
 -- Save big samples of data in shift registers.
 SR_G: for i in 0 to 3 generate
	SR_inst:
		component shiftregister
		port map(clk => clk48_sa_signal,
				 rst_n => rstn_sa_signal, 
				 din => input_sa_signal(i),
				 dout => dout_sa_signal(i)
				 );
 end generate;
 
 -- generate instances of power estimation.
 -- Calculate the average power of the 4 channel signals.
 PE_G: for i in 0 to 3 generate
    PE_inst:
	    component power_estimation
		port map(clk => clk48_sa_signal,
		     reset_n => rstn_sa_signal,
			 data_in => dout_sa_signal(i),
			 power_data => power_out_sa_signal(i)
			 );
	end generate;
	
 -- max instance
 -- Index out the channel with the maximum power.
 MAX_inst: 
  component MAX
  port map(
  rstn => rstn_sa_signal,
  clk  => clk48_sa_signal, 
  DIN1 => power_out_sa_signal(0),
  DIN2 => power_out_sa_signal(1),
  DIN3 => power_out_sa_signal(2),
  DIN4 => power_out_sa_signal(3),
  max => MaxIndexer_sa_signal
  );
  
  
 -- Panning accumulator instance
 -- go in small sequences to the correct microphone 
 PA_inst:
   component PA
   port map(
   CLK => clk48_sa_signal,
   TargetIndex => MaxIndexer_sa_signal,
   Indexer => PAIndexer_sa_signal
   );
  
  
  -- generate 4 instances of fader
  -- Attenuates the microphones
  F_G: for i in 0 to 3 generate
   Fader_inst:
      component fader
	  port map(
	  CLK => clk48_sa_signal,
	  SampleIn => input_sa_signal(i),
	  SampleOut => FaderOut_sa_signal(i),
	  Indexer => PAIndexer_sa_signal,
	  RefIndex => STD_LOGIC_VECTOR(To_unsigned(i+1, 3)),
	  Multiout => FaderMultiOut_sa_signal(i)
	  );
	end generate;
 
 -- instance of mixer
 -- add the signals and give one output
 mixer_inst:
	component mixer
	port map(
	  CLK => clk48_sa_signal,
	  Input1 => FaderOut_sa_signal(0),
	  Input2 => FaderOut_sa_signal(1),
	  Input3 => FaderOut_sa_signal(2),
	  Input4 => FaderOut_sa_signal(3),
	  Output => OUTPUT_sa_Signal
	);
 
 -- assign entity
 rstn_sa_signal <= start_SA;
 clk48_sa_signal <= clk;
 input_sa_signal(0) <= LC1_in;
 input_sa_signal(1) <= LC2_in;
 input_sa_signal(2) <= RC1_in;
 input_sa_signal(3) <= RC2_in;
 
 OUTPUT <= OUTPUT_sa_Signal;
 INDEX_OUT <=  MaxIndexer_sa_signal;
 
end architecture ArchSimpleAlgorithm;