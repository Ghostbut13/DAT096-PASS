LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY MAX1000 IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din : IN xcorrdata;
	dout : OUT STD_LOGIC_VECTOR(29 DOWNTO 0)
	);
END ENTITY MAX1000;

ARCHITECTURE arch_MAX1000 OF MAX1000 IS
signal current_index : integer := 0;
signal current_MAX : std_logic_vector(15 downto 0) := (others=>'0');
signal MAX_INDEX : std_logic_vector(13 downto 0) := (others=>'0');

  begin 
  -- iterative function to determine the max input.
	process(din, rst_n, clk)
	  BEGIN
	  if (rst_n = '0') then
		current_MAX <= (others=>'0');
		MAX_INDEX <= (others => '0');
	
	  elsif falling_edge(clk) then	  
		  --FOR current_index IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
		  FOR current_index IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
			  if din(current_index) > current_MAX then
				current_MAX <= din(current_index);
				MAX_INDEX <= std_logic_vector(to_unsigned(current_index+1, MAX_INDEX'length));
		  end if;
		  END LOOP;
	  end if;
	END process;

 dout <= current_MAX & MAX_INDEX;
END arch_MAX1000;
