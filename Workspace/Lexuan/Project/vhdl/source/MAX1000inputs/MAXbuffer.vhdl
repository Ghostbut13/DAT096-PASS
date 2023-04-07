LIBRARY ieee;
library work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY MAXbuffer IS 
  GENERIC(BUFFER_LENGTH: INTEGER);
  PORT(
  clk : IN STD_LOGIC;
  rst_n : IN STD_LOGIC;
  din : IN STD_LOGIC;
  dout: OUT STD_LOGIC
  );
END ENTITY MAXbuffer;

ARCHITECTURE arch_MAXbuffer OF MAXbuffer IS
  
COMPONENT singleregister IS
  PORT (clk: IN STD_LOGIC;
        din: IN STD_LOGIC;
        dout: OUT STD_LOGIC);
END COMPONENT singleregister;

  SIGNAL temp_buffer : STD_LOGIC_VECTOR(BUFFER_LENGTH-1 DOWNTO 0) := (OTHERS => '0');

BEGIN 

  buffer_inst: FOR i IN 1 TO BUFFER_LENGTH-1 GENERATE
    buffer_inst:
	COMPONENT singleregister
    PORT MAP(
	clk => clk,
    din => temp_buffer(i-1),
    dout => temp_buffer(i));
  END GENERATE;
	
	temp_buffer(0) <= din;
	dout <= temp_buffer(BUFFER_LENGTH-1);
  
END ARCHITECTURE arch_MAXbuffer;