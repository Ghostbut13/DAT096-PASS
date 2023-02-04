
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.i2c_type_package.all;


entity I2C_master_for_temperature is
  
  port (
    clk : in std_logic;
    rstn : in std_logic;
    SCL : out 	std_logic;
    SDA : inout std_logic;
--    state1 : out 	i2c_state_type;
--    next_state1 : out 	i2c_state_type;
    data_show: out std_logic_vector(7 downto 0);
    data_show_1: out std_logic_vector(7 downto 0)
    );
  
end entity I2C_master_for_temperature;

architecture arch_I2C_master_for_temperature of I2C_master_for_temperature is

--COMPONENT ila_0

--PORT (
--	clk : IN STD_LOGIC;
--	probe0 : IN STD_LOGIC;
--	probe1 : IN STD_LOGIC
--);
--END COMPONENT  ;




  signal addr : std_logic_vector(7 downto 0) := "10010111";
  signal data_MSB : std_logic_vector(7 downto 0) := x"00";
  signal data_LSB : std_logic_vector(7 downto 0) := x"00";
  signal cnt_10k : integer := 0;
  signal cnt_200k : integer := 0;
  signal clk_200k : std_logic;
  signal clk_10k : std_logic;
  signal state : i2c_state_type;
  signal next_state : i2c_state_type;
  signal out_bit : std_logic  := '1';
  signal in_bit : std_logic ;
  signal cnt_in_state : integer := 0;
  signal send_flag : std_logic := '1';
  -- signal data_show_signal : std_logic_vector(7 downto 0) := x"00";
  -- signal data_show_signal_1 : std_logic_vector(7 downto 0) := x"00";

  signal d1 : std_logic;
  signal dd : std_logic;

  
begin  -- architecture arch_I2C_master_for_temperature
--  state1 <= state;
--  next_state1 <= next_state;

