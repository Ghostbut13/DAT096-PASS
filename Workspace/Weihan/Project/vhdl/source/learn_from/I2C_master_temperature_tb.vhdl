
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.i2c_type_package.all;

entity I2C_master_for_temperature_tb is
 
end entity I2C_master_for_temperature_tb;

architecture arch_I2C_master_for_temperature_tb of I2C_master_for_temperature_tb is

  component I2C_master_for_temperature is
    port (
      clk  : in    std_logic;
      rstn : in    std_logic;
      SCL  : out   std_logic;
      SDA  : inout std_logic;
--      state1 : out 	i2c_state_type;
--      next_state1 : out 	i2c_state_type;
      data_show: out std_logic_vector(7 downto 0);
      data_show_1: out std_logic_vector(7 downto 0)
      );
  end component I2C_master_for_temperature;

  signal clk_tb : std_logic := '1';
  signal rstn_tb : std_logic := '1';
  signal SCL_tb : std_logic;
  signal SDA_tb : std_logic;
  signal  data_show: std_logic_vector(7 downto 0);
  signal  data_show_1: std_logic_vector(7 downto 0);
  signal state : i2c_state_type;
  signal next_state : i2c_state_type;
  
begin  -- architecture arch_I2C_master_for_temperature

  INST_I2C: I2C_master_for_temperature
    port map (
      clk  => clk_tb,
      rstn => rstn_tb,
      SCL  => SCL_tb,
      SDA  => SDA_tb,
--      state1 => state,
--      next_state1 => next_state,
      data_show => data_show,
      data_show_1 => data_show_1
      );


  proc_clk_gen : 
  process
  begin
    wait for 5 ns;
    clk_tb <= not(clk_tb) ;
  end process proc_clk_gen;
  rstn_tb <= '0' after 1 ns,
          '1' after 2 ns;


end architecture arch_I2C_master_for_temperature_tb;
