

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

entity F_TB is
end F_TB;

architecture arch of F_TB is
	component F is
		port(
			CLK:			in STD_LOGIC; --48kHz clock
			SampleIn:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
			sampleOut:		out STD_LOGIC_VECTOR(16 DOWNTO 1);
			Indexer:		in STD_LOGIC_VECTOR(15 DOWNTO 1);
			RefIndex:		in STD_LOGIC_VECTOR(2 DOWNTO 1);
			Multiout:		out STD_LOGIC_VECTOR(16 downto 1)
    );
	end component F;
	

	SIGNAL CLK_TB: 			STD_LOGIC := '0';
	SIGNAL SampleIn_TB:		STD_LOGIC_VECTOR(16 DOWNTO 1) := "0111111111111111";
	SIGNAL SampleOUt_TB:	STD_LOGIC_VECTOR(16 DOWNTO 1);	
	SIGNAL Indexer_TB: 		STD_LOGIC_VECTOR(15 DOWNTO 1) := "000000000000000";
	SIGNAL RefIndex_TB:		STD_LOGIC_VECTOR(2 DOWNTO 1) := "01";
	
	SIGNAL Multi_TB:			STD_LOGIC_VECTOR(16 downto 1);
	
begin
	INST_F: F
	port map(
		CLK			=> CLK_TB, --48kHz clock
		SampleIn	=> SampleIn_TB,
		SampleOut	=> SampleOUt_TB,
		Indexer		=> Indexer_TB,
		RefIndex	=> RefIndex_TB,
		Multiout	=> Multi_TB
	);



	Sample_clk_gen : 
	process
	begin
		wait for 10.4166 us;
		CLK_TB <= not(CLK_TB);
		IF CLK_TB = '1' then
			Indexer_TB <= Indexer_TB + "000000000000001";
		END IF;
	end process Sample_clk_gen;
	
end arch;