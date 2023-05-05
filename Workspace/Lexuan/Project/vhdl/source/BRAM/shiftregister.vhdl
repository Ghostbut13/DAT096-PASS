-- shift register
-- read data from BRAM and send it to power estimation and cross-correlation
-- power estimation needs two data: the newest sample and the oldest sample(100)
-- cross-correlation needs two data: the newest sample and the oldest sample(10000)

LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY shiftregister IS
PORT(clk_read: IN STD_LOGIC; --bclk
     clk_write: IN STD_LOGIC; --fsync
     rst_n: IN STD_LOGIC;
	 enable : IN STD_LOGIC;
     din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
     dout_PE: OUT outputdata;
	 dout_xcorr: OUT outputdata
	 );
END shiftregister;

ARCHITECTURE arch_shiftregister OF shiftregister IS

SIGNAL addr_write : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
SIGNAL addr_read : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
SIGNAL data_read : STD_LOGIC_VECTOR(15 DOWNTO 0):= (OTHERS =>'0')
SIGNAL dout_PE_signal: outputdata := (OTHERS => (OTHERS => '0'));
SIGNAL dout_xcorr_signal: outputdata := (OTHERS => (OTHERS => '0'));
-- the index of the output data, when index = 1, output the outputarray for cross-correlation
SIGNAL data_index : INTEGER := 0;
SIGNAL write_en : STD_LOGIC := '0';
SIGNAL read_en : STD_LOGIC := '0';
SIGNAL write_we : STD_LOGIC := '1';
SIGNAL bufferfull : STD_LOGIC := '0';

-- data_counter = 0 , idle
-- data_counter = 1 , write data into BRAM
-- data_counter = 2-3 , get data for power estimation
-- data_counter = 4-565 , get data for cross-correlation
SIGNAL counter : INTGER := 0;

COMPONENT simple_dual_two_clocks is
 port(
 clka : in std_logic;
 clkb : in std_logic;
 ena : in std_logic;
 enb : in std_logic;
 wea : in std_logic;
 addra : in std_logic_vector(12 downto 0);
 addrb : in std_logic_vector(12 downto 0);
 dia : in std_logic_vector(15 downto 0);
 dob : out std_logic_vector(15 downto 0)
 );
end COMPONENT simple_dual_two_clocks;

BEGIN

COMPONENT simple_dual_two_clocks
 port map(
 clka => clk_write,
 clkb => clk_read,
 ena => write_en,
 enb => read_en,
 wea => write_we,
 addra => addr_write,
 addrb => addr_read,
 dia => din,
 dob => data_read
 );
end COMPONENT simple_dual_two_clocks;

counter_process:
PROCESS(clk_read)
BEGIN
  IF RISING_EDGE(clk_read,rst_n) THEN
    IF clk_write = '0' THEN
      IF counter < 282 THEN
        counter <= counter + 1;
	  ELSE
	    counter <= 0;
      END IF;
	END IF;
  END IF;
END PROCESS counter_process;

data_process:
PROCESS(counter)
BEGIN
  IF counter = 0 THEN
    --idle
  ELSE IF counter = 1 THEN
    -- write din into BRAM
	IF addr_write < "111111111111" THEN
	  addr_write <= addr_write + 1;
	ELSE
	  addr_write <= '0';
    write_en <= '1';
	
  ELSE IF counter = 2 THEN
    -- get newest data for power estimation
    write_en <= '0';
	addr_read <= addr_write;
	read_en <= '1';
	dout_PE_signal(0) <= data_read;
	
  ELSE IF  counter = 3 then
    -- get oldest data for power estimation
	read_en <= '0';
	IF bufferfull = '0' THEN
	  IF addr_write < 1000 THEN
	    dout_PE_signal(1) <= (OTHERS => '0');
	  ELSE if
	    addr_read <= addr_write - 1000;
		read_en <= '1';
	    dout_PE_signal(1) <= data_read;
      END IF;
	ELSE
	  IF addr_write < 1000 THEN
	    addr_read <= 9191 - addr_write;
		read_en <= '1';
	    dout_PE_signal(1) <= data_read;
	  ELSE 
	    addr_read <= addr_write - 1000;
		read_en <= '1';
	    dout_PE_signal(1) <= data_read;
	  END IF;
	END IF;

  ELSE IF counter < 565 THEN
    read_en <= '0';
	-- get the newest data for cross-correlation
	IF STD_LOGIC_VECTOR(counter)(0) = 0 THEN
	  addr_read <= addr_write;
	  read_en <= '1';
	  dout_xcorr_signal(0) <= data_read;
	-- get the oldest data for cross-correlation
	ELSE IF STD_LOGIC_VECTOR(counter)(0) = 1 THEN
	  IF(bufferfull = '0')
	    dout_xcorr_signal(1) <= (OTHERS => '0');
	  ELSE
	    IF addr_write = 0 THEN
		  addr_read <= (OTHERS => '1');
		ELSE 
		  addr_read <= addr_write - 1;
		  END IF;
	  END IF;
	  dout_xcorr <= dout_xcorr_signal;
	END IF;
	
   ELSE
     counter <= 0;
   END IF;
   
END arch_shiftregister;

