-- this design takes in the added grid from the three cross corelations pixel after pixel
-- 64x128 = 8192 pixels in total. The flow of the design is controlled by the image capturing program which triggers
-- a rst_n signal to make it stop outputting the max signal.

LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
--USE work.parameter.ALL;

ENTITY maxLUT IS 
	PORT(
	clk		   : IN STD_LOGIC;
	rst_n 	   : IN STD_LOGIC;
	din 	   : IN STD_LOGIC_VECTOR (33 downto 0);
	xy_pos_in  : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
	xy_pos_out : OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
	);
END ENTITY maxLUT;

ARCHITECTURE arch_maxLUT OF maxLUT IS

signal current_MAX 		 : std_logic_vector(33 downto 0) := (others=>'0');
signal xy_pos_out_signal : std_logic_vector(12 downto 0) := (others=>'0'); -- 6 bits x, 6 bits y.

  begin 
  -- iterative function to determine the max input.
	process(rst_n, clk)
	  BEGIN
	  if (rst_n = '0') then
		current_MAX <= (others=>'0');
		xy_pos_out_signal <= (others => '0');
	
	  elsif rising_edge(clk) then	  
		  if din > current_MAX then
			current_MAX <= din;
			xy_pos_out_signal <= xy_pos_in;
		  end if;
	  end if;
	END process;

 xy_pos_out <= xy_pos_out_signal;
 
END arch_maxLUT;
