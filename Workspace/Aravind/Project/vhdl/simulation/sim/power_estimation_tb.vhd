library ieee;
USE ieee.std_logic_1164.all;
--use work.power_estimation_package.all;
use work.parameter.all;
use ieee.numeric_std.all;

--PACKAGE parameter IS
--  CONSTANT SIGNAL_WIDTH :INTEGER := 16;
 -- CONSTANT REGISTER_LENGTH : INTEGER := 5;
 -- TYPE outputdata IS ARRAY(0 TO REGISTER_LENGTH-1) OF STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
 -- signal test_data: outputdata :=("1010101010101010","0101010101010101","1111111100000000","0000000011111111","1111111111111111");
--END PACKAGE;

--library ieee;
--use work.parameter.all;
--USE ieee.std_logic_1164.all;
--use ieee.numeric_std.all;


entity power_estimation_tb is
end power_estimation_tb;

architecture arc_power_estimation_tb of power_estimation_tb is
 component power_estimation is
	 generic(len_data: positive);
	 port(clk:in std_logic;
		 reset_n: in std_logic;
		 data_in: in outputdata;
		old_data:in std_logic_vector (len_data downto 0);
		new_data: in std_logic_vector(len_data downto 0);
		power_data: out std_logic_vector(SIGNAL_WIDTH-1 downto 0)
	 );
 end component;



--COMPONENT shiftregister IS
--  GENERIC(SIGNAL_WIDTH:INTEGER := 16;
--           REGISTER_LENGTH:INTEGER := 1000);
 -- PORT(clk: IN STD_LOGIC;
   --    din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH_tb-1 DOWNTO 0);
     --  dout: OUT outputdata);
  --END COMPONENT shiftregister; 
--constant len_data:positive  :=15;

signal reset_n_tb:std_logic:='1';
signal clk_tb:std_logic:='0';
signal old_data_tb:std_logic_vector(SIGNAL_WIDTH-1 downto 0);
signal new_data_tb:std_logic_vector(SIGNAL_WIDTH-1 downto 0);
signal power_data_tb:std_logic_vector(SIGNAL_WIDTH-1 downto 0);
signal data_in_tb: outputdata;


begin
 power_estimation_inst: component power_estimation
	 generic map(len_data=>SIGNAL_WIDTH)
	 port map(reset_n=>reset_n_tb, clk=>clk_tb, data_in=>data_in_tb, power_data=>power_data_tb);
	
	
	 shiftregister_inst:
  /* COMPONENT shiftregister
--    GENERIC MAP(SIGNAL_WIDTH => SIGNAL_WIDTH_tb,
--                REGISTER_LENGTH => REGISTER_LENGTH_tb)
    PORT MAP(clk => clk_tb,
             din => din_tb,
             dout => dout_tb); */
			 
			 
	clk_proc: process
	begin	
		wait for 5 ns;
		clk_tb <= not clk_tb;
	end process;
	
	--old_data_tb <= "0101010101010101";
	--new_data_tb <= "1010101010101010";
	data_in_tb <= test_data;
	
end arc_power_estimation_tb;