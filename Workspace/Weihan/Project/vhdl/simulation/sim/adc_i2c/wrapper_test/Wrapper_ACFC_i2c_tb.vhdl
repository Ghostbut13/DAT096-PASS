
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_state_package.all;
use work.i2c_type_package.all;

entity Wrapper_ACFC_i2c_tb is
  
end entity Wrapper_ACFC_i2c_tb;

architecture arch of Wrapper_ACFC_i2c_tb is

  component Wrapper_ACFC_i2c is
    port (
      -- clk and rstn
      clk       : in    std_logic;
      rstn      : in    std_logic;
      -- control ready
      SW_vdd_ok : in    std_logic;
      SHDNZ     : in    std_logic;
      -- i2c communication
      SDA       : inout std_logic;
      SCL       : out   std_logic
      -- FSNYC and BCLK
      --FSNYC     : out   std_logic;
      --BCLK      : out   std_logic
      );
  end component Wrapper_ACFC_i2c;

  signal clk_tb  : std_logic := '1';
  signal rstn_tb : std_logic := '1';
  signal SCL_tb  : std_logic;
  signal SDA_tb  : std_logic;
  signal SHDNZ_pin_tb : std_logic := '0';
  signal SW_vdd_ok_tb :  std_logic := '0';


  
begin  -- architecture arch_I2C_master_for_temperature

  inst_W: Wrapper_ACFC_i2c
    port map (
      clk => clk_tb,
      rstn => rstn_tb,

      SW_vdd_ok => SW_vdd_ok_tb,
      SHDNZ => SHDNZ_pin_tb,

      SDA => SDA_tb,
      SCL => SCL_tb
      
      );


  proc_clk_gen : 
  process
  begin
    wait for 5 ns;
    clk_tb <= not(clk_tb) ;
  end process proc_clk_gen;
  rstn_tb <= '0' after 1 ns,
             '1' after 2 ns;


  
  SW_vdd_ok_tb <= '1' after 243 ns;
                  -- '0' after when_can_done * 19 + 10 ns,
                  -- '1' after when_can_done * 22;

  SHDNZ_pin_tb <= '1' after 991 ns,
                  -- good 28 10 29
                  --'0' after when_can_done * 28 + 10 ns,
                  --'1' after when_can_done * 29;
                  -- fixed time : 14000000
                  '0' after 14000000 ns,
                  '1' after 14600000 ns;

 
              


end architecture arch;
