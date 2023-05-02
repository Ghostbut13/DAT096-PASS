-- cross-correlation in complex algorithm
LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY Xcc IS
	PORT(
	clk: IN STD_LOGIC;
	rst_n: IN STD_LOGIC;
	din: IN outputdata;	
	dout: OUT xcorrdata;
	);
END ENTITY Xcc;

ARCHITECTURE arch_Xcc OF Xcc IS

COMPONENT Xcorr IS
	PORT(
	clk: IN STD_LOGIC;
	rst_n: IN STD_LOGIC;
	newest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	newest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	dout: OUT xcorrdata_half
	);
END COMPONENT Xcorr;

SIGNAL xcorr_positive : xcorrdata_shift := (OTHERS => (OTHERS => '0'));
SIGNAL xcorr_negative : xcorrdata_shift := (OTHERS => (OTHERS => '0'));

BEGIN
    xcorrp:
    COMPONENT Xcorr
	PORT MAP(
	clk => clk,
	rst_n => rst_n,
	newest_data_1 => xcorr_positive(),
	oldest_data_1 => xcorr_positive(),
	newest_data_2 => din(),
	oldest_data_2 => din(),
	dout: => dout(0 TO xcorr_REGISTER_LENGTH/2-1)
	);
	
	xcorrn:
    COMPONENT Xcorr
	PORT MAP(
	clk => clk,
	rst_n => rst_n,
	newest_data_1 => xcorr_negative(),
	oldest_data_1 => xcorr_negative(),
	newest_data_2 => din(),
	oldest_data_2 => din(),
	dout => dout(xcorr_REGISTER_LENGTH/2 TO xcorr_REGISTER_LENGTH)
	);
  
    FOR xcorr_WINDOW in 1 TO 140 LOOP 
	  xcorr_positive <= din(xcorr_REGISTER_LENGTH- xcorr_WINDOW_LENGTH-1 DOWNTO 0);
	  xcorr_negative <= din(xcorr_REGISTER_LENGTH DOWNTO xcorr_WINDOW_LENGTH-1);
	END LOOP;
	
END ARCHITECTURE;