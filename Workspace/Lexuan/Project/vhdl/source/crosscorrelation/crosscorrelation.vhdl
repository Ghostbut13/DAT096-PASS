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
	-- for CC1 channel 1 is the loudest channel, 2 is the second loudest channel
	-- for CC1 channel 1 is the loudest channel, 2 is the third loudest channel
	newest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	newest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	oldest_data_2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
    -- outputdata: an array where 1000 cross-correlation values are stored	
	dout: OUT xcorrdata
	);
END ENTITY Xcorr;

ARCHITECTURE arch_Xcorr OF Xcorr IS

SIGNAL xcorr: STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL xcorr_out: STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');
SIGNAL shiftregister_out: xcorrdata := (OTHERS => (OTHERS => '0'));
	
COMPONENT shiftregister IS 
    GENERIC(
	INPUT_WIDTH : INTEGER;
    REGISTER_NUM : INTEGER
    );	
	PORT(
	clk: IN STD_LOGIC;
	rst_n: IN STD_LOGIC;
	din: IN STD_LOGIC_VECTOR(INPUT_WIDTH-1 DOWNTO 0);
    dout: OUT xcorrdata
	);
END COMPONENT shiftregister;

BEGIN 
	xcorr_array:
	COMPONENT shiftregister
	GENERIC MAP(
	INPUT_WIDTH => xcorr_SIGNAL_WIDTH,
	REGISTER_NUM => xcorr_REGISTER_LENGTH)
	PORT MAP(
	clk => clk,
	rst_n => rst_n,
	din => xcorr,
	dout => shiftregister_out
	);
	

crosscorrelation:
PROCESS(clk,rst_n)
BEGIN
	IF rst_n = '0' THEN 
	  shiftregister_out <= (OTHERS =>(OTHERS => '0'));
	END IF;
	IF FALLING_EDGE(clk) THEN 
	  xcorr <= STD_LOGIC_VECTOR(SIGNED(xcorr) + SIGNED(newest_data_1) * SIGNED(newest_data_2) - SIGNED(oldest_data_1) * SIGNED(oldest_data_2));
    END IF;
END PROCESS crosscorrelation;

  dout <= shiftregister_out;

END ARCHITECTURE arch_Xcorr;