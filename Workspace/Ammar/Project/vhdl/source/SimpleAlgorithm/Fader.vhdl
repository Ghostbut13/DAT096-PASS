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

entity fader is
  port(
	CLK:			in STD_LOGIC; --48kHz clock
	SampleIn:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	sampleOut:		out STD_LOGIC_VECTOR(16 DOWNTO 1);
	Indexer:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	RefIndex:		in STD_LOGIC_VECTOR(3 DOWNTO 1);
	Multiout:		out STD_LOGIC_VECTOR(16 downto 1)
    );
end fader;

architecture Behavioral of fader is
	SIGNAL SampleInSig: Signed(16 DOWNTO 1);
	SIGNAL Multiplicant: Signed(16 DOWNTO 1);
	SIGNAL SampleOutSig: Signed(32 DOWNTO 1);
	SIGNAL delta:		signed(16 DOWNTO 1);

begin

	SampleInSig <= signed(SampleIn);

	F_process:
	PROCESS(CLK, SampleInSig, Indexer, RefIndex)
	BEGIN
	
	--delta <=abs(signed("0" & RefIndex & "000000000000") - signed("0" & Indexer(15 DOWNTO 1)));
	delta <= abs(signed(RefIndex & "0000000000000" - Indexer(16 downto 1)));
	IF FALLING_EDGE(CLK) then
		-- delta between target index and current indexer value
		IF delta < "001" & "0000000000000"  then
			Multiplicant <= "001" & "0000000000000" - delta;
			
		ELSE 
			Multiplicant <= "0000000000000000";
		END IF;
		
		SampleOutSig <= SampleInSig * Multiplicant;
	END IF;
	
	--Multiout <= STD_LOGIC_VECTOR(delta);
	
	END PROCESS F_process;

	Multiout <= STD_LOGIC_VECTOR(Multiplicant);
	SampleOut <= STD_LOGIC_VECTOR(SampleOutSig(29 DOWNTO 14));

	
end Behavioral;
