-- shift register
-- read data from BRAM and send it to power estimation and cross-correlation
-- power estimation needs two data: the newest sample and the oldest sample(100)
-- cross-correlation needs two data: the newest sample and the oldest sample(10000)

LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY shiftregister IS
PORT(clk_read: IN STD_LOGIC; --bclk
     clk_write: IN STD_LOGIC; --fsync
     rst_n: IN STD_LOGIC;
     din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
     dout_PE: OUT outputdata;
	 dout_xcorr: OUT outputdata
	 );
END shiftregister;

ARCHITECTURE arch_shiftregister OF shiftregister IS

SIGNAL addr_write : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
SIGNAL addr_read : STD_LOGIC_VECTOR(12 DOWNTO 0) := (OTHERS => '0');
SIGNAL data_read : STD_LOGIC_VECTOR(15 DOWNTO 0):= (OTHERS =>'0');
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
SIGNAL counter : SIGNED(10 DOWNTO 0) := (OTHERS => '0');

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

BRAM_inst:
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

counter_process:
PROCESS(clk_read)
BEGIN
  IF RISING_EDGE(clk_read) THEN
    IF clk_write = '0' THEN
	    IF counter < 564 THEN 
          counter <= counter + 1;
		ELSE
		  counter <= counter;
	    END IF;
	ELSE
	  	counter <= (OTHERS =>'0');
	END IF;
  END IF;
END PROCESS counter_process;

wirte_process:
PROCESS(clk_write)
BEGIN
  IF RISING_EDGE(clk_write) THEN
     -- write din into BRAM
	 write_en <= '0';
	IF addr_write < "111111111111" THEN
	  addr_write <= STD_LOGIC_VECTOR(SIGNED(addr_write) + 1);
	ELSE
	  addr_write <= (OTHERS => '0');
	  bufferfull <= '1';
	END IF;
	write_en <= '1';
  END IF;
  
END PROCESS wirte_process;

read_process:
PROCESS(counter,addr_write)
BEGIN
  IF counter = 0 THEN
      read_en <= '1';
  ELSIF counter = 1 THEN
  --
  ELSIF counter = 2 THEN
    -- get newest data for power estimation
	addr_read <= addr_write;
	
  ELSIF  counter = 3 THEN
    -- get oldest data for power estimation
	IF bufferfull = '0' THEN
	  IF addr_write >= POWER_WINDOW THEN
	    addr_read <= STD_LOGIC_VECTOR(SIGNED(addr_write) - POWER_WINDOW);
      END IF;
	ELSE
	  IF addr_write < POWER_WINDOW THEN
	    addr_read <= STD_LOGIC_VECTOR(8191 - POWER_WINDOW + SIGNED(addr_write));
	  ELSE 
	    addr_read <= STD_LOGIC_VECTOR(SIGNED(addr_write) - POWER_WINDOW);
	  END IF;
	END IF;

  ELSIF counter < 563 THEN
	-- get the newest data for cross-correlation
	IF counter(0) = '0' THEN
	  addr_read <= STD_LOGIC_VECTOR((SIGNED(addr_write) + (SIGNED('0'& counter(9 DOWNTO 1)) - 2)) MOD 8192);
	-- get the oldest data for cross-correlation
	ELSIF counter(0) = '1' THEN
	  IF bufferfull = '1' THEN
	    IF addr_write = "0000000000000" THEN
		  addr_read <= (OTHERS => '1');
		ELSE 		  
		  addr_read <= STD_LOGIC_VECTOR((SIGNED(addr_write) - 1 + (SIGNED('0'& counter(9 DOWNTO 1)) - 2)) MOD 8192);
		END IF;
	  END IF;
    END IF;
	
   ELSE
   --idele
   END IF;
END PROCESS read_process;

assignment_proc:
PROCESS(clk_read)
BEGIN
  IF FALLING_EDGE(clk_read) THEN
  
    IF counter = 3 THEN
	dout_PE_signal(0) <= data_read;
	dout_PE_signal(1) <= dout_PE_signal(1);
	
    ELSIF counter = 4 THEN
	  dout_PE_signal(0) <= dout_PE_signal(0);
	  IF bufferfull = '0' THEN
	    IF addr_write < POWER_WINDOW THEN
	      dout_PE_signal(1) <= (OTHERS => '0');
	    ELSE
	      dout_PE_signal(1) <= data_read;
        END IF;
	  ELSE
	      dout_PE_signal(1) <= data_read;
	  END IF;

	ELSIF counter < 564 THEN
		dout_PE_signal <= dout_PE_signal;
		IF counter(0) = '0' THEN
		  dout_xcorr_signal(0) <= data_read;
		ELSIF counter(0) = '1' THEN
		  IF bufferfull = '0' THEN
			dout_xcorr_signal(1) <= (OTHERS => '0');
		  ELSE
			dout_xcorr_signal(1) <= data_read;
		  END IF;	  
		END IF;
	ELSE
		dout_PE_signal <= dout_PE_signal;
	END IF;
  END IF;
END PROCESS assignment_proc;

dout_PE <= dout_PE_signal;
dout_xcorr <= dout_xcorr_signal;

END ARCHITECTURE arch_shiftregister;

