library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MAX_tb is


end MAX_tb;

architecture ARCH_MAX_tb of MAX_tb is
  constant WORD_LENGTH_TB : integer := 3;
  
  component MAX is
  GENERIC ( WORD_LENGHT : natural range 0 to 16 := 3);
  PORT  (
	rstn   : IN std_logic;
	clk		: IN std_logic;
	DIN1 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
	DIN2 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
	DIN3 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
	DIN4 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
	max 	: out std_logic_vector (2 downto 0)
	);
  end component MAX;
  

  signal DIN1_tb : std_logic_vector (WORD_LENGTH_TB-1 downto 0):= "001";
  signal DIN2_tb: std_logic_vector (WORD_LENGTH_TB-1 downto 0) := "011";
  signal DIN3_tb : std_logic_vector (WORD_LENGTH_TB-1 downto 0) := "101";
  signal DIN4_tb: std_logic_vector (WORD_LENGTH_TB-1 downto 0) := "111";
  
  signal clk_tb   : std_logic := '0';
  signal reset_tb : std_logic := '0';
  signal max_tb   : std_logic_vector(2 downto 0);
  
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
		rstn => reset_tb,
		clk => clk_tb,
		DIN1 => DIN1_tb,
		DIN2=>DIN2_tb,
		DIN3=> DIN3_tb,
		DIN4 => DIN4_tb,
		max => max_tb
		);
				
	reset_tb <= '1' after 0 ms,
				'0' after 70 ms,
				'1' after 85 ms;
				
end ARCH_MAX_tb;