-- switcher description: we get indexer from power max. This will then help us find the neighbouring mics. 
-- If indexer is 2 we know that 1, 2, 3 are affected. Therefore, we take the cc1 and cc2, because cc1 have 2-1 and (-)cc2 have 2-3
--    cc1: mics 1 and 2
--    cc2: mics 2 and 3 
-- (-)cc2: mics 3 and 2
--    cc3: mics 3 and 4
-- we output the two delta values being the index of each MAX from each correlation and the common index_out from the cross-corelation.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;


ENTITY switch IS
  PORT  (
	index_PE  	: IN STD_LOGIC_VECTOR (2 downto 0);
	cc1_max 	: IN STD_LOGIC_VECTOR (29 DOWNTO 0); -- 13 to 0 is index of the max value out of n inputs.
	cc2_MAX 	: IN STD_LOGIC_VECTOR (29 DOWNTO 0);
	cc3_MAX 	: IN STD_LOGIC_VECTOR (29 DOWNTO 0);
	index_out	: OUT STD_LOGIC_VECTOR (2 downto 0);
	delta1		: OUT STD_LOGIC_VECTOR (13 downto 0);
    delta2 		: out std_logic_vector (13 downto 0)  
    );
END ENTITY switch;

ARCHITECTURE ARCH_switch OF switch IS

  signal cc1_index_signal : STD_LOGIC_VECTOR (13 downto 0);
  signal cc2_index_signal : STD_LOGIC_VECTOR (13 downto 0);
  signal cc3_index_signal : STD_LOGIC_VECTOR (13 downto 0);

  begin
  
	delta1 <= cc1_index_signal when (conv_integer(index_PE) < 3) else
				   cc2_index_signal;

	delta2 <= cc2_index_signal when (conv_integer(index_PE) < 3) else
				   cc3_index_signal;
				   
	index_out <= "010" when (conv_integer(index_PE) < 3) else
				   "011";

				   
	cc1_index_signal <= cc1_max(13 downto 0);
    cc2_index_signal <= cc2_max(13 downto 0);
    cc3_index_signal <= cc3_max(13 downto 0);
	
END ARCH_switch;