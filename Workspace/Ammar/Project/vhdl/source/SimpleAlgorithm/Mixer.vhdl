

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

entity mixer is
  port(
	CLK:		in STD_LOGIC; --48kHz clock
	Input1:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input2:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input3:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input4:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Output:		OUT STD_LOGIC_VECTOR(16 DOWNTO 1)
    );
end mixer;

architecture Behavioral of mixer is
	SIGNAL sum: STD_LOGIC_VECTOR(16 DOWNTO 1);

begin


	M_process:
	PROCESS(CLK, Input1, Input2, Input3, Input4)
	BEGIN
	
	
	IF FALLING_EDGE(CLK) then
		sum <= Input1 + Input2 + Input3 + Input4;
		
	END IF;
    END PROCESS M_process;

	Output <= sum(16 DOWNTO 1);
	--Output <= std_logic_vector(unsigned(sum(16 DOWNTO 1))+to_unsigned(16#8000#,16));

	
end Behavioral;
