-- switcher description: we get indexer from power max. This will then help us find the neighbouring mics. 
-- If indexer is 2 we know that 1, 2, 3 are affected. Therefore, we take the cc1 and cc2, because cc1 have 2-1 and (-)cc2 have 2-3
--    cc1: mics 1 and 2
--    cc2: mics 2 and 3 
-- (-)cc2: mics 3 and 2
--    cc3: mics 3 and 4
-- we output the two delta values being the max value from each correlation and the common index_out from the cross-corelation.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;


ENTITY switch IS
  PORT  (
    clk			: IN STD_LOGIC ;
	rst_n 		: IN STD_LOGIC;
	index_PE  	: IN STD_LOGIC_VECTOR (2 downto 0);
	cc1_max 	: IN STD_LOGIC_VECTOR (15 downto 0);
	cc2_MAX 	: IN STD_LOGIC_VECTOR (15 downto 0);
	cc3_MAX 	: IN STD_LOGIC_VECTOR (15 downto 0);
	index_out	: OUT STD_LOGIC_VECTOR (2 downto 0);
	delta1		: OUT STD_LOGIC_VECTOR (15 downto 0);
    delta2 		: out std_logic_vector (15 downto 0)  
    );
END ENTITY switch;

ARCHITECTURE ARCH_switch OF switch IS

  SIGNAL delta1_out_signal: STD_LOGIC_VECTOR (15 DOWNTO 0);
  SIGNAL delta2_out_signal: STD_LOGIC_VECTOR (15 DOWNTO 0);
  begin
 
  delta1_out_signal <= cc1_max when (conv_integer(index_PE) < 3) else
  					   cc2_MAX;

  delta2_out_signal <= cc2_max when (conv_integer(index_PE) < 3) else
					   cc3_MAX;
						 
	indexer_proc:
   	 process(clk, rst_n)
	 begin
		
 
 delta1 <= delta1_out_signal;
 delta2 <= delta2_out_signal;

END ARCH_switch;
