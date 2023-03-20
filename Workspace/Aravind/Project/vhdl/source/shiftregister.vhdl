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
USE ieee.std_logic_1164.ALL;

PACKAGE parameter IS
  CONSTANT SIGNAL_WIDTH :INTEGER := 16;
  CONSTANT REGISTER_LENGTH : INTEGER := 5;
  TYPE outputdata IS ARRAY(0 TO REGISTER_LENGTH-1) OF STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  signal test_data: outputdata :=("1010101010101010","0101010101010101","1111111100000000","0000000011111111","1111111111111111");
END PACKAGE;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY work;
USE work.parameter.ALL;

ENTITY shiftregister IS
  PORT(clk: IN STD_LOGIC;
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
signal power_data_tb : std_logic_vector(SIGNAL_WIDTH-1 downto 0);
signal reset_n_tb: std_logic :='1';
signal dout_sig: outputdata := ((others => (others=>'0')));


COMPONENT singleregister IS
  GENERIC(SIGNAL_WIDTH : INTEGER := 16);
  PORT (clk: IN STD_LOGIC;
       din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
        dout: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
END COMPONENT singleregister;

component power_estimation is
	 generic(len_data: positive);
	 port(clk:in std_logic;
		 reset_n: in std_logic;
		 data_in: in outputdata;
		--old_data:in std_logic_vector (len_data downto 0);
		--new_data: in std_logic_vector(len_data downto 0);
		power_data: out std_logic_vector(SIGNAL_WIDTH-1 downto 0)
	 );
 end component;

BEGIN

  G: FOR i IN 0 TO REGISTER_LENGTH-1 GENERATE
	register_i:
        COMPONENT singleregister
 	GENERIC MAP(SIGNAL_WIDTH => SIGNAL_WIDTH)
  	PORT MAP(clk => clk,
                din => data(SIGNAL_WIDTH*(i+1)-1 DOWNTO SIGNAL_WIDTH*i),
                dout => dout_sig(i));
END GENERATE;

power_estimation_inst: component power_estimation
	 generic map(len_data=>SIGNAL_WIDTH)
	 port map(reset_n=>reset_n_tb, clk=>clk, data_in=>dout_sig, power_data=>power_data_tb);

--
shift_process:
PROCESS(clk)
BEGIN
IF FALLING_EDGE(clk) THEN
   data(SIGNAL_WIDTH*REGISTER_LENGTH-1 DOWNTO SIGNAL_WIDTH) <= data(SIGNAL_WIDTH*(REGISTER_LENGTH-1)-1 DOWNTO 0);
   data(SIGNAL_WIDTH-1 DOWNTO 0) <= din;
 END IF;
END PROCESS shift_process;

dout <= dout_sig;

END arch_shiftregister;

