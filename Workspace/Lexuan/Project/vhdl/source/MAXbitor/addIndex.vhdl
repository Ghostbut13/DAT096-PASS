-- Leuxan Tang 2023/04/10

-- sub-block in maxbitor block
-- function: add the 7-bit index identifier to the original input data
-- when we find the maximum, we take the last 7-bit index as output
-- the algorithm takes 1 cycle

LIBRARY ieee;
library work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY addIndex IS
  PORT(
    clk : IN STD_LOGIC;
--	rst_n : IN STD_LOGIC;
	din : IN xcorrdata;
	dout : OUT xcorrindex;
	);
END ENTITY addIndex;

ARCHITECTURE arch_addIndex OF addIndex IS

  FUNCTION add(input: xcorrdata) RETURN xcorrindex IS
  
    VARIABLE output: xcorrindex := (OTHERS => (OTHERS => '0'));
	
	BEGIN
	  FOR data_index IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
	    output(data_index) := input(data_index) & STD_LOGIC_VECTOR(TO_UNSIGNED(data_index,7));
	  END LOOP;
	  RETURN output;
  END add;
  
BEGIN

addindex_proc:
PROCESS(clk)
  BEGIN
    IF FALLING_EDGE(clk) THEN
		dout <= add(din);
	END IF;
END PROCESS addindex_proc;

END ARCHITECTURE arch_addIndex;