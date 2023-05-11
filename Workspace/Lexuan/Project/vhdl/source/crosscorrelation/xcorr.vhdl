LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY Xcc IS
	PORT(
	clk_en: IN STD_LOGIC;
	clk : IN STD_LOGIC;
	din_reference : IN outputdata;
	din_xcorr : IN outputdata;
	rst_n: IN STD_LOGIC;
	dout: OUT xcorrdata
	);
END ENTITY Xcc;

ARCHITECTURE arch_Xcc OF Xcc IS

SIGNAL newest_data_1_signal : STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL newest_data_2_signal : STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL oldest_data_1_signal : STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL oldest_data_2_signal : STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL accumulator_output : STD_LOGIC_VECTOR(2*SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL dout_signal : xcorrdata := (OTHERS =>(OTHERS =>'0'));
SIGNAL counter : SIGNED(10 DOWNTO 0) := (OTHERS => '0');

COMPONENT Xcorr IS
	PORT(
	clk: IN STD_LOGIC;
	rst_n: IN STD_LOGIC;
	newest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	newest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	dout: OUT STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0)
	);
END COMPONENT Xcorr;

BEGIN

accumulator_inst:
COMPONENT Xcorr
  PORT MAP(
	clk => clk,
	rst_n =>rst_n,
	newest_data_1 => newest_data_1_signal,
	oldest_data_1 => oldest_data_1_signal,
	newest_data_2 => newest_data_2_signal,
	oldest_data_2 => oldest_data_2_signal,
	dout => accumulator_output
  );

counter_process:
PROCESS(clk)
BEGIN
  IF RISING_EDGE(clk) THEN -- system clk
    IF clk_en = '0' THEN
	    IF counter < 567 THEN 
          counter <= counter + 1;
		ELSE
		  counter <= counter;
	    END IF;
	ELSE
	  	counter <= (OTHERS =>'0');
	END IF;
  END IF;
END PROCESS counter_process;

input_proc:
PROCESS(clk)
BEGIN
  IF FALLING_EDGE(clk) THEN 
    IF counter = 3 THEN
	  newest_data_1_signal <= din_reference(0);
	  oldest_data_1_signal <= din_reference(1);  
	ELSIF counter > 6 and counter < 566 THEN
	  IF counter(0) = '1' THEN
	    newest_data_2_signal <= din_xcorr(0);
	    oldest_data_2_signal <= din_xcorr(1);
	  END IF;
	END IF;	  
  END IF;
END PROCESS input_proc;

output_proc:
PROCESS(counter)
BEGIN
  IF counter > 7 and counter < 567 THEN
    dout_signal(TO_INTEGER(SIGNED('0' & counter(9 DOWNTO 1)) - 4)) <= accumulator_output;
  END IF;
END PROCESS output_proc;

assigenment_proc:
PROCESS(clk_en)
BEGIN
  IF FALLING_EDGE(clk_en) THEN
    dout <= dout_signal;
  END IF;
END PROCESS assigenment_proc;

END ARCHITECTURE;