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
	input_matrix : IN xcorrindex;
	output_matrix : OUT xcorrindex_T
	);
END ENTITY transposition;

ARCHITECTURE arch_transposition OF transposition IS
  
  FUNCTION T(input : xcorrindex) RETURN xcorrindex_T IS
  
    VARIABLE output: xcorrindex_T := (OTHERS=>(OTHERS => '0'));
	
	BEGIN
	  FOR i IN  0 TO xcorr_DATA_WIDTH-1 LOOP
	    FOR j IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
		  output(i)(j) := input(j)(i);
		END LOOP;
	  END LOOP;
	  RETURN output;
  END T;

BEGIN

transposition_proc:
PROCESS(clk)
BEGIN
  IF FALLING_EDGE(clk) THEN
    output_matrix <= T(input_matrix);
  END IF;
END PROCESS transposition_proc;
	
END ARCHITECTURE arch_transposition;