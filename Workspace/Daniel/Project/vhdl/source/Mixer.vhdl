

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

entity M is
  port(
	CLK:			in STD_LOGIC; --48kHz clock
	Input1:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input2:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input3:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input4:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Output:		OUT STD_LOGIC_VECTOR(16 DOWNTO 1)
    );
end M;

architecture Behavioral of M is
	SIGNAL sum: STD_LOGIC_VECTOR(16 DOWNTO 1);

begin


	M_process:
	PROCESS(CLK)
	BEGIN
	
	
	IF rising_edge(CLK) then
		sum <= Input1 + Input2 + Input3 + Input4;
		
	END IF;
	Output <= sum(16 DOWNTO 1);
	END PROCESS M_process;


	
end Behavioral;