-------------------------------------------------------------------------------
-- Title      : serial_port(UART) receiver
-- Project    : EDA234
-------------------------------------------------------------------------------
-- File       : sp.vhdl
-- Author     : weihanga@chalmers.se
-- Company    : 
-- Created    : 2022-11-12
-- Last update: 2023-03-01
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2022 
-------------------------------------------------------------------------------
-- Revisions  : 1.2
-- Date        Version  Author  Description
-- 2022-11-12  1.0      ASUS	Created
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
USE work.mlhdlc_aesd_fixpt_pkg.ALL;

entity uart_receiver is
  port(
    clk         : in std_logic;
    rstn        : in std_logic;
    --uart_rxd    : in std_logic;
    uart_done   : out std_logic;
    uart_txd    : out std_logic;
    clk_enable  : in std_logic;

    wr_enable      : in std_logic;
    FSYNC       : in std_logic;
    BCLK        : in std_logic;
    DIN         : in std_logic
    
    );
end entity uart_receiver;



architecture arch_uart_receiver of uart_receiver is
  SIGNAL  uart_rxd    : std_logic;
  --signal plaintext_v : vector_of_std_logic_vector8(0 to 15) := ((x"1F"), (x"9D"), (x"05"), (x"17"), (x"7B"), (x"B0"), (x"5F"), (x"87"), (x"99"), (x"7A"), (x"AE"), (x"F3"), (x"9E"), (x"82"), (x"51"), (x"CC"));

    --constant Len : integer := 6000000;
    constant Len : integer := 60;
  signal audio_4_channel : vector_of_std_logic_vector8(Len-1 downto 0);

  
  constant uart_bps     : integer := 9600;
  -- constant uart_bps     : integer := 960000;
    constant clk_frq      : integer := 100000000;
  --constant clk_frq      : integer := 6144000;
  constant CNT_BPS      : integer := clk_frq / uart_bps;
  signal uart_rxd_d1    : std_logic;  -- rxd
  signal uart_rxd_d2    : std_logic;
  signal uart_done_signal       : std_logic;  -- done
  signal cnt_rx         : integer;
  signal cnt_tx         : integer;
  signal cnt_clk_rx     : integer;
  signal cnt_clk_tx     : integer;
  signal cnt_read_cip   : integer;
  signal buffer_data8   : std_logic_vector(7 downto 0);
  signal rx_data_flag   : std_logic;
  signal start_flag     : std_logic;

  signal enb            : std_logic;
  signal uart_enable: std_logic;
  signal uart_txd_signal : std_logic;
  signal data_t         : std_logic_vector(7 downto 0):= x"A5";
  signal tx_flag        : std_logic;
  signal cnt_start      : integer;

  signal addr_pointer   : integer := 0;
  signal bit_pointer    : integer :=0;
  
