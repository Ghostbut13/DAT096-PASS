-- cross-correlation in complex algorithm
LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY Xcorr IS
	PORT(
	clk: IN STD_LOGIC;
	rst_n: IN STD_LOGIC;
	newest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	newest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	dout: OUT STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0)
	);
END ENTITY Xcorr;

ARCHITECTURE arch_Xcorr OF Xcorr IS
SIGNAL xcorr: STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');

BEGIN 	

crosscorrelation:
PROCESS(clk,rst_n)
BEGIN
	IF rst_n = '0' THEN 
	  xcorr <= (OTHERS => '0');
	END IF;
	IF FALLING_EDGE(clk) THEN 
	  xcorr <= STD_LOGIC_VECTOR(SIGNED(xcorr) + SIGNED(newest_data_1) * SIGNED(newest_data_2) - SIGNED(oldest_data_1) * SIGNED(oldest_data_2));
    END IF;
END PROCESS crosscorrelation;

  dout <= xcorr;

END ARCHITECTURE arch_Xcorr;