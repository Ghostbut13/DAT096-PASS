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
SIGNAL newest_data_1_tb : STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
SIGNAL newest_data_2_tb : STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
SIGNAL oldest_data_1_tb : STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
SIGNAL oldest_data_2_tb : STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
SIGNAL dout_tb : xcorrdata;

COMPONENT Xcorr IS
	PORT(
	clk: IN STD_LOGIC;
	rst_n: IN STD_LOGIC;
	newest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	newest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	dout: OUT xcorrdata
	);
END COMPONENT Xcorr;

BEGIN 
  Xcorr_inst:
  COMPONENT Xcorr
    PORT MAP(
	clk => clk_tb,
	rst_n => rst_n_tb,
	newest_data_1 => newest_data_1_tb,
	newest_data_2 => newest_data_2_tb,
	oldest_data_1 => oldest_data_1_tb,
	oldest_data_2 => oldest_data_2_tb,
    dout => dout_tb
	);

clk_proc:
PROCESS
BEGIN
  WAIT FOR 5 ns;
  clk_tb <= NOT(clk_tb);
END PROCESS clk_proc;

 newest_data_1_tb <= "0000000000000001" after 3 ns,
                     "0000000000000101" after 13 ns,
					 "0000000000000010" after 23 ns,
					 "0000000000001000" after 33 ns,
					 "0000000000001001" after 43 ns,
					 "0000000000000111" after 53 ns,
					 "0000000000000001" after 63 ns;
 
 
 newest_data_2_tb <= "0000000000000001" after 3 ns,
                     "0000000000000001" after 13 ns,
					 "0000000000000001" after 23 ns,
					 "0000000000000001" after 33 ns,
					 "0000000000000001" after 43 ns,
					 "0000000000000001" after 53 ns,
                     "0000000000000001" after 63 ns;
 
 
 oldest_data_1_tb <= "0010000000000001" after 3 ns,
                     "0000010000000101" after 13 ns,
					 "0000000000000010" after 23 ns,
					 "0000000000001000" after 33 ns,
					 "0000000000001001" after 43 ns,
					 "0000000000000111" after 53 ns,
					 "0000000000000001" after 63 ns;
 
 
 
 oldest_data_2_tb <= "0000000000000010" after 3 ns,
                     "0000000000000001" after 13 ns,
					 "0000000000000010" after 23 ns,
					 "0000000000000001" after 33 ns,
					 "0111111000000001" after 43 ns,
					 "0000000000111111" after 53 ns,
                     "0000011111110001" after 63 ns;

END ARCHITECTURE arch_xcorr_tb;