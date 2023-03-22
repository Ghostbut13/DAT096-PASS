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
LIBRARY work;
USE work.parameter.ALL;

ENTITY shiftregister IS
  PORT(clk: IN STD_LOGIC;
       din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
       dout: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
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
signal power_data : std_logic_vector(SIGNAL_WIDTH-1 downto 0);
signal reset_n: std_logic;
signal dout_sig: outputdata := ((others => (others=>'0')));


COMPONENT singleregister IS
  PORT (clk: IN STD_LOGIC;
        din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
        dout: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
END COMPONENT singleregister;

component power_estimation is
	 generic(len_data: positive);
	 port(clk:in std_logic;
		 reset_n: in std_logic;
		 data_in: in outputdata;
		 power_data: out std_logic_vector(SIGNAL_WIDTH-1 downto 0)
	 );
 end component;

BEGIN

  G: FOR i IN 0 TO REGISTER_LENGTH-1 GENERATE
	register_i:
        COMPONENT singleregister
  	PORT MAP(clk => clk,
                din => data(SIGNAL_WIDTH*(i+1)-1 DOWNTO SIGNAL_WIDTH*i),
                dout => dout_sig(i));
END GENERATE;

power_estimation_inst: component power_estimation
	 generic map(len_data=>LEN_DATA)
	 port map(reset_n=>reset_n, clk=>clk, data_in=>dout_sig, power_data=>power_data);

--
shift_process:
PROCESS(clk)
BEGIN
IF RISING_EDGE(clk) THEN
   data(SIGNAL_WIDTH*REGISTER_LENGTH-1 DOWNTO SIGNAL_WIDTH) <= data(SIGNAL_WIDTH*(REGISTER_LENGTH-1)-1 DOWNTO 0);
   data(SIGNAL_WIDTH-1 DOWNTO 0) <= din;
 END IF;
END PROCESS shift_process;

dout <= power_data;
reset_n <= '1','0' after 20 ns, '1' after 40 ns;

END arch_shiftregister;

