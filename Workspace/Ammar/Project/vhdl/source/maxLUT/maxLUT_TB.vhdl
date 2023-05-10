library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;


entity maxLUT_TB is
end maxLUT_TB;

architecture arch_maxLUT_TB of maxLUT_TB is

	component maxLUT is
	PORT(
	clk		   : IN STD_LOGIC;
	rst_n 	   : IN STD_LOGIC;
	din 	   : IN STD_LOGIC_VECTOR (15 downto 0);
	xy_pos_in  : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
	xy_pos_out : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
	end component maxLUT;
	

	SIGNAL CLK_TB: 			    STD_LOGIC := '0';
	SIGNAL rst_n_tb: 			STD_LOGIC := '1';
	SIGNAL din_tb:				STD_LOGIC_VECTOR(16 DOWNTO 1) := "0111111111111111";
	SIGNAL xy_pos_in_tb:		STD_LOGIC_VECTOR(12 DOWNTO 1) := "000000000000";
	SIGNAL xy_pos_out_tb: 		STD_LOGIC_VECTOR(12 DOWNTO 1) := "000000000000";
	
begin
	inst_maxLUT: maxLUT
	port map(
		clk			=> CLK_TB, --system clock
		rst_n		=> rst_n_tb,
		din			=> din_tb,
		xy_pos_in	=> xy_pos_in_tb,
		xy_pos_out	=> xy_pos_out_tb
	);

	Sample_clk_gen : 
	process
	begin
		wait for 5 us;
		CLK_TB <= not(CLK_TB);
	end process Sample_clk_gen;
	
	
	rst_n_tb <= '1' after 0 us,
				'0' after 66 us,
				'1' after 68 us;
	
	
	din_tb   <=  "0011000000010000"  after 0 us,
				 "0000111100001111"  after 10 us,
				 "1010101010101010"  after 20 us,
				 "0010110101010100"	 after 30 us,
				 "1111111111111111"  after 40 us,
				 "1100111001111111"  after 65 us;

				 
	xy_pos_in_tb <= "010110110010" after 0 us,
					"010101001111" after 10 us,
					"111011111001" after 20 us,
					"001000111100" after 30 us,
					"010000100100" after 40 us,
					"111100001111" after 65 us;

	
end arch_maxLUT_TB;
