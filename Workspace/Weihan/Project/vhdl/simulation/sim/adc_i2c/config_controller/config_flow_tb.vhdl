
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_state_package.all;

entity config_flow_tb is
  
end entity config_flow_tb;

architecture arch_I2C_master_for_temperature_tb of config_flow_tb is

  component adc_config is
    generic(
      -- addr reg
      constant const_addr_sleep_reg         : std_logic_vector(7 downto 0) := x"02";
      constant const_addr_interrupt_reg     : std_logic_vector(7 downto 0) := x"28";
      constant const_addr_c1_reg            : std_logic_vector(7 downto 0) := x"3c";
      constant const_addr_c2_reg            : std_logic_vector(7 downto 0) := x"41";
      constant const_addr_c3_reg            : std_logic_vector(7 downto 0) := x"46";
      constant const_addr_c4_reg            : std_logic_vector(7 downto 0) := x"4b";
      constant const_addr_input_channel_reg : std_logic_vector(7 downto 0) := x"73";
      constant const_addr_8_reg             : std_logic_vector(7 downto 0) := x"74";
      constant const_addr_powerup_reg       : std_logic_vector(7 downto 0) := x"75";
      constant const_addr_10_reg            : std_logic_vector(7 downto 0) := x"64"
      );
    
    port (
      rstn         : in  std_logic;
      clk          : in  std_logic;
      done         : in  std_logic;
      start        : out std_logic;
      config_value : out std_logic_vector(7 downto 0);
      config_addr  : out std_logic_vector(7 downto 0);
      SHDNZ        : in  std_logic;
      SW_vdd_ok    : in  std_logic
      );

  end component adc_config;


  constant when_can_done : time := 600000 ns;
  constant restart_ACFC  : time := when_can_done*22;
  

  signal clk_tb : std_logic := '1';
  signal rstn_tb : std_logic := '1';
  signal SCL_tb : std_logic;
  signal SDA_tb : std_logic;
  signal done_tb : std_logic := '0';
  signal start_tb : std_logic;
  signal SHDNZ_pin_tb : std_logic := '0';
  signal SW_vdd_ok_tb    :  std_logic := '0';


  
begin  -- architecture arch_I2C_master_for_temperature

  inst: adc_config
    port map (
      clk  => clk_tb,
      rstn => rstn_tb,
      --SCL  => SCL_tb,
      --SDA  => SDA_tb,
      done => done_tb,
      start => start_tb,
      SHDNZ => SHDNZ_pin_tb,
      SW_vdd_ok => SW_vdd_ok_tb
      );


  proc_clk_gen : 
  process
  begin
    wait for 5 ns;
    clk_tb <= not(clk_tb) ;
  end process proc_clk_gen;
  rstn_tb <= '0' after 1 ns,
             '1' after 2 ns;


  
  SW_vdd_ok_tb <= '1' after 243 ns,
                  '0' after when_can_done * 19 + 10 ns,
                  '1' after when_can_done * 22;

  SHDNZ_pin_tb <= '1' after 991 ns,
                  -- good 28 10 29
                  --'0' after when_can_done * 28 + 10 ns,
                  --'1' after when_can_done * 29;
                  -- fixed time : 14000000
                  '0' after 14000000 ns,
                  '1' after 14600000 ns;

  
  done_tb <= '1' after when_can_done,
             '0' after when_can_done + 10 ns, --3a
             -- '1' after when_can_done * 2,
             -- '0' after when_can_done * 2 + 10 ns, --3b
             '1' after when_can_done * 3,
             '0' after when_can_done * 3 + 10 ns, --3c
             '1' after when_can_done * 4,
             '0' after when_can_done * 4 + 10 ns, --3c
             '1' after when_can_done * 5,
             '0' after when_can_done * 5 + 10 ns, --3d
             '1' after when_can_done * 6,
             '0' after when_can_done * 6 + 10 ns, --3e
             '1' after when_can_done * 7,
             '0' after when_can_done * 7 + 10 ns, --3f
             -- '1' after when_can_done * 8,
             -- '0' after when_can_done * 8 + 10 ns, --3g
             -- '1' after when_can_done * 9,
             -- '0' after when_can_done * 9 + 10 ns, --3h
             -- '1' after when_can_done * 10,
             -- '0' after when_can_done * 10 + 10 ns, --3i
             '1' after when_can_done * 18,
             '0' after when_can_done * 18 + 10 ns,  --3j





             ----------------------------------------restart ACFC
             '1' after restart_ACFC+when_can_done,
             '0' after restart_ACFC+when_can_done + 10 ns, --3a
             -- '1' after restart_ACFC+when_can_done * 2,
             -- '0' after restart_ACFC+when_can_done * 2 + 10 ns, --3b
             '1' after restart_ACFC+when_can_done * 3,
             '0' after restart_ACFC+when_can_done * 3 + 10 ns, --3c
             '1' after restart_ACFC+when_can_done * 4,
             '0' after restart_ACFC+when_can_done * 4 + 10 ns, --3c
             '1' after restart_ACFC+when_can_done * 5,
             '0' after restart_ACFC+when_can_done * 5 + 10 ns, --3d
             '1' after restart_ACFC+when_can_done * 6,
             '0' after restart_ACFC+when_can_done * 6 + 10 ns, --3e
             '1' after restart_ACFC+when_can_done * 7,
             '0' after restart_ACFC+when_can_done * 7 + 10 ns, --3f
             -- '1' after restart_ACFC+when_can_done * 8,
             -- '0' after restart_ACFC+when_can_done * 8 + 10 ns, --3g
             -- '1' after restart_ACFC+when_can_done * 9,
             -- '0' after restart_ACFC+when_can_done * 9 + 10 ns, --3h
             -- '1' after restart_ACFC+when_can_done * 10,
             -- '0' after restart_ACFC+when_can_done * 10 + 10 ns, --3i
             '1' after restart_ACFC+when_can_done * 18,
             '0' after restart_ACFC+when_can_done * 18 + 10 ns;  --3j
              


end architecture arch_I2C_master_for_temperature_tb;
