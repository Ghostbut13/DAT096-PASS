

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

entity segDisp is
  port(
	fSync:	in STD_LOGIC; --100MHz
	resetN:	in STD_LOGIC; --100MHz
	Y:		in STD_LOGIC_VECTOR(5 DOWNTO 0);
	CA:		out STD_LOGIC;
	CB:		out STD_LOGIC;
	CC:		out STD_LOGIC;
	CD:		out STD_LOGIC;
	CE:		out STD_LOGIC;
	CF:		out STD_LOGIC;
	CG:		out STD_LOGIC;
	DP:		out STD_LOGIC;
	AN:		out STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
end segDisp;

architecture Behavioral of segDisp is

	TYPE state_type IS (Num1_state, Num2_state, grabNumbs);
	SIGNAL present_state_signal:state_type;
	SIGNAL next_state_signal:state_type;
	
	SIGNAL num1:	STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL num2:	STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL dispNum: STD_LOGIC_VECTOR(3 DOWNTO 0);

begin

	tran_proc:
	PROCESS(fSync, resetN)
	BEGIN
		if resetN = '0' then
			present_state_signal <= grabNumbs;
		elsif RISING_EDGE(fSync) then
			present_state_signal <= next_state_signal;
		end if;
	END PROCESS tran_proc;
	


	flow_process:
	PROCESS(present_state_signal)
	BEGIN
		case present_state_signal is
			when grabNumbs=> 
				next_state_signal <= Num1_state;
	
			when Num1_state =>
				next_state_signal <= Num2_state;
				
			when Num2_state =>
				next_state_signal <= grabNumbs;
				
		end case;
	END PROCESS flow_process;
	
	
	state_process:
	PROCESS(present_state_signal, fSync)
	BEGIN
	if RISING_EDGE(fSync) then
		case present_state_signal is
			when grabNumbs => 
				num2 <= "00" & Y(5 DOWNTO 4);
				num1 <= Y(3 DOWNTO 0);
				dispNum <= (others => '0');
				AN(7 DOWNTO 0) <= "11111111";
				
			when Num1_state =>
				dispNum <= num1;
				AN(7 DOWNTO 0) <= "11111110";
				
			when Num2_state =>
				dispNum <= num2;
				AN(7 DOWNTO 0) <= "11111101";
				
		end case;
	end if;
	END PROCESS state_process;

	seg_process:
	PROCESS(dispNum)
	BEGIN
		DP <= '1';
		case dispNum is
			when "0000" => --0
				CA <= '0';
				CB <= '0';
				CC <= '0';
				CD <= '0';
				CE <= '0';
				CF <= '0';
				CG <= '1';
				
			when "0001" => --1
				CA <= '1';
				CB <= '0';
				CC <= '0';
				CD <= '1';
				CE <= '1';
				CF <= '1';
				CG <= '1';
			
			when "0010" => --2
				CA <= '0';
				CB <= '0';
				CC <= '1';
				CD <= '0';
				CE <= '0';
				CF <= '1';
				CG <= '0';
			
			when "0011" => --3
				CA <= '0';
				CB <= '0';
				CC <= '0';
				CD <= '0';
				CE <= '1';
				CF <= '1';
				CG <= '0';
			
			when "0100" => --4
				CA <= '1';
				CB <= '0';
				CC <= '0';
				CD <= '1';
				CE <= '1';
				CF <= '0';
				CG <= '0';
			
			when "0101" => --5
				CA <= '0';
				CB <= '1';
				CC <= '0';
				CD <= '0';
				CE <= '1';
				CF <= '0';
				CG <= '0';
			
			when "0110" => --6
				CA <= '0';
				CB <= '1';
				CC <= '0';
				CD <= '0';
				CE <= '0';
				CF <= '0';
				CG <= '0';
			
			when "0111" => --7
				CA <= '0';
				CB <= '0';
				CC <= '0';
				CD <= '1';
				CE <= '1';
				CF <= '1';
				CG <= '1';
			
			when "1000" => --8
				CA <= '0';
				CB <= '0';
				CC <= '0';
				CD <= '0';
				CE <= '0';
				CF <= '0';
				CG <= '0';
			
			when "1001" => --9
				CA <= '0';
				CB <= '0';
				CC <= '0';
				CD <= '1';
				CE <= '1';
				CF <= '0';
				CG <= '0';
			
			when "1010" => --A
				CA <= '0';
				CB <= '0';
				CC <= '0';
				CD <= '1';
				CE <= '0';
				CF <= '0';
				CG <= '0';
			
			when "1011" => --b
				CA <= '1';
				CB <= '1';
				CC <= '0';
				CD <= '0';
				CE <= '0';
				CF <= '0';
				CG <= '0';
			
			when "1100" => --c
				CA <= '1';
				CB <= '1';
				CC <= '1';
				CD <= '0';
				CE <= '0';
				CF <= '1';
				CG <= '0';
			
			when "1101" => --d
				CA <= '1';
				CB <= '0';
				CC <= '0';
				CD <= '0';
				CE <= '0';
				CF <= '1';
				CG <= '0';
			
			when "1110" => --E
				CA <= '0';
				CB <= '1';
				CC <= '1';
				CD <= '0';
				CE <= '0';
				CF <= '0';
				CG <= '0';
				
			when "1111" => --F
				CA <= '0';
				CB <= '1';
				CC <= '1';
				CD <= '1';
				CE <= '0';
				CF <= '0';
				CG <= '0';
		end case;
	END PROCESS seg_process;

	
end Behavioral;
