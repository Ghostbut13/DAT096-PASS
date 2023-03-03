library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MAX_tb is


end MAX_tb;

architecture ARCH_MAX_tb of MAX_tb is
  constant WORD_LENGTH_TB : integer := 4;
  
  component MAX is
  GENERIC ( WORD_LENGHT : integer);
  PORT  (
	clk		: IN std_logic;
	DIN1 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
	DIN2 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
	DIN3 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
	DIN4 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
	max 	: out std_logic_vector (1 downto 0)
	);
  end component MAX;
  

  signal DIN1_tb : std_logic_vector (WORD_LENGTH_TB-1 downto 0):= "1001";
  signal DIN2_tb: std_logic_vector (WORD_LENGTH_TB-1 downto 0) := "0011";
  signal DIN3_tb : std_logic_vector (WORD_LENGTH_TB-1 downto 0) := "1111";
  signal DIN4_tb: std_logic_vector (WORD_LENGTH_TB-1 downto 0) := "1111";
  
  signal clk_tb:std_logic := '0';
  signal max_tb : std_logic_vector(1 downto 0);
  
  constant clk_delay : time :=   10 ms;-- 81.380 ns; -- one period 12.288MHz


  begin
  
  clk_process:
   process
   begin
	wait for clk_delay/2;
	clk_tb <= not(clk_tb);
  end process clk_process;
  
  MAX_inst:
  component MAX
  generic map(WORD_LENGHT => WORD_LENGTH_TB)
  port map(
		clk => clk_tb,
		DIN1 => DIN1_tb,
		DIN2=>DIN2_tb,
		DIN3=> DIN3_tb,
		DIN4 => DIN4_tb,
		max => max_tb
		);
				
end ARCH_MAX_tb;