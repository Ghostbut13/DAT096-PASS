LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY MAXsort_tb IS 
--
END ENTITY MAXsort_tb;

ARCHITECTURE arch_MAXsort_tb OF MAXsort_tb IS 

  SIGNAL clk_tb: STD_LOGIC := '0';
  SIGNAL rst_n_tb: STD_LOGIC := '1';
  SIGNAL din1_tb: STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  SIGNAL din2_tb: STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  SIGNAL din3_tb: STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  SIGNAL din4_tb: STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  SIGNAL dout_loudest_tb: STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL dout_secondloudest_tb: STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL dout_thirdloudest_tb: STD_LOGIC_VECTOR(2 DOWNTO 0);

  COMPONENT MAXsort IS 
	PORT(
	clk: IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	din2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	din3: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	din4: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	dout_loudest: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	
	dout_secondloudest: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	
	dout_thirdloudest: OUT STD_LOGIC_VECTOR(2 DOWNTO 0)	
	);
  END COMPONENT MAXSort;

BEGIN 
  MAXsort_inst:
  COMPONENT MAXsort
  PORT MAP(
  clk => clk_tb,
  rst_n => rst_n_tb,
  din1 => din1_tb,
  din2 => din2_tb,
  din3 => din3_tb,
  din4 => din4_tb,
  dout_loudest => dout_loudest_tb,
  dout_secondloudest => dout_secondloudest_tb,
  dout_thirdloudest => dout_thirdloudest_tb
  );
  
clk_proc:
PROCESS
BEGIN
  WAIT FOR 5 ns;
  clk_tb <= NOT(clk_tb);
END PROCESS clk_proc;

  din1_tb <= "0000000000000000" after 3 ns,
             "0000000000000001" after 13 ns,
			 "0000000000000010" after 23 ns,
			 "0000000000000001" after 33 ns,
			 "0000000000000010" after 43 ns,
			 "0000000000000001" after 53 ns;
			 
  din2_tb <= "0000000000000000" after 3 ns,
             "0000000000000010" after 13 ns,
			 "0000000000000011" after 23 ns,
			 "0000000000000100" after 33 ns,
			 "0000000000000111" after 43 ns,
			 "0000000000000010" after 53 ns;
			 
  din3_tb <= "0000000000000000" after 3 ns,
             "0000000000000001" after 13 ns,
			 "0000000000000010" after 23 ns,
			 "0000000000000001" after 33 ns,
			 "0000000000000010" after 43 ns,
			 "0000000000000001" after 53 ns;
			 
  din4_tb <= "0000000000000001" after 3 ns,
             "0000000000000000" after 13 ns,
			 "0000000000000000" after 23 ns,
			 "0000000000000000" after 33 ns,
			 "0000000000000000" after 43 ns,
			 "0000000001000000" after 53 ns;
			 
END ARCHITECTURE arch_MAXSort_tb;