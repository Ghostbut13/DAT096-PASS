LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY bitand IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	column_index: IN INTEGER;
	bitand_lastrow: IN STD_LOGIC;
	din : IN xcorrdata;
	dout_bitand : OUT STD_LOGIC
	);
END ENTITY bitand;

ARCHITECTURE arch_MAXbitand OF bitand IS

  FUNCTION bitand (input_array : xcorrdata; column_index : INTEGER ; lastbitand: STD_LOGIC) RETURN STD_LOGIC IS 
  
	VARIABLE andresult : STD_LOGIC := '0';
	
  BEGIN
      FOR data_index IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
	    IF lastbitand = '1' THEN
		  IF input_array(data_index)(column_index-1) = '1' THEN
		    andresult := andresult or input_array(data_index)(column_index);
		  END IF;
		ELSE
		  andresult := andresult or input_array(data_index)(column_index);
		END IF;
	  END LOOP;
	  RETURN andresult;
  END bitand;
  
  FUNCTION fisrt (input_array : xcorrdata; column_index : INTEGER) RETURN STD_LOGIC IS 
  
	VARIABLE andresult : STD_LOGIC := '0';
	
  BEGIN
      FOR data_index IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
		  andresult := andresult or input_array(data_index)(column_index);
	  END LOOP;
	  RETURN andresult;
  END fisrt;
  
BEGIN
bitand_proc:
PROCESS(clk)
BEGIN
	IF RISING_EDGE(clk) THEN 
	  IF column_index = 0 THEN 
	    dout_bitand <= fisrt(din ,column_index);
	  ELSE
		dout_bitand <= bitand(din ,column_index,bitand_lastrow);
	  END IF;
	END IF;
END PROCESS bitand_proc;
END ARCHITECTURE arch_MAXbitand;