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
SIGNAL xcorr : xcorrdata := (OTHERS =>(OTHERS =>'0'));
--SIGNAL dout_signal : xcorrdata := (OTHERS =>(OTHERS =>'0'));
SIGNAL counter : SIGNED(10 DOWNTO 0) := (OTHERS => '0');

BEGIN

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
  IF RISING_EDGE(clk) THEN 
    IF counter = 2 THEN
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
    xcorr(TO_INTEGER(SIGNED('0' & counter(9 DOWNTO 1)) - 4)) <= STD_LOGIC_VECTOR(SIGNED(xcorr(TO_INTEGER(SIGNED('0' & counter(9 DOWNTO 1)) - 4))) + SIGNED(newest_data_1_signal) * SIGNED(newest_data_2_signal) - SIGNED(oldest_data_1_signal) * SIGNED(oldest_data_2_signal));
  END IF;
END PROCESS output_proc;

assigenment_proc:
PROCESS(clk_en)
BEGIN
  IF FALLING_EDGE(clk_en) THEN
    dout <= xcorr;
  END IF;
END PROCESS assigenment_proc;

END ARCHITECTURE;