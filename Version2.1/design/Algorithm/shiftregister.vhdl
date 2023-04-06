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
  PORT(clk: IN STD_LOGIC;
       rst_n: IN STD_LOGIC;
       din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
       dout: OUT outputdata);
END shiftregister;

ARCHITECTURE arch_shiftregister OF shiftregister IS

--implementation 1

--SIGNAL data: outputdata;

--COMPONENT singleregister IS
--  GENERIC(SIGNAL_WIDTH : INTEGER := 16);
--  PORT (clk: IN STD_LOGIC;
--        din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
--        dout: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
--END COMPONENT singleregister;

--BEGIN

--  G: FOR i IN 1 TO REGISTER_LENGTH-1 GENERATE
--	register_i:
--        COMPONENT singleregister
--  	GENERIC MAP(SIGNAL_WIDTH => SIGNAL_WIDTH)
 -- 	PORT MAP(clk => clk,
--                 din => data(i-1),
--                 dout => data(i));
--END GENERATE;

--first_register:
--COMPONENT singleregister
--  	GENERIC MAP(SIGNAL_WIDTH => SIGNAL_WIDTH)
--  	PORT MAP(clk => clk,
--                 din => din,
--                 dout => data(0));

--shift_process:
--PROCESS(clk)
--BEGIN
--  IF RISING_EDGE(clk) THEN
--      dout <= data;
--  END IF;
--END PROCESS shift_process;

--implementation 2

SIGNAL data: STD_LOGIC_VECTOR(SIGNAL_WIDTH*REGISTER_LENGTH-1 DOWNTO 0) := (others => '0');
signal dout_sig: outputdata := ((others => (others=>'0')));


COMPONENT singleregister IS
  PORT (clk: IN STD_LOGIC;
        din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
        dout: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
END COMPONENT singleregister;

BEGIN

  G: FOR i IN 0 TO REGISTER_LENGTH-1 GENERATE
	register_i:
        COMPONENT singleregister
  	PORT MAP(clk => clk,
                din => data(SIGNAL_WIDTH*(i+1)-1 DOWNTO SIGNAL_WIDTH*i),
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
   data(SIGNAL_WIDTH*REGISTER_LENGTH-1 DOWNTO SIGNAL_WIDTH) <= data(SIGNAL_WIDTH*(REGISTER_LENGTH-1)-1 DOWNTO 0);
   data(SIGNAL_WIDTH-1 DOWNTO 0) <= din;
 END IF;
END PROCESS shift_process;

dout <= dout_sig;

END arch_shiftregister;

