LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY MAXbitand_tb IS 
--
END ENTITY MAXbitand_tb;

ARCHITECTURE arch_MAXbitand_tb OF MAXbitand_tb IS

  SIGNAL clk_tb : STD_LOGIC := '0';
  SIGNAL rst_n_tb : STD_LOGIC := '1';
  SIGNAL din_tb : xcorrdata := ( OTHERS => (OTHERS => '0'));
  SIGNAL dout_tb : STD_LOGIC_VECTOR(7 DOWNTO 0);

   COMPONENT MAXbitand IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din : IN xcorrdata;
	dout_index : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
  END COMPONENT MAXbitand;
  
BEGIN

  MAXbitand_inst:
    COMPONENT MAXbitand
    PORT MAP(
    clk => clk_tb,
    rst_n => rst_n_tb,
    din => din_tb,
    dout_index => dout_tb
    );
  
clk_proc:
PROCESS
BEGIN
  WAIT FOR 5 ns;
  clk_tb <= NOT(clk_tb);
END PROCESS clk_proc;  
  din_tb(0) <= "00000000000000000000000000000001" after 13 ns;
  
  din_tb(1) <= "00000000000000000000000000000010" after 23 ns;
  
  din_tb(4) <= "00000000000000000000000000000110" after 33 ns;
  
  din_tb(8) <= "00000000000000000000010000000010" after 43 ns;
  
  din_tb(3) <= "00000000010000000000000000000010" after 53 ns;
  
  
END ARCHITECTURE arch_MAXbitand_tb;