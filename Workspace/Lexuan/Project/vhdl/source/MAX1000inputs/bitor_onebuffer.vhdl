LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY bitor_onebuffer IS 
    GENERIC(column_index: INTEGER);
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	bitor_last: IN STD_LOGIC;
	din : IN xcorrdata;
	dout_bitor : OUT STD_LOGIC
	);
END ENTITY bitor_onebuffer;

ARCHITECTURE arch_bitor_onebuffer OF bitor_onebuffer IS

  SIGNAL bitor_buffer : STD_LOGIC := '0';

  COMPONENT MAXbuffer IS 
    GENERIC(BUFFER_LENGTH: INTEGER);
    PORT(
    clk : IN STD_LOGIC;
    rst_n : IN STD_LOGIC;
    din : IN STD_LOGIC;
    dout: OUT STD_LOGIC
    );
  END COMPONENT MAXbuffer;
  

  FUNCTION bitor (input_array : xcorrdata; column_index : INTEGER ; lastbitor: STD_LOGIC) RETURN STD_LOGIC IS 
  
	VARIABLE orresult : STD_LOGIC := '0';
	
  BEGIN
      FOR data_index IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
	    IF lastbitor = '1' THEN
		  IF input_array(data_index)(column_index+1) = '1' THEN
		    orresult := orresult or input_array(data_index)(column_index);
		  END IF;
		ELSE
		  orresult := orresult or input_array(data_index)(column_index);
		END IF;
	  END LOOP;
	  RETURN orresult;
  END bitor;
  
  FUNCTION fisrt (input_array : xcorrdata; column_index : INTEGER) RETURN STD_LOGIC IS 
  
	VARIABLE orresult : STD_LOGIC := '0';
	
  BEGIN
      FOR data_index IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
		  orresult := orresult or input_array(data_index)(column_index);
	  END LOOP;
	  RETURN orresult;
  END fisrt;
  
BEGIN

bitor_proc:
PROCESS(clk)
BEGIN
	IF RISING_EDGE(clk) THEN 
	  IF column_index = xcorr_REGISTER_LENGTH-1 THEN 
	    bitor_buffer <= fisrt(din ,column_index);
	  ELSE
		bitor_buffer <= bitor(din ,column_index,bitor_last);
	  END IF;
	  dout_bitor <= bitor_buffer;
	END IF;
END PROCESS bitor_proc;

END ARCHITECTURE arch_bitor_onebuffer;