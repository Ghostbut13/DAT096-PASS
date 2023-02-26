
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.i2c_type_package.all;

entity I2C_master_tb is
 
end entity I2C_master_tb;

architecture arch_I2C_master_tb of I2C_master_tb is

  component I2C_Interface is
    port (
      clk  : in std_logic;
      rstn : in std_logic;
      -- signals between i2c and ACFC
      start : in std_logic;
      done : out std_logic;
      config_addr : in  std_logic_vector(7 downto 0);
      config_value : in  std_logic_vector(7 downto 0);
      -- i2c communication
      SDA : inout std_logic;
      SCL : out std_logic

      );
  end component I2C_Interface;

  signal clk_tb : std_logic := '1';
  signal rstn_tb : std_logic := '1';
  signal SCL_tb : std_logic;
  signal SDA_tb : std_logic;
  signal config_value_tb : std_logic_vector(7 downto 0):= x"18";
  signal config_addr_tb : std_logic_vector(7 downto 0):=x"91";
  signal done_tb : std_logic;
  signal start_tb : std_logic := '0';

  
begin  -- architecture arch_I2C_master_for_temperature

  inst: I2C_Interface
    port map (
      clk  => clk_tb,
      rstn => rstn_tb,
      SCL  => SCL_tb,
      SDA  => SDA_tb,
      config_addr => config_addr_tb,
      config_value => config_value_tb,
      done => done_tb,
      start => start_tb
      );


  proc_clk_gen : 
  process
  begin
    wait for 5 ns;
    clk_tb <= not(clk_tb) ;
  end process proc_clk_gen;
  rstn_tb <= '0' after 1 ns,
          '1' after 2 ns;
   start_tb <= '1' after 1000 ns,
               '0' after 281570 ns +800000 ns,
	       '1' after 400000 ns +800000 ns,
	       '0' after 680570 ns +800000 ns;
  --start_tb <= '1' after 1000 ns;


end architecture arch_I2C_master_tb;