begin  -- architecture arch_uart_receiver
  
  uart_txd  <= uart_txd_signal;
  uart_done <= uart_done_signal;
  ---------------------------------------------
  
  proc_cnt: process (clk, rstn) is
  begin  -- process proc_cnt
    if rstn = '0' then
      cnt_clk_rx <= 0;
      cnt_rx <= 0;
    elsif rising_edge(clk) then 
      if rx_data_flag='1' then
        if(cnt_clk_rx < CNT_BPS) then
          cnt_clk_rx <= cnt_clk_rx +1;
          cnt_rx <= cnt_rx;
        else
          cnt_clk_rx <= 0;
          cnt_rx <= cnt_rx +1;
        end if;
      else
        cnt_clk_rx <= 0;
        cnt_rx <= 0;
      end if;
    end if;
  end process proc_cnt;
  -- 
  proc_rx_falledge_detect: process (clk, rstn) is
  begin  -- process proc_rx_falledge_detect
    if rstn = '0' then                 
      uart_rxd_d1 <= '0';
      uart_rxd_d2 <= '0';
    elsif clk'event and clk = '1' then  
      uart_rxd_d1 <= uart_rxd;
      uart_rxd_d2 <= uart_rxd_d1;
    end if;
    start_flag <= uart_rxd_d2 and not(uart_rxd_d1) and not(rx_data_flag);
  end process proc_rx_falledge_detect;

  proc_rx_data_flag: process (clk, rstn) is
  begin  -- process proc_data_face
    if rstn = '0' then                  
      rx_data_flag <= '0';
      uart_done_signal <= '0';
    elsif clk'event and clk = '1' then
      if start_flag='1' then
        rx_data_flag <= '1';
        uart_done_signal <= '0';
      end if;
      if cnt_rx=9 then
        rx_data_flag <= '0';
        uart_done_signal <= '1';
      end if;
    end if;
  end process proc_rx_data_flag;

  proc_data_catch: process (clk, rstn) is
  begin  -- process proc_rx
    if rstn = '0' then               
      buffer_data8 <= "00000000";
    elsif rising_edge(clk) then
      --cnt_clk_rx= CNT_BPS / 2 is waiting for data stable
      if (rx_data_flag='1' and cnt_clk_rx= CNT_BPS / 2 and cnt_rx > 0) then
        buffer_data8(cnt_rx-1) <= uart_rxd_d1;
      end if;
    end if;
  end process proc_data_catch;















  
  proc_txcnt: process (clk, rstn) is
  begin  -- process proc_cnt
    if rstn = '0' then
      cnt_clk_tx <= 0;
      cnt_tx <= 0;
    elsif rising_edge(clk) then 
      if tx_flag ='0' then
        if(cnt_clk_tx < CNT_BPS) then
          cnt_clk_tx <= cnt_clk_tx +1;
          cnt_tx <= cnt_tx;
        else
          cnt_clk_tx <= 0;
          cnt_tx <= cnt_tx +1;
        end if;
      else
        cnt_clk_tx <= 0;
        cnt_tx <= 0;
      end if;
    end if;
  end process proc_txcnt;

  -- enb <= '1';  
  done_and_begin_uart: process(clk,rstn) is
  begin
    if rstn='0' then
      enb <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (clk_enable='1' and enb = '0') then
        if (cnt_read_cip = 3) then
          enb<='1';
        end if;
      elsif (clk_enable='0' and enb='1') then
        enb<='0';
      elsif (clk_enable='1' and enb='1' and cnt_start > Len) then
        enb<='0';
      end if;
    end if;
  end process done_and_begin_uart;
  
  uart_enable_control: process (clk, rstn) is
  begin  -- process buffer_out
    if rstn = '0' then                 -- asynchronous reset (active low)
      uart_enable <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if(enb='1' and cnt_read_cip=10000) then
        uart_enable <= '1';
      else
        uart_enable <= '0';
      end if;
    end if;
  end process uart_enable_control;
  
  push_data_out_cnt: process (clk, rstn) is
  begin  -- process push_data_out
    if rstn = '0' then                 -- asynchronous reset (active low)
      cnt_read_cip <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if (clk_enable = '1' and tx_flag='1' and cnt_start < 127)then
        if (cnt_read_cip < 20000) then
          cnt_read_cip <= cnt_read_cip+1;
        else
          cnt_read_cip <= 0;
        end if;
      elsif ((clk_enable='0' and enb='1')) then
        cnt_read_cip <= 0;
      elsif ((clk_enable='1' and cnt_start >= 127)) then
        cnt_read_cip <= 0;
      end if;
    end if;
  end process push_data_out_cnt;
  
  act_proc: process (clk,rstn) is
  begin
    if rstn = '0' then
      tx_flag <= '1';
    elsif rising_edge(clk) then
      if uart_enable ='1' then
        tx_flag <= '0';                 --start
      end if;
      if cnt_tx=9  then
        tx_flag <= '1';
      end if;
    end if;
  end process act_proc;

  -- proc_tx: 
  -- process (clk, rstn) is
  -- begin  -- process proc_tx_falledge_detect
  --   if rstn = '0' then                 
  --     uart_txd_signal <= '1';
  --     cnt_start <= 0;
  --   elsif clk'event and clk = '1' then
  --     if (tx_flag='0') then
  --       if cnt_tx=0 then
  --         uart_txd_signal <= '0';
  --       elsif cnt_tx<9 then
  --         uart_txd_signal <= plaintext_v(cnt_start)(cnt_tx-1);
  --       else
  --         uart_txd_signal <= '1';
  --       end if;
  --     elsif (tx_flag ='1' and cnt_tx = 9) then --tx last
  --       uart_txd_signal <= '1';
  --       if cnt_start<7 then
  --         cnt_start <= cnt_start+1;     --array's addr
  --       else
  --         cnt_start <= 0;
  --       end if;
  --     else
  --       uart_txd_signal <= '1';
  --     end  if;
  --   end  if;
  -- end process proc_tx;

  proc_read: 
  process (clk, rstn) is
  begin  -- process proc_tx_falledge_detect
    if rstn = '0' then                 
      uart_txd_signal <= '1';
      cnt_start <= 0;
    elsif clk'event and clk = '1' then
      if (tx_flag='0') then
        if cnt_tx=0 then
          uart_txd_signal <= '0';
        elsif cnt_tx<9 then
          uart_txd_signal <= audio_4_channel(cnt_start)(cnt_tx-1);
        else
          uart_txd_signal <= '1';
        end if;
      elsif (tx_flag ='1' and cnt_tx = 9) then --tx last
        uart_txd_signal <= '1';
        if cnt_start<Len then
          cnt_start <= cnt_start+1;     --array's addr
        else
          cnt_start <= 0;
        end if;
      else
        uart_txd_signal <= '1';
      end  if;
    end  if;
  end process proc_read;

  proc_write: 
  process (BCLK, rstn) is
    variable i : integer;
  begin  -- process proc_tx_falledge_detect
    if rstn = '0' then
      for i in 0 to Len-1 loop
        audio_4_channel(i) <= (others => '1');
      end loop;  -- i
    elsif BCLK'event and BCLK = '1' then
      if wr_enable = '1' then
        if addr_pointer<Len then
          audio_4_channel(addr_pointer)(bit_pointer) <= DIN;
          bit_pointer <= bit_pointer + 1;
          if bit_pointer = 7 then
            addr_pointer <= addr_pointer + 1;
            bit_pointer <= 0;
          end if;
        end if;
      end  if;
    end if;
  end process proc_write;

end architecture arch_uart_receiver;
