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
	din_c1: IN outputdata;
	din_c2: IN outputdata;
	dout: OUT xcorrdata
	);
END ENTITY Xcc;

ARCHITECTURE arch_Xcc OF Xcc IS

SIGNAL dout_sig : xcorrdata;

COMPONENT Xcorr IS
	PORT(
	clk: IN STD_LOGIC;
	rst_n: IN STD_LOGIC;
	newest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	newest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	dout: OUT STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0)
	);
END COMPONENT Xcorr;

BEGIN
	
	xcorr_positive_inst:
	FOR lag IN 0 TO xcorr_MAXLAG-1 GENERATE
	xcorr_inst_i:
      COMPONENT Xcorr
	  PORT MAP(
	  clk => clk,
	  rst_n => rst_n,
	  newest_data_1 => din_c1(0),
	  oldest_data_1 => din_c1(REGISTER_LENGTH - xcorr_MAXLAG),
	  newest_data_2 => din_c2(lag),
	  oldest_data_2 => din_c2(REGISTER_LENGTH - xcorr_MAXLAG + lag),
	  dout => dout_sig(lag+xcorr_MAXLAG)
	  );
	END GENERATE;
	  
	xcorr_negative_inst:
	FOR lag IN 0 TO xcorr_MAXLAG-1 GENERATE
	xcorr_inst_i:
      COMPONENT Xcorr
	  PORT MAP(
	  clk => clk,
	  rst_n => rst_n,
	  newest_data_1 => din_c1(lag),
	  oldest_data_1 => din_c1(REGISTER_LENGTH - xcorr_MAXLAG + lag),
	  newest_data_2 => din_c2(0),
	  oldest_data_2 => din_c2(REGISTER_LENGTH - xcorr_MAXLAG),
	  dout => dout_sig(lag)
	  );
	END GENERATE;
 
 dout <= dout_sig;
	
END ARCHITECTURE;