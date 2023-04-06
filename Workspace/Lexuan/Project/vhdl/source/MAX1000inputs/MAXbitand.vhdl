LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY MAXbitand IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din : IN xcorrdata;
	dout_index : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY MAXbitand;

ARCHITECTURE arch_MAXbitand OF MAXbitand IS

  SIGNAL maxvalue : STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
  
  COMPONENT bitand IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	column_index: INTEGER;
	bitand_lastrow: IN STD_LOGIC;
	din : IN xcorrdata;
	dout_bitand : OUT STD_LOGIC
	);
  END COMPONENT bitand;

  FUNCTION findmax( max: STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0); input_array : xcorrdata) RETURN INTEGER IS 
  
    VARIABLE i : INTEGER := 0;
	VARIABLE target_index : INTEGER := 0;
	
  BEGIN
	FOR i IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
      IF input_array(i) = max THEN
		  	target_index := i;  
	  END IF;
	END LOOP;
	RETURN target_index;
  END findmax;
  
BEGIN
    bitand_first:
	  COMPONENT bitand
	  PORT MAP(
	  clk => clk,
      rst_n => rst_n,
      column_index => 0,
	  bitand_lastrow => '0',
      din => din,
	  dout_bitand => maxvalue(0)
	  );
	  
	bitand_inst: FOR i IN 1 TO xcorr_SIGNAL_WIDTH-1 GENERATE
	  bitand_inst:
        COMPONENT bitand
        PORT MAP(
        clk => clk,
        rst_n => rst_n,
        column_index => i,
		bitand_lastrow => maxvalue(i-1),
        din => din,
	    dout_bitand => maxvalue(i)
	    );
      END GENERATE; 
	
findmax_proc:
PROCESS(clk)
BEGIN
  IF FALLING_EDGE(clk) THEN
	dout_index <= STD_LOGIC_VECTOR(to_unsigned(findmax(maxvalue, din),8));
  END IF;
END PROCESS findmax_proc;
	

END ARCHITECTURE arch_MAXbitand;