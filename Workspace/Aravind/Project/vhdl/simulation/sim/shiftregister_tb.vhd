LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY shiftregister_tb IS 
END shiftregister_tb;

ARCHITECTURE arch_shiftregister_tb OF shiftregister_tb IS

SIGNAL din_tb:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
SIGNAL dout_tb: STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
SIGNAL clk_tb: STD_LOGIC := '0';
signal counter: integer range 0 to REGISTER_LENGTH:= 0;

  COMPONENT shiftregister IS
  PORT(clk: IN STD_LOGIC;
       din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
       dout: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
  END COMPONENT shiftregister;

BEGIN
  shiftregister_inst:
  COMPONENT shiftregister
    PORT MAP(clk => clk_tb,
             din => din_tb,
             dout => dout_tb);

clk_proc:
PROCESS
BEGIN
  WAIT FOR 5 ns;
  clk_tb <= NOT(clk_tb);
END PROCESS clk_proc;

test_proc: process 
	begin
		wait for 3 ns;
		if counter < 5 then
			din_tb <= test_data(counter);
			counter <= counter +1;
		end if;
		if counter = 4 then
			  counter <= 0;
		end if;
		wait for 6 ns;
	end process test_proc;


END arch_shiftregister_tb;


