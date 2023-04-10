-- Leuxan Tang 2023/04/10

-- sub-block in maxbitor block
-- function: matrix transposition
-- the algorithm takes 1 cycle

LIBRARY ieee;
library work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY transposition IS
  PORT(
    clk : IN STD_LOGIC;
--	rst_n : IN STD_LOGIC;
	input_matrix : IN xcorrdata;
	output_matrix : OUT xcorrdata_T
	);
END ENTITY transposition;

ARCHITECTURE arch_transposition OF transposition IS
  
  FUNCTION T(input:xcorrdata) RETURN xcorrdata_T IS
  
    VARIABLE output: xcorrdata_T := (OTHERS=>(OTHERS => '0'));
	
	BEGIN
	  FOR i IN  0 TO xcorr_DATA_WDITH LOOP
	    FOR j IN 0 TO xcorr_REGISTER_LENGTH LOOP
		  output(i)(j) := input(j)(i);
		END LOOP;
	  END LOOP;
  END T;

BEGIN
transposition_proc:
PROCESS(clk)
  IF FALLING_EDGE(clk) THEN
    output_matrix <= T(input_matrix);
  END IF;
	
END ARCHITECTURE arch_transposition;