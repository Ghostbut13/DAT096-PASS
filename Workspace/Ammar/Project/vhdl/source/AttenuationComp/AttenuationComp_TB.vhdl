library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity AC_TB is
end AC_TB;

architecture arch of AC_TB is
	component AttenuationComp is
     port(
		CLK :		in STD_LOGIC; --48kHz clock
		mic1:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
		mic2:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
		mic3:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
		mic4:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
		y_pos_in:   in std_logic_vector(6 downto 1);
		output_DAC:		out STD_LOGIC_VECTOR(16 downto 1)
    );
	end component AttenuationComp;
	

	SIGNAL CLK_TB: 			STD_LOGIC := '0';
	SIGNAL mic1_tb:			STD_LOGIC_VECTOR(16 DOWNTO 1) := "0000000001111111";
	SIGNAL mic2_tb:			STD_LOGIC_VECTOR(16 DOWNTO 1) := "0000000001010011";
	SIGNAL mic3_tb: 		STD_LOGIC_VECTOR(16 DOWNTO 1) := "1111111111111111";
	SIGNAL mic4_tb:			STD_LOGIC_VECTOR(16 DOWNTO 1) := "0000000111111000";
	
	SIGNAL y_pos_in_tb:			STD_LOGIC_VECTOR(6 downto 1) := (others=>'0');
	SIGNAL output_tb:			STD_LOGIC_VECTOR(16 downto 1);
	
begin
	INST_AC: AttenuationComp
	port map(
		CLK			=> CLK_TB, --48kHz clock
		mic1	=> mic1_tb,
		mic2	=> mic2_tb,
		mic3		=> mic3_tb,
		mic4	=> mic4_tb,
		y_pos_in => y_pos_in_tb,
		output_DAC	=> output_tb
	);



	Sample_clk_gen : 
	process
	begin
		wait for 10 us;
		CLK_TB <= not(CLK_TB);
	end process Sample_clk_gen;
	
	Sample: 
	process
	begin
		wait for 100 us;
		y_pos_in_tb <= y_pos_in_tb+1;
	end process Sample;
	
	
	--y_pos_in_tb <= "000001" after 50 us;
	
end arch;
