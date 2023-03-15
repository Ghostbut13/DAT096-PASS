library ieee;
USE ieee.std_logic_1164.all;
--use work.power_estimation_package.all;
use work.parameter.all;
use ieee.numeric_std.all;

-- PACKAGE parameter IS
  -- CONSTANT SIGNAL_WIDTH :INTEGER := 16;
  -- CONSTANT REGISTER_LENGTH : INTEGER := 5;
  -- TYPE outputdata IS ARRAY(0 TO REGISTER_LENGTH-1) OF STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
 -- signal test_data: power_arr :=("1010101010101010","0101010101010101","1111111100000000","0000000011111111","1111111111111111");
-- END PACKAGE;

--library ieee;
--use work.parameter.all;
--USE ieee.std_logic_1164.all;
--use ieee.numeric_std.all;


entity power_estimation is
	generic(len_data: positive);
	port(clk:in std_logic;
		reset_n: in std_logic;
		data_in: in outputdata;
		--old_data:in std_logic_vector (len_data downto 0);
		--new_data: in std_logic_vector(len_data downto 0);
		power_data: out std_logic_vector(SIGNAL_WIDTH-1 downto 0)
	);
end power_estimation;

architecture arc_power_estimation of power_estimation is

signal old_data_abs: std_logic_vector(SIGNAL_WIDTH-1 downto 0);
signal new_data_abs: std_logic_vector(SIGNAL_WIDTH-1 downto 0);
--signal counter: integer range 0 to REGISTER_LENGTH:=0;



begin
	clk_proc: process (clk,reset_n)  is
	  begin
	 -- data_in <= power_arr;
		old_data_abs <= std_logic_vector(abs(signed(data_in(REGISTER_LENGTH-1))));
		new_data_abs <= std_logic_vector(abs(signed(data_in(0))));	
		if reset_n = '0' then
		elsif falling_edge(clk) then
		--unsigned cuz std_logic_vector wasn't working to check for the undefined functionality
			--old_data_abs <= data_in(REGISTER_LENGTH-1);
			--if std_logic_vector(to_unsigned(unsigned(old_data_abs), SIGNAL_WIDTH)) = (others =>'U') then
				--old_data_abs <= (others =>'0');
			--end if;
			
			power_data <= std_logic_vector(signed(new_data_abs) - signed(old_data_abs));
		end if;
	end process clk_proc;
end arc_power_estimation;