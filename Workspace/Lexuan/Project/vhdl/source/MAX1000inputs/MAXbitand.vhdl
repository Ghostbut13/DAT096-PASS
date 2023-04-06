LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY MAXbitand IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din : xcorrdata;
	dout_index : STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY MAXbitand;

ARCHITECTURE arch_MAXbitand IS

  SIGNAL maxvalue : STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0) = (OTHERS => '0');
  SIGNAL buffer_0 : STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0) = (OTHERS => '0');
  
  COMPONENT bitand IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	column_index: INTEGER;
	din : IN xcorrdata;
	dout_bitand : OUT STD_LOGIC
	);
  END COMPONENT bitand;

  FUNCTION findmax( max: STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0), input_array : xcorrdata) RETURN INTEGER IS 
  
    VARIABLE i : INTEGER;
	
  BEGIN
	FOR i IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
      IF input_array(i) = max THEN
		  RETURN i;		  
	  END IF;
	END LOOP;
  END findmax;
  
BEGIN
	bitand_inst: FOR i IN 0 TO xcorr_SIGNAL_WIDTH-1 GENERATE
	  bitand_inst:
      COMPONENT bitand
      PORT MAP(
      clk => clk,
      rst_n => rst_n,
      column_index => i,
      din => din,
	  dout_bitand => maxvalue(i)
	  );
    END GENERATE; 
	
findmax_proc:
PROCESS(clk)
BEGIN
	dout_index <= findmax(din,maxvalue);
END PROCESS findmax_proc;
	

END ARCHITECTURE arch_MAXbitand;