--ILA : ila_0
--PORT MAP (
--	clk => clk,
--	probe0 => in_bit,
--	probe1 => clk_10k
--);

  Cnt_GENE: process (clk, rstn) is
  begin  -- process CLK_10K_GENE
    if rstn='0' then
      cnt_200k <= 0;
      cnt_10k <= 0;
    elsif rising_edge(clk) then
      if cnt_200k<249 then
        cnt_200k <= cnt_200k+1;
      else
        cnt_200k <= 0;
      end if;
      if cnt_10k<4999 then
        cnt_10k <= cnt_10k+1;
      else
        cnt_10k <= 0;
      end if;
    end if;
  end process Cnt_GENE;

  CLK_GENE: process (clk, rstn) is
  begin  -- process CLK_10K_GENE
    if rstn = '0' then                  -- asynchronous reset (active low)
      clk_200k <= '1';
      CLK_10K <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if cnt_200k = 249 then
        clk_200k <= not(clk_200k);
      end if;
      if cnt_10k = 4999 then
        clk_10k <= not(clk_10k);
      end if;
    end if;
  end process CLK_GENE;

  SCL <= clk_10k;


  a:process(clk,rstn)
  begin
    IF (rstn = '0') THEN
      d1<= '0';
    ELSIF rising_edge(clk) THEN
      d1 <= clk_200k;
    end if;
  end process a;

  dd <= not(d1) and clk_200k;
  
  state_transition_proc:
  PROCESS(rstn,clk)
  BEGIN
    IF (rstn = '0') THEN
      state <= idle_state;
      cnt_in_state <= 0;
    ELSIF rising_edge(clk) THEN
      if(dd = '1') then
        if cnt_in_state< 2559 then
          cnt_in_state <= cnt_in_state+1;
        else
          cnt_in_state <= 2000;
        end if;
        
        state <= next_state;
      end if;
    END IF;
  END PROCESS state_transition_proc;


  
  state_flow_proc:
  PROCESS(state,cnt_in_state)
  BEGIN     
    CASE state IS
      WHEN idle_state => 
        IF (cnt_in_state=1999) THEN
          next_state <= start_state;
        ELSE
          next_state <= idle_state;
        END IF;
      WHEN start_state =>
        IF (cnt_in_state= 2013) THEN
          next_state <= write_addr_state_0;
        ELSE
          next_state <= start_state ;
        END IF;
      WHEN write_addr_state_0 =>
        IF (cnt_in_state= 2033) THEN
          next_state <= write_addr_state_1;
        ELSE
          next_state <= write_addr_state_0;
        END IF;
      WHEN write_addr_state_1 =>
        IF (cnt_in_state=2053) THEN
          next_state <= write_addr_state_2;
        ELSE
          next_state <= write_addr_state_1;
        END IF;
      WHEN write_addr_state_2 =>
        IF (cnt_in_state=2073) THEN
          next_state <= write_addr_state_3;
        ELSE
          next_state <= write_addr_state_2;
        END IF;
      WHEN write_addr_state_3 =>
        IF (cnt_in_state=2093) THEN
          next_state <= write_addr_state_4;
        ELSE
          next_state <= write_addr_state_3;
        END IF;
      WHEN write_addr_state_4 =>
        IF (cnt_in_state=2113) THEN
          next_state <= write_addr_state_5;
        ELSE
          next_state <= write_addr_state_4;
        END IF;
      when write_addr_state_5  =>
        IF (cnt_in_state=2133) THEN
          next_state <= write_addr_state_6;
        ELSE
          next_state <= write_addr_state_5;
        END IF;

      WHEN write_addr_state_6 =>
        IF (cnt_in_state=2153) THEN
          next_state <= send_RW_state;
        ELSE
          next_state <= write_addr_state_6;
        END IF;
      when send_RW_state  =>
        IF (cnt_in_state=2169) THEN
          next_state <= REC_ACK_state;
        ELSE
          next_state <= send_RW_state;
        END IF;
      WHEN REC_ACK_state =>
        IF (cnt_in_state=2189) THEN
          next_state <= data_state_0;
        ELSE
          next_state <= REC_ACK_state;
        END IF;
      WHEN data_state_0 =>
        IF (cnt_in_state= 2209) THEN
          next_state <=  data_state_1;
        ELSE
          next_state <= data_state_0;
        END IF;
      WHEN data_state_1 =>
        IF (cnt_in_state=2229) THEN
          next_state <=  data_state_2;
        ELSE
          next_state <=  data_state_1;
        END IF;
      WHEN data_state_2 =>
        IF (cnt_in_state=2249) THEN
          next_state <= data_state_3;
        ELSE
          next_state <= data_state_2;
        END IF;
      WHEN data_state_3 =>
        IF (cnt_in_state=2269) THEN
          next_state <= data_state_4;
        ELSE
          next_state <= data_state_3;
        END IF;
      WHEN data_state_4 =>
        IF (cnt_in_state=2289) THEN
          next_state <= data_state_5;
        ELSE
          next_state <= data_state_4;
        END IF;
      WHEN data_state_5 =>
        IF (cnt_in_state= 2309) THEN
          next_state <= data_state_6;
        ELSE
          next_state <= data_state_5;
        END IF;
      WHEN data_state_6 =>
        IF (cnt_in_state=2329) THEN
          next_state <= data_state_7;
        ELSE
          next_state <= data_state_6;
        END IF;
      WHEN data_state_7 =>
        IF (cnt_in_state= 2349) THEN
          next_state <= SEND_ACK_state;
        ELSE
          next_state <=  data_state_7;
        END IF;
      WHEN SEND_ACK_state =>
        IF (cnt_in_state=2369) THEN
          next_state <=  data_state_8;
        ELSE
          next_state <= SEND_ACK_state;
        END IF;
      WHEN data_state_8 =>
        IF (cnt_in_state=2389) THEN
          next_state <= data_state_9 ;
        ELSE
          next_state <=  data_state_8;
        END IF;
      WHEN data_state_9 =>
        IF (cnt_in_state=2409) THEN
          next_state <=  data_state_10;
        ELSE
          next_state <=  data_state_9;
        END IF;
      WHEN data_state_10 =>
        IF (cnt_in_state= 2429) THEN
          next_state <= data_state_11;
        ELSE
          next_state <= data_state_10;
        END IF;
      WHEN data_state_11 =>
        IF (cnt_in_state= 2449) THEN
          next_state <= data_state_12;
        ELSE
          next_state <= data_state_11;
        END IF;
      WHEN data_state_12 =>
        IF (cnt_in_state=  2469) THEN
          next_state <= data_state_13;
        ELSE
          next_state <= data_state_12;
        END IF;
      WHEN data_state_13 =>
        IF (cnt_in_state= 2489) THEN
          next_state <= data_state_14;
        ELSE
          next_state <= data_state_13;
        END IF;
      WHEN data_state_14 =>
        IF (cnt_in_state= 2509) THEN
          next_state <= data_state_15;
        ELSE
          next_state <= data_state_14;
        END IF;
      WHEN data_state_15 =>
        IF (cnt_in_state= 2529 ) THEN
          next_state <= end_state;
        ELSE
          next_state <= data_state_15;
        END IF;
      WHEN end_state =>
        IF (cnt_in_state= 2559 ) THEN
          next_state <= start_state;
        ELSE
          next_state <= end_state;
        END IF;
      when others =>
        next_state <= idle_state;
    END CASE;
  END PROCESS state_flow_proc;
  
  assignment_proc:
  PROCESS(state,cnt_in_state,in_bit)
  BEGIN
    --out_bit <= '1';
    --send_flag <= '1';
    CASE state IS
      when idle_state => 
        send_flag <= '1';
        out_bit <= '1';
      WHEN start_state => 
        if cnt_in_state > 2008 then
          out_bit <= '0';
        ELSE
          out_bit <= '1';
        end if;
        
        send_flag <= '1';
      when write_addr_state_0 => 
        send_flag <= '1';
        out_bit <= addr(7);
      when write_addr_state_1 => 
        send_flag <= '1';
        out_bit <= addr(6);
      when write_addr_state_2 => 
        send_flag <= '1';
        out_bit <= addr(5);
      when write_addr_state_3 => 
        send_flag <= '1';
        out_bit <= addr(4);
      when write_addr_state_4 => 
        send_flag <= '1';
        out_bit <= addr(3);
      when write_addr_state_5 => 
        send_flag <= '1';
        out_bit <= addr(2);
      when write_addr_state_6 => 
        send_flag <= '1';
        out_bit <= addr(1);
      when send_RW_state => 
        send_flag <= '1';
        out_bit <= addr(0);

      when  REC_ACK_state => 
        send_flag <= '0';


        
      when  data_state_0 => 
        send_flag <= '0';
        data_MSB(7) <= in_bit;
      when  data_state_1 => 
        send_flag <= '0';
        data_MSB(6) <= in_bit;
      when  data_state_2 => 
        send_flag <= '0';
        data_MSB(5) <= in_bit;
      when  data_state_3 => 
        send_flag <= '0';
        data_MSB(4) <= in_bit;
      when  data_state_4 => 
        send_flag <= '0';
        data_MSB(3) <= in_bit;
      when  data_state_5 => 
        send_flag <= '0';
        data_MSB(2) <= in_bit;
      when  data_state_6 => 
        send_flag <= '0';
        data_MSB(1) <= in_bit;
      when  data_state_7 => 
        send_flag <= '0';
        data_MSB(0) <= in_bit;
        out_bit <= '0';

        
      when SEND_ACK_state => 
        send_flag <= '1';
        out_bit <= '0';

        
      when  data_state_8 => 
        send_flag <= '0';
        data_LSB(7) <= in_bit;
      when  data_state_9 => 
        send_flag <= '0';
        data_LSB(6) <= in_bit;
      when  data_state_10 => 
        send_flag <= '0';
        data_LSB(5) <= in_bit;
      when  data_state_11 => 
        send_flag <= '0';
        data_LSB(4) <= in_bit;
      when  data_state_12 => 
        send_flag <= '0';
        data_LSB(3) <= in_bit;
      when  data_state_13 => 
        send_flag <= '0';
        data_LSB(2) <= in_bit;
      when  data_state_14 => 
        send_flag <= '0';
        data_LSB(1) <= in_bit;
      when  data_state_15 => 
        send_flag <= '0';
        data_LSB(0) <= in_bit;
        out_bit <= '1';

        
      when  end_state => 
        send_flag <= '1';
        out_bit <= '1';
        -- data_show_signal<= data_MSB(7 downto 0);
        -- data_show_signal_1<= data_LSB(7 downto 0);
        data_show<=(data_MSB(6 downto 0) & data_LSB(7));
        data_show_1<=x"00";

      when others =>
        send_flag <= '1';
        out_bit <= '1';
        data_MSB(7 downto 0) <= x"00";
        data_LSB(7 downto 0) <= x"00";
    END CASE;
  END PROCESS assignment_proc;

  in_bit <= SDA;

  
  SDA <= out_bit when send_flag='1' ELSE
         'Z';

end architecture arch_I2C_master_for_temperature;
