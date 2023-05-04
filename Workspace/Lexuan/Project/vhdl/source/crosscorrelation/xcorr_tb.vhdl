LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY xcorr_tb IS 
--
END ENTITY xcorr_tb;

ARCHITECTURE arch_xcorr_tb OF xcorr_tb IS

SIGNAL clk_tb : STD_LOGIC := '0';
SIGNAL rst_n_tb : STD_LOGIC := '1';
SIGNAL din_c1_tb : STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL din_c2_tb : STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL din_xcorr1_tb : outputdata := (OTHERS => (OTHERS => '0'));
SIGNAL din_xcorr2_tb : outputdata := (OTHERS => (OTHERS => '0'));
SIGNAL dout_tb : xcorrdata := (OTHERS => (OTHERS => '0'));

COMPONENT Xcc IS
	PORT(
	clk: IN STD_LOGIC;
	rst_n: IN STD_LOGIC;
	din_c1: IN outputdata;
	din_c2: IN outputdata;
	dout: OUT xcorrdata
	);
END COMPONENT Xcc;

COMPONENT shiftregister IS
  GENERIC(INPUT_WIDTH : INTEGER;
          REGISTER_NUM : INTEGER);
  PORT(clk: IN STD_LOGIC;
       rst_n: IN STD_LOGIC;
       din: IN STD_LOGIC_VECTOR(INPUT_WIDTH-1 DOWNTO 0);
       dout: OUT outputdata);
END COMPONENT shiftregister;

BEGIN 
  Xcorr_inst:
  COMPONENT Xcc
    PORT MAP(
	clk => clk_tb,
	rst_n => rst_n_tb,
    din_c1 => din_xcorr1_tb,
	din_c2 => din_xcorr2_tb,
    dout => dout_tb
	);

  shiftregister_c1_inst:
  COMPONENT shiftregister
  GENERIC MAP(INPUT_WIDTH => SIGNAL_WIDTH,
          REGISTER_NUM => REGISTER_LENGTH)
  PORT MAP(clk => clk_tb,
       rst_n => rst_n_tb,
       din => din_c1_tb,
       dout => din_xcorr1_tb
	   );
	   
  shiftregister_c2_inst:
  COMPONENT shiftregister
  GENERIC MAP(INPUT_WIDTH => SIGNAL_WIDTH,
          REGISTER_NUM => REGISTER_LENGTH)
  PORT MAP(clk => clk_tb,
       rst_n => rst_n_tb,
       din => din_c2_tb,
       dout => din_xcorr2_tb
	   );



clk_proc:
PROCESS
BEGIN
  WAIT FOR 5 ns;
  clk_tb <= NOT(clk_tb);
END PROCESS clk_proc;

 rst_n_tb <= '0' after 13 ns,
             '1' after 18 ns;
			 
 din_c1_tb <= "0000000000000001" after 3 ns,
                     "0000000000000101" after 13 ns,
					 "0000000000000010" after 23 ns;
 
 
 din_c2_tb <= "0000000000000001" after 13 ns,
                     "0000000000000101" after 23 ns,
					 "0000000000000010" after 33 ns;
 

END ARCHITECTURE arch_xcorr_tb;