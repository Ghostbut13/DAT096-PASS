

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Wrapper_UDP_E is
  
  port (
    --MDIO                : inout std_logic; --configurate register
    --MDC                 : out   std_logic; --configurate clk
    
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

end entity Wrapper_UDP_E;


architecture arch_UDP_Ethernet of Wrapper_UDP_E is
  
  constant const_20us : integer := 1000;
  signal fsync : std_logic:='0'; 
  signal cnt_20us : integer ;

  signal channel_64_tb : std_logic_vector(63 downto 0) :=  x"5700fc011101fc11";--x"0001acab91aeffff";
  -- signal channel_64_tb : std_logic_vector(63 downto 0) := x"ffffffffffffffff";
  
  
  component UDP_Ethernet is
    port (
      --MDIO                : inout std_logic; --configurate register
      --MDC                 : out   std_logic; --configurate clk
      
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
      start  : in    std_logic; --switch : start ETHERNET
      fsync  : in    std_logic; --when I2S catch all data(fsync falling), start writing
      channel_1 : in    std_logic_vector(15 downto 0);
      channel_2 : in    std_logic_vector(15 downto 0);
      channel_3 : in    std_logic_vector(15 downto 0);
      channel_4 : in    std_logic_vector(15 downto 0)
      );
  end component UDP_Ethernet;
  
  
begin
  tcp1:UDP_Ethernet
    port map (
      --MDIO                =>MDIO,
      --MDC                 =>MDC,
      
      resetN              =>resetN,
      CLKIN               =>CLKIN,

      INTN_REFCLK0        =>INTN_REFCLK0,
      CRSDV_MODE2         =>CRSDV_MODE2,
      RXD1_MODE1          =>RXD1_MODE1,
      RXD0_MODE0          =>RXD0_MODE0,
      RXERR_PHYAD0        =>RXERR_PHYAD0,
      TXD0                =>TXD0,
      TXD1                =>TXD1,
      txen                =>txen,
      clk       => clk,
      rstn      => rstn,
      fsync     => fsync,
      start     => start,
      
      
      
      
      channel_1 => channel_64_tb(15 downto 0),
      channel_2 => channel_64_tb(31 downto 16),
      channel_3 => channel_64_tb(47 downto 32),
      channel_4 => channel_64_tb(63 downto 48)
      );
  
  
  process (clk, rstn) is
  begin
    if rstn = '0' then
      cnt_20us <= 0;
      fsync<='0';
    elsif rising_edge(clk) then 
      if cnt_20us <const_20us then
        cnt_20us<= cnt_20us+1;
      else 
        cnt_20us<=0;
        fsync<=not(fsync);
      end if;
    end if;
  end process;
  
  
end architecture arch_UDP_Ethernet;


