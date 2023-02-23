

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.mlhdlc_aesd_fixpt_pkg.ALL;

ENTITY mlhdlc_aesd_fixpt IS
  PORT( clk             :   IN  std_logic;
        reset           :   IN  std_logic;
        clk_enable      :   IN  std_logic;
        TXD             :   IN  std_logic_vector(7 downto 0);
        uart_enable     :   in  std_logic;
        uart_txd        :   out std_logic
        );
END mlhdlc_aesd_fixpt;


ARCHITECTURE rtl OF mlhdlc_aesd_fixpt IS
  --const
  constant plaintext_v : vector_of_std_logic_vector8(0 to 15) := ((x"1F"), (x"9D"), (x"05"), (x"17"), (x"7B"), (x"B0"), (x"5F"), (x"87"), (x"99"), (x"7A"), (x"AE"), (x"F3"), (x"9E"), (x"82"), (x"51"), (x"CC"));
;
  -- Signals
  constant uart_bps : integer := 9600;
  constant clk_frq : integer := 10000000;
  constant CNT_BPS : integer := clk_frq / uart_bps;

  
  signal uart_txd_signal : std_logic;
  signal cnt_tx : integer;
  signal cnt_clk : integer;
  signal tx_flag : std_logic := '1';
  signal uart_done : std_logic;
  signal cnt_start : integer;
  signal cnt_read_cip                   : integer;
  signal cnt_catch_rf : integer;
  signal stb : integer;
  signal done_flag : std_logic := '0';
  signal RX_RF_d1 : std_logic;


BEGIN

  uart_txd <= uart_txd_signal;

  cnt_proc:  process(clk,reset) is
  begin    
    if reset ='0' then
      cnt_clk <= 0;
      cnt_tx <= 0;
    elsif rising_edge(clk) then
      if tx_flag = '0' then
        if (cnt_clk < CNT_BPS) then
          cnt_clk <= cnt_clk +1;
          cnt_tx <= cnt_tx;
        else
          cnt_clk <= 0;
          cnt_tx <= cnt_tx+1;
        end if;
      else
        cnt_clk <= 0;
        cnt_tx <= 0;
      end if;
    end if;
  end process cnt_proc;

  act_proc:
  process(uart_enable, cnt_tx)is
  begin                         
    if uart_enable ='1' then            --tx work
      tx_flag <= '0';
    end if;
    if cnt_tx=9  then                   --tx close
      tx_flag <= '1';
    end if;
  end process act_proc;

  proc_tx: process (clk, reset) is
  begin  -- process proc_tx_falledge_detect
    if reset = '0' then                 
      uart_txd_signal <= '1';
      cnt_start <= 0;
    elsif clk'event and clk = '1' then
      if (tx_flag='0') then             --tx work
        if cnt_tx=0 then                --start: low uart_txd
          uart_txd_signal <= '0';
        elsif cnt_tx<9 and cnt_tx>0 then --1 2 3 4 5 6 7 8
          uart_txd_signal <= plaintext_v(cnt_start)(cnt_tx-1);
        elsif cnt_tx=9 then         
          uart_txd_signal <= '1';       --finish: high
        end if;
      elsif (tx_flag ='1' and cnt_tx = 9) then --tx last
        uart_txd_signal <= '1';
        if cnt_start<7 then
          cnt_start <= cnt_start+1;     --array's addr
        else
          cnt_start <= 0;
        end if;
      else
        uart_txd_signal <= '1';
      end  if;
    end  if;
  end process proc_tx;

END rtl;
