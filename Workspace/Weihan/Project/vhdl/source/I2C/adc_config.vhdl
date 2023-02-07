-------------------------------------------------------------------------------
-- Title      : adc_config_flow
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adc_config.vhdl
-- Author     : weihan gao -- -- weihanga@chalmers.se
-- Company    : 
-- Created    : 2023-02-04
-- Last update: 2023-02-07
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
--
-- Configration by FPGA as master using the i2c protocol.
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-02-04  1.0      ASUS	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_state_package.all;

entity adc_config is
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
    SHDNZ_pin    : in  std_logic;
    SW_vdd_ok    : in  std_logic
    );

end entity adc_config;

architecture arch_adc_config of adc_config is
  -- constant
  constant CHANNEL_NUMBER : integer := 4;
  constant WTIME_1ms_CNT  : integer := 1000000 / 10 / 2;
  constant WTIME_10ms_CNT : integer := 280570 / 10;
  constant WTIME_20ms_CNT : integer := 280570 / 10;
  -- counter
  signal cnt_clk : integer;
  --signal cnt_i2c : integer;
  signal cnt_channel : integer;  
  -- fsm
  -- type adc_config_state_type is (
  --   idle_state,
  --   hardware_shutdown_state,
  --   SHDNZ_state,
  --   wakeup_state,
  --   powerdown_state,
  --   config_channel_state,
  --   enable_input_state,
  --   enable_output_state,
  --   powerup_state,
  --   APPLY_BCLK_FSYNC_state,
  --   enable_diagnostics_state,
  --   disable_diagnostics_state,
  --   stop_state,
  --   end_state
  --   );
  signal state : adc_config_state_type;
  signal next_state : adc_config_state_type;
  -- output signals
  signal OUT_start : std_logic;
  signal OUT_config_value : std_logic_vector(7 downto 0);
  signal OUT_config_addr  : std_logic_vector(7 downto 0);
  signal out_SHDNZ : std_logic;
  -- control/flag register
  signal flag_cnt_START : std_logic := '0';
  signal flag_cnt_STOP : std_logic;
  -- value registers
  -- -- for adc config
  signal value_wakeup           : std_logic_vector(7 downto 0) := "10000101";
  signal value_powerdown        : std_logic_vector(7 downto 0) := "00010000";
  signal value_c1_config        : std_logic_vector(7 downto 0) := "00011000";
  signal value_c2_config        : std_logic_vector(7 downto 0) := "00011000";
  signal value_c3_config        : std_logic_vector(7 downto 0) := "00011000";
  signal value_c4_config        : std_logic_vector(7 downto 0) := "00011000";
  signal value_enable_input     : std_logic_vector(7 downto 0) := "11110000";
  signal value_enable_output    : std_logic_vector(7 downto 0) := "11110000";
  signal value_powerup          : std_logic_vector(7 downto 0) := "11100000";
  signal value_enable_diagno    : std_logic_vector(7 downto 0) := "11110000";
  -- -- for waiting_time between some config steps 
  signal waiting_time           : integer := 0;
  

