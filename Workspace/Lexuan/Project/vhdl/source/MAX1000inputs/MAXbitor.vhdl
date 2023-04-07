LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY MAXbitor IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din : IN xcorrdata;
	dout_index : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END ENTITY MAXbitor;

ARCHITECTURE arch_MAXbitor OF MAXbitor IS

  SIGNAL maxvalue : STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
 -- SIGNAL buffervalue : STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
  
  COMPONENT bitor IS 
    GENERIC(column_index: INTEGER);
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	bitor_last: IN STD_LOGIC;
	din : IN xcorrdata;
	dout_bitor : OUT STD_LOGIC
	);
  END COMPONENT bitor;
  
  COMPONENT bitor_nobuffer IS 
    GENERIC(column_index: INTEGER := 0);
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	bitor_last: IN STD_LOGIC;
	din : IN xcorrdata;
	dout_bitor : OUT STD_LOGIC
	);
  END COMPONENT bitor_nobuffer;

  COMPONENT bitor_onebuffer IS 
    GENERIC(column_index: INTEGER :=  1);
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	bitor_last: IN STD_LOGIC;
	din : IN xcorrdata;
	dout_bitor : OUT STD_LOGIC
	);
  END COMPONENT bitor_onebuffer;
  
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
    bitor_first:
	  COMPONENT bitor
	  GENERIC MAP(column_index => xcorr_SIGNAL_WIDTH-1)
	  PORT MAP(
	  clk => clk,
      rst_n => rst_n,
	  bitor_last => '0',
      din => din,
	  dout_bitor => maxvalue(xcorr_SIGNAL_WIDTH-1)
	  );
	  
	bitor_inst: FOR i IN 1 TO xcorr_SIGNAL_WIDTH-3 GENERATE
	  bitor_inst:
        COMPONENT bitor
		GENERIC MAP(column_index => xcorr_SIGNAL_WIDTH-1-i)
        PORT MAP(
        clk => clk,
        rst_n => rst_n,
		bitor_last => maxvalue(xcorr_SIGNAL_WIDTH-i),
        din => din,
	    dout_bitor => maxvalue(xcorr_SIGNAL_WIDTH-1-i)
	    );
    END GENERATE; 
	
	bitor_index1:
	  COMPONENT bitor_onebuffer
	  PORT MAP(
	  clk => clk,
	  rst_n => rst_n,
	  bitor_last => maxvalue(2),
	  din => din,
	  dout_bitor => maxvalue(1)
	  );
	
	bitor_index0:
	  COMPONENT bitor_nobuffer
	  PORT MAP(
	  clk => clk,
	  rst_n => rst_n,
	  bitor_last => maxvalue(1),
	  din => din,
	  dout_bitor => maxvalue(0)
	  );
	  
findmax_proc:
PROCESS(clk)
BEGIN
  IF FALLING_EDGE(clk) THEN
	dout_index <= STD_LOGIC_VECTOR(to_unsigned(findmax(maxvalue, din),8));
  END IF;
END PROCESS findmax_proc;
	

END ARCHITECTURE arch_MAXbitor;