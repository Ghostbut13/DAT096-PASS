

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

entity F is
  port(
	MCLK:			in STD_LOGIC; --1000MHz
	EN_CLK:			in STD_LOGIC; --48kHz clock
	CLKOUT:			out STD_LOGIC;
	SamplesIn:		in outputdata;
	indexOut:		out STD_LOGIC_VECTOR(16 DOWNTO 1);
    );
end F;

architecture Behavioral of F is
	--SIGNAL SampleInSig: Signed(16 DOWNTO 1);
	SIGNAL indexer: unsigned(7 downto 1):= 0;
	SIGNAL MaxVal:  unsigned(16 downto 1):=0;
	Signal INEX:	unsigned(7 downto 1):=0;
	SIGNAL newC:	boolean()
begin


	F_process:
	PROCESS(MCLK)
	BEGIN
	
	SampleInSig <= signed(SampleIn);
	
	
	IF rising_edge(EN_CLK) then
		indexer = 0;
	elsif rising_edge(MCLK) then
		if indexer < 100 then
			CLKOUT = 0;
			indexer <= indexer +1;
			--- actual max function
				IF SamplesIn(indexer) > MaxVal then
					MaxVal <= SamplesIn(indexer);
					INEX <= indexer;
				END
		else then 
			CLKOUT = CLK
		end
		
	END IF;
	
	END PROCESS F_process;


	
end Behavioral;
