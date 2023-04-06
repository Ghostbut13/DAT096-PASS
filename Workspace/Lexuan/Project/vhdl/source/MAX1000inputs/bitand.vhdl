LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY bitand IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	column_index: IN INTEGER;
	din : IN xcorrdata;
	dout_bitand : OUT STD_LOGIC
	);
END ENTITY bitand;

ARCHITECTURE arch_MAXbitand OF bitand IS

  FUNCTION bitand (input_array : xcorrdata, column_index : INTEGER) RETURN STD_LOGIC IS 
  
    VARIABLE row_index : INTEGER := 0;
	VARIABLE andresult : STD_LOGIC := "1";
	
  BEGIN
      FOR data_index IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
		andresult := andresult and input_array(data_index)(column_index);
	  END LOOP;
	  RETURN andresult;
  END bitand;
  
BEGIN
bitand_proc:
PROCESS(clk)
BEGIN
	IF FALLING_EDGE(clk) THEN 
		dout_bitand = bitand(din ,column_index);
	END IF;
END PROCESS bitand_proc;
END ARCHITECTURE arch_MAXbitand;