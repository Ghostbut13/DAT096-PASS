library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart_receiver_tb is 
 --generic(
   --
  -- );
end entity uart_receiver_tb;

architecture arch_uart_receiver_tb of uart_receiver_tb is 

  constant rx_time : time := 10417*20 ns;
  
  signal clk_tb: std_logic := '0';
  signal rstn_tb: std_logic;
  signal uart_rxd_tb: std_logic;
  signal uart_done_tb: std_logic;

  
  signal uart_txd_tb: std_logic;
  signal  clk_enable_tb  : std_logic := '0';
  
  
  signal data_get: std_logic_vector(7 downto 0);
  signal data_trans: std_logic_vector(15 downto 0):=x"A865";

  signal stop_tb_flag : std_logic := '0';
  
  component uart_receiver
    port(
      clk         : in std_logic;
      rstn        : in std_logic;
      uart_rxd    : in std_logic;
      uart_done   : out std_logic;
      uart_txd    : out std_logic;
      clk_enable  : in std_logic
      );
  end component;

begin

  inst:component uart_receiver port map(
    clk => clk_tb,
    rstn => rstn_tb,
    uart_txd => uart_txd_tb,
    uart_rxd => uart_rxd_tb,
    uart_done => uart_done_tb,
    clk_enable => clk_enable_tb
    );

  proc_clk:process is
  begin
    wait for 10 ns;
    clk_tb <= not(clk_tb);
  end process proc_clk;

  rstn_tb <= '1',
             '0' after 50 ns,
             '1' after 80 ns;
  
  -- uart_rxd_tb <= '1' ,
  --                '0' after rx_time*2,
  --                data_trans(0)  after rx_time*3,
  --                data_trans(1)  after rx_time*4,
  --                data_trans(2)  after rx_time*5,
  --                data_trans(3)  after rx_time*6,
  --                data_trans(4)  after rx_time*7,
  --                data_trans(5)  after rx_time*8,
  --                data_trans(6)  after rx_time*9,
  --                data_trans(7)  after rx_time*10,
  --       	 '1'  after rx_time*11,
  --       	 '0'  after rx_time*20,
  --       	 data_trans(8)  after rx_time*21,
  --                data_trans(9)  after rx_time*22,
  --                data_trans(10)  after rx_time*23,
  --                data_trans(11)  after rx_time*24,
  --                data_trans(12)  after rx_time*25,
  --                data_trans(13)  after rx_time*26,
  --                data_trans(14)  after rx_time*27,
  --                data_trans(15)  after rx_time*28;
  
clk_enable_tb <= '1' after 10000 ns;

  -- stop_tb_flag <= '1' after rx_time*40+(1000 ns);


end architecture arch_uart_receiver_tb;