begin  -- architecture arch_adc_config
  start         <= OUT_start;
  config_value  <= OUT_config_value;
  config_addr   <= OUT_config_addr;
  --SHDNZ_pin     <= out_SHDNZ;
  
  ----------------------------------------
  -- purpose: waiting 
  waitingtime_proc: process (clk, rstn) is
    variable k : integer := 0;        -- Parameter passing
  begin
    k := waiting_time;
    if rstn = '0' then                 -- asynchronous reset (active low)
      cnt_clk <= 0;
      flag_cnt_STOP <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if SHDNZ_pin='1' then
        if flag_cnt_START='1' then
          if cnt_clk < k then
            cnt_clk <= cnt_clk+1;
            flag_cnt_STOP <= '0';
          else
            cnt_clk <= 0;
            flag_cnt_STOP <= '1';
          end if;
        else
          flag_cnt_STOP <= '0';
          cnt_clk <= 0;
        end if;
      else
        cnt_clk <= 0;
        flag_cnt_STOP <= '0';
      end if;
    end if;
  end process waitingtime_proc;
  
  ----------------------------------------
  -- purpose: fsm
  state_transition_proc: process (clk, rstn) is
  begin  -- process state_transition_proc
    if rstn = '0' then                  -- asynchronous reset (active low)
      state <= idle_state;
    elsif clk'event and clk = '1' then  -- rising clock edge
      state <= next_state;
    end if;
  end process state_transition_proc;
  
  state_flow_proc: process (state, cnt_channel, SW_vdd_ok, flag_cnt_STOP, SHDNZ_pin, done) is
  begin  -- process state_flow_proc
    case state is --
      when  idle_state =>
        if SW_vdd_ok ='1' then
          next_state <= hardware_shutdown_state;
        else
          next_state <= idle_state;
        end if;
      when  hardware_shutdown_state =>  --2b start
        if SHDNZ_pin = '1' then
          next_state <=  SHDNZ_state;
        else
          next_state <=  hardware_shutdown_state;
        end if;
      when SHDNZ_state =>               --2b stop
        if flag_cnt_STOP = '1' then
          next_state <=  wakeup_state;
        else
          next_state <=  SHDNZ_state;
        end if;
      when wakeup_state  =>             --3a and 
        if done = '1' then
          next_state <= woke_state ;
        else
          next_state <= wakeup_state;
        end if;
      when woke_state =>                --3b stop
        if flag_cnt_STOP = '1' then
          next_state <=  powerdown_state;
        else
          next_state <=  woke_state;
        end if;
      when powerdown_state  =>          --3c
        if done = '1' then
          next_state <= config_channel_state;
        else
          next_state <= powerdown_state;
        end if;
      when  config_channel_state =>     --3c
        -- if cnt_channel <= CHANNEL_NUMBER then
        --   next_state <= config_channel_state;
        -- else
        --   next_state <= enable_input_state;
        -- end if;
        if done = '1' then              --only for 1 channel
          next_state <= enable_input_state;
        else
          next_state <= config_channel_state;
        end if;
      when  enable_input_state =>       --3d
        if done = '1' then
          next_state <= enable_output_state;
        else
          next_state <= enable_input_state;
        end if;
      when  enable_output_state =>      --3e
        if done = '1' then
          next_state <= powerup_state;
        else
          next_state <= enable_output_state;
        end if;
      when  powerup_state=>             --3f
        if done = '1' then
          next_state <= APPLY_BCLK_FSYNC_state;
        else
          next_state <= powerup_state;
        end if;
      --------------------------------------------------------------------------------
      when  APPLY_BCLK_FSYNC_state =>   --3g and 3h and 3i start
        next_state <=  I2S_working_state;
        --
        --
      --------------------------------------------------------------------------------
      when I2S_working_state =>         --3i stop
        if flag_cnt_STOP = '1' then
          next_state <=  enable_diagnostics_state;
        else
          next_state <=  I2S_working_state;
        end if;
      when  enable_diagnostics_state => --3j
        if done = '1' then
          -- next_state <= disable_diagnostics_state;
          next_state <= stop_state;
        else
          next_state <= enable_diagnostics_state;
        end if;
      when  disable_diagnostics_state =>
        --next_state <=  stop_state;
        --
      when stop_state =>
        next_state <=  end_state;
      when end_state =>
      when others => null;
    end case;
  end process;

  assignment_proc: process (state,cnt_channel, SW_vdd_ok,SHDNZ_pin,done) is
  begin  -- process assignment_proc
    OUT_config_value <= x"00";
    case state is
      when idle_state =>
        flag_cnt_START  <= '0';
        waiting_time    <= 0;
        OUT_start       <= '0';
      when hardware_shutdown_state =>   --2b start
        if SHDNZ_pin = '1' then
          flag_cnt_START <= '1';        
          waiting_time <= WTIME_1ms_CNT;
        else
          flag_cnt_START <= '0';
          waiting_time <= 0;
        end if;
        OUT_start <= '0';
      when SHDNZ_state =>               --2b stop
        OUT_start <= '0';
      when wakeup_state  =>             --3a
        flag_cnt_START <= '0';
        waiting_time <= 0;
        OUT_config_value <= value_wakeup;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when woke_state =>                --3b
        flag_cnt_START <= '1';        
        waiting_time <= WTIME_1ms_CNT;
        OUT_start <= '0';
      when powerdown_state  =>          --3c
        flag_cnt_START <= '0';
        waiting_time <= 0;
        OUT_config_value <= value_powerdown;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when config_channel_state =>      --3c
        -- if cnt_channel = 1 then
        --   OUT_config_value <= value_c1_config;
        -- elsif cnt_channel = 2 then
        --   OUT_config_value <= value_c2_config;
        -- elsif cnt_channel = 3 then
        --   OUT_config_value <= value_c3_config;
        -- elsif cnt_channel = 4 then
        --   OUT_config_value <= value_c4_config;
        -- else
        --   OUT_config_value <= "00000000";
        -- end if;
        -- OUT_config_value <= value_c1_config;
        -- OUT_start <= '1';
        flag_cnt_START <= '0';
        waiting_time <= 0;
        OUT_config_value <= value_c1_config;  -- we just do only one channel
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when  enable_input_state =>       --3d
        OUT_config_value <= value_enable_input;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when enable_output_state =>       --3e
        OUT_config_value <= value_enable_output;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when  powerup_state=>             --3f
        OUT_config_value <= value_powerup;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      --------------------------------------------------------------------------------
      when  APPLY_BCLK_FSYNC_state =>   --3g and 3h and 3i start
        flag_cnt_START <= '1';        
        waiting_time <= WTIME_1ms_CNT;
        OUT_start <= '0';
      --------------------------------------------------------------------------------
      when I2S_working_state =>         --3i stop
        
        OUT_start <= '0';
        
      when  enable_diagnostics_state => --3j
        flag_cnt_START <= '0';
        waiting_time <= 0;
        OUT_config_value <=  value_enable_diagno;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when  disable_diagnostics_state => --3j
        OUT_start <= '0';
      when stop_state =>
        OUT_start <= '0';
      when end_state =>
        OUT_start <= '0';
      when others => null;
    end case;
  end process assignment_proc;

  ----------------------------------------
  
end architecture arch_adc_config;
