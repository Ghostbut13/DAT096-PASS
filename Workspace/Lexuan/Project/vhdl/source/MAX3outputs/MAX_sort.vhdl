-- sort function in complex algorithm
LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY MAXsort IS 
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
END ENTITY MAXSort;

ARCHITECTURE arch_MAXsort OF MAXsort IS 
  
  COMPONENT firstpass IS 
    PORT(
	  clk: IN STD_LOGIC;
	  rst_n : IN STD_LOGIC;

	  din1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);	-- four input data from power estimation
	  din2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	  din3: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	  din4: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);

	  dout_loudest: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	-- index of the loudest microphone
	
      dout1: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0); -- three microphones left
	  dout2: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);
	  dout3: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0)
	);
  END COMPONENT firstpass;
  
  COMPONENT secondpass IS 
    PORT(
	  clk: IN STD_LOGIC;
	  rst_n : IN STD_LOGIC;

	  din1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);	-- three input data from first pass
	  din2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);
	  din3: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);

	  dout_second: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	-- index of the second loudest microphone
	
      dout1: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0); -- two microphones left
	  dout2: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0)
	);
  END COMPONENT secondpass;

  COMPONENT thirdpass IS 
	PORT(
	clk: IN STD_LOGIC;
	rst_n : IN STD_LOGIC;

	din1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);	-- two input data from first pass
	din2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);

	dout_third: OUT STD_LOGIC_VECTOR(2 DOWNTO 0)	-- index of the second loudest microphone
	);
  END COMPONENT thirdpass;
  
  SIGNAL firstpass_out1 : STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL firstpass_out2 : STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL firstpass_out3 : STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0) := (OTHERS => '0');
  
  SIGNAL secondpass_out1 : STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0) := (OTHERS => '0');
  SIGNAL secondpass_out2 : STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0) := (OTHERS => '0');
  
BEGIN

  firstpass_inst:
  COMPONENT firstpass
    PORT MAP(
	  clk => clk,
	  rst_n => rst_n,
	  din1 => din1,
	  din2 => din2,
	  din3 => din3,
	  din4 => din4,
	  dout_loudest => dout_loudest,
      dout1 => firstpass_out1,
	  dout2 => firstpass_out2,
	  dout3 => firstpass_out3
	);
	
  secondpass_inst:
  COMPONENT secondpass
    PORT MAP(
	  clk => clk,
	  rst_n => rst_n,
	  din1 => firstpass_out1,
	  din2 => firstpass_out2,
	  din3 => firstpass_out3,
	  dout_second => dout_secondloudest,
      dout1 => secondpass_out1,
	  dout2 => secondpass_out2
	);
	
  thirdpass_inst:
  COMPONENT thirdpass
    PORT MAP(
	  clk => clk,
	  rst_n => rst_n,
      din1 => secondpass_out1,
	  din2 => secondpass_out2,
	  dout_third => dout_thirdloudest
	);


END ARCHITECTURE arch_MAXSort;