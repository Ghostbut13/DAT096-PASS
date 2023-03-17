library ieee;
USE ieee.std_logic_1164.all;
--use work.power_estimation_package.all;
use work.parameter.all;
use ieee.numeric_std.all;

entity power_estimation is
	generic(len_data: positive);
	port(clk:in std_logic;
		reset_n: in std_logic;
		data_in: in outputdata;
		power_data: out std_logic_vector(SIGNAL_WIDTH-1 downto 0)
	);
end power_estimation;

architecture arc_power_estimation of power_estimation is

signal old_data_abs: std_logic_vector(SIGNAL_WIDTH-1 downto 0);
signal new_data_abs: std_logic_vector(SIGNAL_WIDTH-1 downto 0);



begin
	clk_proc: process (clk,reset_n)  is
	  begin
	 -- data_in <= power_arr;
		old_data_abs <= std_logic_vector(abs(signed(data_in(REGISTER_LENGTH-1))));
		new_data_abs <= std_logic_vector(abs(signed(data_in(0))));	
		if reset_n = '0' then
		elsif falling_edge(clk) then
			power_data <= std_logic_vector(signed(new_data_abs) - signed(old_data_abs));
		end if;
	end process clk_proc;
end arc_power_estimation;