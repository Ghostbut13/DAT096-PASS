LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY MAXbitor IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din : IN xcorrdata;
	dout_index : OUT STD_LOGIC_VECTOR(xcorr_INDEX_WIDTH-1 DOWNTO 0)
	);
END ENTITY MAXbitor;

ARCHITECTURE arch_MAXbitor OF MAXbitor IS

  SIGNAL addIndex_output_signal : xcorrindex := (OTHERS => (OTHERS => '0')); 
  
  COMPONENT addIndex IS
  PORT(
    clk : IN STD_LOGIC;
	din : IN xcorrdata;
	dout : OUT xcorrindex
	);
  END COMPONENT addIndex;
  
  COMPONENT bitor IS 
  PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din : IN xcorrindex;
	dout_index : OUT STD_LOGIC_VECTOR(xcorr_INDEX_WIDTH-1 DOWNTO 0)
	);
  END COMPONENT bitor;
  
BEGIN
  
 addIndex_inst:
  COMPONENT addIndex
  PORT MAP(
    clk => clk,
	din => din,
	dout => addIndex_output_signal
  );
	
 bitor_inst:
  COMPONENT bitor 
  PORT MAP(
	clk => clk,
	rst_n => rst_n,
	din => addIndex_output_signal,
	dout_index  => dout_index
	);
  
END ARCHITECTURE arch_MAXbitor;