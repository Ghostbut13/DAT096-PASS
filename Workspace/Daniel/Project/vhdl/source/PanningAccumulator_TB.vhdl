

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PA_TB is
end PA_TB;

architecture arch of PA_TB is
	component PA is
		port(
			CLK:			in STD_LOGIC; --48kHz clock
			TargetIndex:	IN STD_LOGIC_VECTOR(3 DOWNTO 1);
			Indexer:		OUT STD_LOGIC_VECTOR(16 DOWNTO 1)
		);
	end component PA;
	

	SIGNAL CLK_TB: 			STD_LOGIC := '0';
	SIGNAL TargetIndex_TB: 	STD_LOGIC_VECTOR(3 DOWNTO 1) := "001";
	SIGNAL Indexer_TB: 		STD_LOGIC_VECTOR(16 DOWNTO 1) := "0000000000000000";
	
	
	
begin
	INST_PA: PA
	port map(
		CLK			=> CLK_TB, --48kHz clock
		TargetIndex	=> TargetIndex_TB,
		Indexer		=> Indexer_TB
	);



	Sample_clk_gen : 
	process
	begin
		wait for 10.4166 us;
		CLK_TB <= not(CLK_TB);
	end process Sample_clk_gen;
	
	TargetIndex_TB <= 	"010" after 200000 us,
						"001" after 300000 us,
						"011" after 400000 us,
						"011" after 500000 us,
						"100" after 600000 us,
						"001" after 1000000 us;
	
	
	
end arch;
