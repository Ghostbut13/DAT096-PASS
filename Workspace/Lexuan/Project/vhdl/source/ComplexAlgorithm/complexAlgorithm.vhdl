library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY complex IS
PORT(
  clk_sysclk : IN STD_LOGIC; --system clk 
  clk_fsync : IN STD_LOGIC; --fsync
  rst_n : IN STD_LOGIC;
  LC1 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  LC2 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  RC1 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  RC2 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  dout_x : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
  dout_y : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
--  dout : OUT STD_LOGIC_VECTOR      (SIGNAL_WIDTH-1 DOWNTO 0)
);
END ENTITY complex;

ARCHITECTURE arch_complex OF complex IS

  TYPE input_array IS ARRAY(0 TO 3) OF STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  TYPE sr_output_array IS ARRAY(0 TO 3) OF outputdata;
  TYPE xcorr_output_array IS ARRAY(0 TO 2) OF xcorrdata;
  
  -- common signals
  SIGNAL input_array_signal : input_array := (OTHERS =>(OTHERS =>'0'));
  SIGNAL clk_sysclk_signal : STD_LOGIC := '0';
  SIGNAL clk_fsync_signal : STD_LOGIC := '0';
  SIGNAL rst_n_signal : STD_LOGIC := '0';
  
  -- shift register
  SIGNAL sr_ref_signal : sr_output_array := (OTHERS => (OTHERS => (OTHERS =>'0')));
  SIGNAL sr_lag_signal : sr_output_array := (OTHERS => (OTHERS => (OTHERS =>'0')));
  
  -- cross cottrlation
  SIGNAL  xcorr_output_signal : xcorr_output_array := (OTHERS => (OTHERS => (OTHERS =>'0')));
  
  -- position solver
  SIGNAL position_x_signal : STD_LOGIC_VECTOR(6 DOWNTO 0) := (OTHERS => '0');
  SIGNAL position_y_signal : STD_LOGIC_VECTOR(5 DOWNTO 0) := (OTHERS => '0');
  
  COMPONENT shiftregister IS
  PORT(
     clk_read: IN STD_LOGIC; --system clk 
     clk_write: IN STD_LOGIC; --fsync
     rst_n: IN STD_LOGIC;
     din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
     dout_PE: OUT outputdata;
	 dout_xcorr_lag: OUT outputdata;
	 dout_xcorr_ref: OUT outputdata
	 );
  END COMPONENT shiftregister;
  
  COMPONENT Xcc IS
  PORT(
	clk_en: IN STD_LOGIC;
	clk : IN STD_LOGIC;
	din_reference : IN outputdata;
	din_xcorr : IN outputdata;
	rst_n: IN STD_LOGIC;
	dout: OUT xcorrdata
	);
  END COMPONENT Xcc;
  
  COMPONENT PositionSolverImager IS
    PORT(
		sysCLK:			in STD_LOGIC; --system clock 100MHz
		reset:			in STD_LOGIC; --system reset
		PositionX:		out STD_LOGIC_VECTOR(6 DOWNTO 0); -- position 0 to 128, middle 64
		PositionY:		out STD_LOGIC_VECTOR(5 DOWNTO 0); -- position 0 to 64
		Correlation1:	in xcorrdata;
		Correlation2:	in xcorrdata;
		Correlation3:	in xcorrdata
    );
  END COMPONENT PositionSolverImager;
BEGIN
  SR_inst: 
  FOR i in 0 TO 3 GENERATE
    shiftregister_inst:
	COMPONENT shiftregister
    PORT MAP
	(
     clk_read => clk_sysclk_signal,
     clk_write => clk_fsync_signal,
     rst_n => rst_n_signal,
     din => input_array_signal(i),
     dout_PE => open,
	 dout_xcorr_lag => sr_lag_signal(i),
	 dout_xcorr_ref => sr_ref_signal(i)
	 );
  END GENERATE;
  
  XCORR_inst:
  FOR i in 0 TO 2 GENERATE
    crosscorrelation_inst:
	COMPONENT Xcc
	PORT MAP
	(
	  clk_en => clk_fsync_signal,
	  clk => clk_sysclk_signal,
	  din_reference => sr_ref_signal(i),
	  din_xcorr => sr_lag_signal(i+1),
	  rst_n => rst_n_signal,
	  dout => xcorr_output_signal(i)
	);
  END GENERATE;
  
  PS_inst:
  COMPONENT PositionSolverImager
  PORT MAP
    (
		sysCLK => clk_sysclk_signal,
		reset => rst_n_signal,
		PositionX => position_x_signal,
		PositionY => position_y_signal,
		Correlation1 => xcorr_output_signal(0),
		Correlation2 => xcorr_output_signal(1),
		Correlation3 => xcorr_output_signal(2)
    );
  
  clk_sysclk_signal <= clk_sysclk;
  clk_fsync_signal <= clk_fsync;
  
  input_array_signal(0) <= LC1;
  input_array_signal(1) <= LC2;
  input_array_signal(2) <= RC1;
  input_array_signal(3) <= RC2;
  
  dout_x <= position_x_signal;
  dout_y <= position_y_signal;
  
END ARCHITECTURE arch_complex;