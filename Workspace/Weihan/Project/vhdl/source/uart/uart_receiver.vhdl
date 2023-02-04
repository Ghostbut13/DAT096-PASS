-------------------------------------------------------------------------------
-- Title      : serial_port(UART) receiver
-- Project    : EDA234
-------------------------------------------------------------------------------
-- File       : sp.vhdl
-- Author     : weihanga@chalmers.se
-- Company    : 
-- Created    : 2022-11-12
-- Last update: 2022-11-14
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

entity uart_receiver is
  -- generic(
  --   mode:boolean:=true;
  --   -- ...
  --   );
  port(
    clk : in std_logic;
    rstn : in std_logic;
    uart_rxd : in std_logic;
    uart_done : out std_logic;
    uart_txd : out std_logic;
    data : out std_logic_vector(7 downto 0)  -- just show the result in simulation
    );
end entity uart_receiver;



architecture arch_uart_receiver of uart_receiver is

  constant uart_bps : integer := 9600;
  constant clk_frq : integer := 100000000;
  constant CNT_BPS : integer := clk_frq / uart_bps;
  signal uart_rxd_d1 : std_logic;  -- rxd
  signal uart_rxd_d2 : std_logic;
  signal uart_done_signal : std_logic;  -- done
  signal cnt_rx : integer;
  signal cnt_clk : integer;
  signal buffer_data8 : std_logic_vector(7 downto 0);
  signal rx_data_flag : std_logic;
  signal start_flag : std_logic;


  signal uart_txd_signal : std_logic;
  signal data_t: std_logic_vector(7 downto 0):= x"A5";
  signal tx_flag : std_logic;

  
begin  -- architecture arch_uart_receiver
  proc_cnt: process (clk, rstn) is
  begin  -- process proc_cnt
    if rstn = '0' then
      cnt_clk <= 0;
      cnt_rx <= 0;
    elsif rising_edge(clk) then 
      if rx_data_flag='1' then
        if(cnt_clk < CNT_BPS) then
          cnt_clk <= cnt_clk +1;
          cnt_rx <= cnt_rx;
        else
          cnt_clk <= 0;
          cnt_rx <= cnt_rx +1;
        end if;
      else
        cnt_clk <= 0;
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
      if (rx_data_flag='1' and cnt_clk= CNT_BPS / 2 and cnt_rx > 0) then
        buffer_data8(cnt_rx-1) <= uart_rxd_d1;
      end if;
    end if;
  end process proc_data_catch;

  act_proc: process(clk,rstn)is
  begin
    if uart_active ='1' then
      tx_flag <= '0';
    end if;
    if cnt_tx=9  then
      tx_flag <= '1';
    end if;
  end process act_proc;


  proc_tx: 
  process (clk, rstn) is
  begin  -- process proc_tx_falledge_detect
    if rstn = '0' then                 
      uart_txd_signal <= '1';
    elsif clk'event and clk = '1' then
      if (tx_flag='0') then
        if cnt_tx=0 then
           uart_txd_signal <= '0';
        elsif cnt_tx<9 then
          uart_txd_signal <= data_t(cnt_tx-1);
        else
          uart_txd_signal <= '1';
        end if;
      end  if;
  end process proc_tx;

  
  uart_txd <= uart_txd_signal;
  uart_done <= uart_done_signal;
  data <= buffer_data8;
  
end architecture arch_uart_receiver;
