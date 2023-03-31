library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Ethernet_tb is
  
end entity Ethernet_tb;

architecture arch_ehternet_tb of Ethernet_tb is
  -- tb

  signal clk_tb : std_logic := '0';
  signal rstn_tb : std_logic := '1';
  signal start_tb : std_logic := '0';

  
  -- declare inst
  component Wrapper_UDP_E is
    port (
      MDIO                : inout std_logic; --configurate register
      MDC                 : out   std_logic; --configurate clk
      
      resetN              : out   std_logic; -- reset the PHY ; last 100us at least
      CLKIN               : out   std_logic; -- 50MHz to PHY

      INTN_REFCLK0        : inout std_logic; --interrupt      ; 50MHz
      CRSDV_MODE2         : inout std_logic; --valid signal from PHY ; CONFIG directly 
      RXD1_MODE1          : inout std_logic; --read data from PHY    ; CONFIG directly 
      RXD0_MODE0          : inout std_logic; --read data from PHY    ; CONfig directly
      RXERR_PHYAD0        : inout std_logic; --error signal from PHY ; addr config ('1')
      TXD0                : out   std_logic; --write data to PHY
      TXD1                : out   std_logic; --write data to PHY
      txen                : out   std_logic; --write data to PHY

      clk    : in    std_logic; --100MHz
      rstn   : in    std_logic; 
      start  : in    std_logic --switch : start ETHERNET
      );
  end component Wrapper_UDP_E;

  
begin  -- architecture arch_ehternet_tb

  inst1: Wrapper_UDP_E 
    port map (
      clk       => clk_tb,
      rstn      => rstn_tb,
      
      start     => start_tb);
  
  process 
  begin
    wait for 5 ns;
    clk_tb <= not(clk_tb);
  end process;
  

  rstn_tb <= '0' after 100 ns,
             '1' after 300 ns;

  start_tb <= '1' after 500 ns;
  
end architecture arch_ehternet_tb;
