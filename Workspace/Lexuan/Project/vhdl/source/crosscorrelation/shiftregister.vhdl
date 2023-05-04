--shift register
--Input signal: 16-bit vector
--Output signal: a 2-D array: 16 columns * 100 rows
--first sample on the left end
--neweast sample on the right end
--when a new sample comes, all the samples shift up

-- 2 ways of implementation
-- 1. connect 100 of 16-bit-register together
-- 2. create a 1600-bit vector


LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY shiftregister IS
  GENERIC(INPUT_WIDTH : INTEGER;
          REGISTER_NUM : INTEGER);
  PORT(clk: IN STD_LOGIC;
       rst_n: IN STD_LOGIC;
       din: IN STD_LOGIC_VECTOR(INPUT_WIDTH-1 DOWNTO 0);
       dout: OUT outputdata);
END shiftregister;

ARCHITECTURE arch_shiftregister OF shiftregister IS

SIGNAL data: STD_LOGIC_VECTOR(INPUT_WIDTH*REGISTER_NUM-1 DOWNTO 0) := (others => '0');
signal dout_sig: outputdata := ((others => (others=>'0')));


COMPONENT singleregister IS
  GENERIC (INPUT_WIDTH : INTEGER);
  PORT (clk: IN STD_LOGIC;
        din: IN STD_LOGIC_VECTOR(INPUT_WIDTH-1 DOWNTO 0);
        dout: OUT STD_LOGIC_VECTOR(INPUT_WIDTH-1 DOWNTO 0));
END COMPONENT singleregister;

BEGIN

  G: FOR i IN 0 TO REGISTER_NUM-1 GENERATE
	register_i:
    COMPONENT singleregister
	GENERIC MAP (INPUT_WIDTH => INPUT_WIDTH)
  	PORT MAP(clk => clk,
             din => data(INPUT_WIDTH*(i+1)-1 DOWNTO INPUT_WIDTH*i),
             dout => dout_sig(i));
END GENERATE;


--
shift_process:
PROCESS(clk, rst_n)
BEGIN
IF rst_n = '0' THEN
	data <= (OTHERS=> '0');
END IF;
IF RISING_EDGE(clk) THEN
   data(INPUT_WIDTH*REGISTER_NUM-1 DOWNTO INPUT_WIDTH) <= data(INPUT_WIDTH*(REGISTER_NUM-1)-1 DOWNTO 0);
   data(INPUT_WIDTH-1 DOWNTO 0) <= din;
 END IF;
END PROCESS shift_process;

dout <= dout_sig;

END arch_shiftregister;

