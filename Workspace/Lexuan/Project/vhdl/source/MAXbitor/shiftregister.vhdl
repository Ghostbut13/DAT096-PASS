-- Leuxan Tang 2023/04/10

-- sub-block in maxbitor block
-- function: delay the data from transposition block by several cycles to make sure the bitor block get correct data
-- the first colomn doesn't need to be delayed
-- the second colomn needs to be delayed for 1 cycle
-- the last colomn needs to be delayed for 31 cycles

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
       dout: OUT STD_LOGIC_VECTOR(INPUT_WIDTH-1 DOWNTO 0));
END shiftregister;

ARCHITECTURE arch_shiftregister OF shiftregister IS

TYPE datasize IS ARRAY (0 TO REGISTER_NUM-1) OF STD_LOGIC_VECTOR(INPUT_WIDTH-1 DOWNTO 0);

SIGNAL data: STD_LOGIC_VECTOR(INPUT_WIDTH*REGISTER_NUM-1 DOWNTO 0) := (others => '0');
signal dout_sig: datasize := ((others => (others=>'0')));


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
IF FALLING_EDGE(clk) THEN
   data(INPUT_WIDTH*REGISTER_NUM-1 DOWNTO INPUT_WIDTH) <= data(INPUT_WIDTH*(REGISTER_NUM-1)-1 DOWNTO 0);
   data(INPUT_WIDTH-1 DOWNTO 0) <= din;
 END IF;
END PROCESS shift_process;

dout <= dout_sig(REGISTER_NUM-1);

END arch_shiftregister;

