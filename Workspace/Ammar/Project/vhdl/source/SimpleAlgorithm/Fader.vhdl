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
	SIGNAL SampleOutSig: Signed(32 DOWNTO 1) := (others => '0');
	SIGNAL delta       : signed(16 DOWNTO 1);

begin


	F_process:
	PROCESS(CLK, RefIndex, Indexer, SampleIn, Multiplicant, SampleOutSig)
	BEGIN
	
	SampleInSig <= signed(SampleIn);
	
	
	IF FALLING_EDGE(CLK) then
		delta <=abs(signed("0" & RefIndex & "000000000000") - signed("0" & Indexer(15 DOWNTO 1)));
		IF delta < "0001" & "000000000000"  then
			Multiplicant <= "0001" & "000000000000" - delta;
			
		ELSE 
			Multiplicant <= "0000000000000000";
		END IF;
		SampleOutSig <= SampleInSig & "0000000000000000"; --* Multiplicant;
		
	END IF;
	Multiout <= STD_LOGIC_VECTOR(Multiplicant);
	--Multiout <= STD_LOGIC_VECTOR(delta);
	SampleOut <= STD_LOGIC_VECTOR(SampleOutSig(29 DOWNTO 14));
	
	END PROCESS F_process;


	
end Behavioral;
