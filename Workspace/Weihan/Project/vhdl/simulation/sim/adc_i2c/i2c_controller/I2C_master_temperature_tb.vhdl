
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.i2c_type_package.all;

entity I2C_master_for_temperature_tb is
 
end entity I2C_master_for_temperature_tb;

architecture arch_I2C_master_for_temperature_tb of I2C_master_for_temperature_tb is

  component adc_i2c_controller is
    port (
      clk  : in std_logic;
      rstn : in std_logic;
      start : in std_logic;
      done : out std_logic;

      SDA : inout std_logic;
      SCL : out std_logic

      );
  end component adc_i2c_controller;

  signal clk_tb : std_logic := '1';
  signal rstn_tb : std_logic := '1';
  signal SCL_tb : std_logic;
  signal SDA_tb : std_logic;
  signal done_tb : std_logic;
  signal start_tb : std_logic := '0';

  
begin  -- architecture arch_I2C_master_for_temperature

  inst: adc_i2c_controller
    port map (
      clk  => clk_tb,
      rstn => rstn_tb,
      SCL  => SCL_tb,
      SDA  => SDA_tb,
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
               '0' after 281570 ns,
	       '1' after 400000 ns,
	       '0' after 680570 ns;
  --start_tb <= '1' after 1000 ns;


end architecture arch_I2C_master_for_temperature_tb;
