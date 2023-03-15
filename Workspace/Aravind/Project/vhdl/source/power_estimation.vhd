library ieee;
USE ieee.std_logic_1164.all;
--use work.power_estimation_package.all;
use ieee.numeric_std.all;

PACKAGE parameter IS
  CONSTANT SIGNAL_WIDTH :INTEGER := 16;
  CONSTANT REGISTER_LENGTH : INTEGER := 100;
  TYPE outputdata IS ARRAY(0 TO REGISTER_LENGTH-1) OF STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
END PACKAGE;

library ieee;
use work.parameter.all;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity power_estimation is
	generic(len_data: positive);
	port(clk:in std_logic;
		reset_n: in std_logic;
		data_in: in outputdata;
		--old_data:in std_logic_vector (len_data downto 0);
		--new_data: in std_logic_vector(len_data downto 0);
		power_data: out signed(SIGNAL_WIDTH-1 downto 0)
	);
end power_estimation;

architecture arc_power_estimation of power_estimation is

signal old_data_abs: std_logic_vector(SIGNAL_WIDTH-1 downto 0);
signal new_data_abs: std_logic_vector(SIGNAL_WIDTH-1 downto 0);
signal counter: integer range 0 to REGISTER_LENGTH:=0;



begin
	clk_proc: process (clk,reset_n,counter)  is
	  begin
	 -- data_in <= power_arr;
		if reset_n = '0' then
		elsif falling_edge(clk) then
			if counter < REGISTER_LENGTH then
				old_data_abs <= std_logic_vector(abs(signed(data_in(0))));
				new_data_abs <= std_logic_vector(abs(signed(data_in(counter))));
				if counter = 0 then
					power_data <= signed(old_data_abs);
				else
					power_data <= signed(new_data_abs) - signed(old_data_abs);
				end if;
			--power_data <= (old_data_abs & "0") + (new_data_abs & "0");
			end if;
		end if;
	end process clk_proc;
	
	counter_proc: process(clk,reset_n) is	
		begin
			if reset_n ='0' then
				counter <=0;
			elsif falling_edge(clk) then
				if counter < REGISTER_LENGTH then
					counter<=counter+1;
				end if;
			end if;
	end process counter_proc;
end arc_power_estimation;