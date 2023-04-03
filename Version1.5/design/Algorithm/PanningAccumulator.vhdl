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

entity PA is
  port(
	CLK:			in STD_LOGIC; --48kHz clock
	TargetIndex:	IN STD_LOGIC_VECTOR(3 DOWNTO 1);
	Indexer:		OUT STD_LOGIC_VECTOR(16 DOWNTO 1)
    );
end PA;

architecture Behavioral of PA is
	CONSTANT PanningDelta: STD_LOGIC_VECTOR(16 DOWNTO 1) := "0000000000000001";  -- 2^-13 ~ 0.0001 
	SIGNAL IndexerSig: STD_LOGIC_VECTOR(16 DOWNTO 1) := "0000000000000000";

begin

  --JC(4 DOWNTO 1) <= dac_vec(4 DOWNTO 1);
  --JC(8 DOWNTO 5) <= dac_vec(8 DOWNTO 5);
  --JD(4 DOWNTO 1) <= dac_vec(16 DOWNTO 13);
  --JD(8 DOWNTO 5) <= dac_vec(12 DOWNTO 9);
  
  
  

	PA_process:
	PROCESS(CLK, IndexerSig, TargetIndex)
	BEGIN
	IF FALLING_EDGE(CLK) then
		IF IndexerSig > TargetIndex & "0000000000000" then
			IndexerSig <= IndexerSig - PanningDelta;
		ELSIF IndexerSig < TargetIndex  & "0000000000000" then
			IndexerSig <= IndexerSig + PanningDelta;
		ELSE
			IndexerSig <= IndexerSig;
		END IF;
	END IF;
	Indexer <= IndexerSig;
	
	END PROCESS PA_process;


	
end Behavioral;
