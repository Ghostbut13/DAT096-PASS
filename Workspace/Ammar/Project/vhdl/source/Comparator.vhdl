-- using different librarys to define the functions
-- I will use these librarys for every code
library ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity uppgift1 is
    Port ( m1,m0, clk : in  STD_LOGIC;
           Q2,Q1,Q0: out  STD_LOGIC);
end uppgift1;

architecture beteende of uppgift1 is

-- create a temporary signal to save the value for every case
-- give the vector value 0 each time the user starts it
signal temp: std_logic_vector(2 downto 0):= "000";

	begin
	process(clk)
	begin

	if(rising_edge(clk))then 

	if ((m1 and m0) = '0') then
	temp <= temp;
	end if;

	if ((not m1 and m0) = '1') then
	-- up counting
	temp <= temp+1;
	end if;

	if ((not m1 and m0) = '0') then
	-- down counting
	temp <= temp-1;
	end if;

	if ((m1 and m0) = '1') then
	-- up counting by 2 
	temp <= temp+2;
	end if;
	
	end if;
	end process;
	
-- give the outputs their value from the temporary vector
Q2<=temp(2);
Q1<=temp(1);
Q0<=temp(0);
	
end beteende;