-- sort function in complex algorithm
LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY thirdpass IS 
	PORT(
	clk: IN STD_LOGIC;
	rst_n : IN STD_LOGIC;

	din1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);	-- two input data from first pass
	din2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);

	dout_third: OUT STD_LOGIC_VECTOR(2 DOWNTO 0)	-- index of the second loudest microphone
	);
END ENTITY thirdpass;

ARCHITECTURE arch_thirdpass OF thirdpass IS 

SIGNAL dout: STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');

BEGIN
	
sort_proc:
PROCESS(clk,rst_n)
BEGIN
  IF rst_n = '0' THEN 
  END IF;
  IF FALLING_EDGE(clk) THEN
	IF din1 > din2 THEN
	  dout <= din1(SIGNAL_WIDTH-14 DOWNTO 0);
	ELSE
	  dout <= din2(SIGNAL_WIDTH-14 DOWNTO 0);
	END IF;
  END IF;
 END PROCESS sort_proc;
 
 dout_third <= dout;

END ARCHITECTURE arch_thirdpass;