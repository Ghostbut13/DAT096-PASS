

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

entity M_TB is
end M_TB;

architecture arch of M_TB is
	component M is
		port(
			CLK:		in STD_LOGIC; --48kHz clock
			Input1:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
			Input2:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
			Input3:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
			Input4:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
			Output:		OUT STD_LOGIC_VECTOR(16 DOWNTO 1)
		);
	end component M;
	

	
	SIGNAL CLK_TB:			STD_LOGIC := '0'; --48kHz clock
	SIGNAL Input1_TB:		STD_LOGIC_VECTOR(16 DOWNTO 1) :="0000000000000000";
	SIGNAL Input2_TB:		STD_LOGIC_VECTOR(16 DOWNTO 1) :="0111111111111111";
	SIGNAL Input3_TB:		STD_LOGIC_VECTOR(16 DOWNTO 1) :="0000000000000000";
	SIGNAL Input4_TB:		STD_LOGIC_VECTOR(16 DOWNTO 1) :="0000000000000000";
	SIGNAL Output_TB:		STD_LOGIC_VECTOR(16 DOWNTO 1) :="0000000000000000";
	
	
begin
	INST_M: M
	port map(
		CLK			=> CLK_TB,
		Input1		=> Input1_TB,
		Input2		=> Input2_TB,
		Input3		=> Input3_TB,
		Input4		=> Input4_TB,
		Output		=> Output_TB
	);



	Sample_clk_gen : 
	process
	begin
		wait for 10.4166 us;
		CLK_TB <= not(CLK_TB);
		IF CLK_TB = '1' then
			Input1_TB <= Input1_TB + "0000000000000001";
			Input2_TB <= Input2_TB - "0000000000000010";
		END IF;
	end process Sample_clk_gen;
	
	
end arch;
