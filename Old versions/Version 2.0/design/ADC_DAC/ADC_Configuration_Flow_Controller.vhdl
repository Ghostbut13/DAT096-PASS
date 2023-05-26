-------------------------------------------------------------------------------
-- Title      : ADC_Configuration_Flow_Controller(ACFC)
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adc_config.vhdl
-- Author     : weihan gao -- -- weihanga@chalmers.se
-- Company    : 
-- Created    : 2023-02-04
-- Last update: 2023-04-04
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Decide which registers and what value should be writen to ADC from FPGA,
-- to Configurate the mode of ADC ,through i2c protocol.
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-02-04  1.0      weihan	Created
-- 2023-02-06  1.1      weihan  structure done
-- 2023-02-10  1.3      weihan  adding master-mode state
-- 2023-02-11  1.5      weihan  re-order the fsm
-- 2023-02-12  2.0      weihan  done
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.config_state_package.all;

entity ADC_Configuration_Flow_Controller is
  
  port (
    finish_config_input : in std_logic;
    I2S_mode    : in  std_logic;
    master_mode : in  std_logic;
    GPIO_MCLK   : in  std_logic;
    FS_48k_256_BCLK  : in  std_logic;
    MCLK_root   : in std_logic;
    
    rstn         : in  std_logic;
    clk          : in  std_logic;
    done         : in  std_logic;
    start        : out std_logic;
    config_value : out std_logic_vector(7 downto 0);
    config_addr  : out std_logic_vector(7 downto 0);
    SHDNZ        : out std_logic;
    SHDNZ_ready  : in  std_logic;
    SW_vdd_ok    : in  std_logic
    
    
    );

end entity ADC_Configuration_Flow_Controller;

architecture arch_ADC_Configuration_Flow_Controller of ADC_Configuration_Flow_Controller is
  -- constant
  -- MODE reg addr
  constant const_addr_sleep_reg         : std_logic_vector(7 downto 0) := x"02";
  constant const_addr_interrupt_reg     : std_logic_vector(7 downto 0) := x"28";
  constant const_addr_c1_reg            : std_logic_vector(7 downto 0) := x"3c";
  constant const_addr_c2_reg            : std_logic_vector(7 downto 0) := x"41";
  constant const_addr_c3_reg            : std_logic_vector(7 downto 0) := x"46";
  constant const_addr_c4_reg            : std_logic_vector(7 downto 0) := x"4b";
  constant const_addr_input_channel_reg : std_logic_vector(7 downto 0) := x"73";
  constant const_addr_8_reg             : std_logic_vector(7 downto 0) := x"74";
  constant const_addr_powerup_reg       : std_logic_vector(7 downto 0) := x"75";
  constant const_addr_10_reg            : std_logic_vector(7 downto 0) := x"64";

  -- -- PLL MASTER-CONTROLLER-MODE addr (no need)
  -- constant const_addr_21_reg            : std_logic_vector(7 downto 0) := x"21";
  -- constant const_addr_13_reg            : std_logic_vector(7 downto 0) := x"13";
  -- constant const_addr_14_reg            : std_logic_vector(7 downto 0) := x"14"

  constant CHANNEL_NUMBER : integer := 4;
  constant WTIME_1ms_CNT  : integer := 1010000 / 10;
  constant WTIME_10ms_CNT : integer := 10100000 / 10;
  constant WTIME_20ms_CNT : integer := 20100000 / 10;
  -- counter
  signal cnt_clk : integer;
  signal cnt_single_config_i2c : integer;
  signal cnt_channel : integer;  
  -- fsm
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
  signal flag_stop_single_config : std_logic;
  signal flag_finish_config_progr : std_logic;
  -- value registers
  -- -- for adc config
  signal value_wakeup           : std_logic_vector(7 downto 0) := "10000001";
  signal value_powerdown        : std_logic_vector(7 downto 0) := "00010000";

  signal value_c1_config        : std_logic_vector(7 downto 0) := "00010000";--"00010000" ->
                                                                             --mic_input
                                                                             --differential_input
                                                                             --DC-coupled
                                                                             --

  signal value_c2_config        : std_logic_vector(7 downto 0) := "00010000";
  signal value_c3_config        : std_logic_vector(7 downto 0) := "00010000";--
  signal value_c4_config        : std_logic_vector(7 downto 0) := "00010000";--

  
  signal value_enable_input     : std_logic_vector(7 downto 0) := "11110000";-- 4channel
  signal value_enable_output    : std_logic_vector(7 downto 0) := "11110000";-- 4channel

  signal value_powerup          : std_logic_vector(7 downto 0) := "11100000";
  signal value_enable_diagno    : std_logic_vector(7 downto 0) := "00000000";
  -- -- for waiting_time between some config steps 
  signal waiting_time           : integer := 0;
  -- -- --for adc PLL-controller-MODE (no need)
  -- signal value_GPIO1_MCLK : std_logic_vector(7 downto 0) := x"a0";  -- config GPIO1 as MCLK input
  -- signal value_master_device : std_logic_vector(7 downto 0) := x"80";  -- config device as master with MCLK
  -- signal value_FS_BCLK_R : std_logic_vector(7 downto 0) := x"48";  -- FS = 44.1k or 48k  BCLK/ratio = 256

  
  -- edge signal
  signal d1_I2S_mode    : std_logic;
  signal d1_master_mode : std_logic;
  signal d1_GPIO_MCLK   : std_logic;
  signal d1_FS_48k_256_BCLK  : std_logic;
  signal d1_MCLK_root  : std_logic;
  
  signal d2_I2S_mode    : std_logic;
  signal d2_master_mode : std_logic;
  signal d2_GPIO_MCLK   : std_logic;
  signal d2_FS_48k_256_BCLK  : std_logic;
  signal d2_MCLK_root : std_logic;

  signal edge_I2S_mode    : std_logic;
  signal edge_master_mode : std_logic;
  signal edge_GPIO_MCLK   : std_logic;
  signal edge_FS_48k_256_BCLK  : std_logic;
  signal edge_MCLK_root : std_logic;
  
begin  -- architecture arch_adc_config
  start         <= OUT_start;
  config_value  <= OUT_config_value;
  config_addr   <= OUT_config_addr;
  SHDNZ         <= out_SHDNZ;
  out_SHDNZ     <= '1' when SHDNZ_ready='1' else
                   '0';
  flag_finish_config_progr <= finish_config_input;
  ----------------------------------------
  -- purpose: waiting 
  waitingtime_proc: process (clk, rstn) is
  begin
    if rstn = '0' then                 -- asynchronous reset (active low)
      cnt_clk <= 0;
      flag_cnt_STOP <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if SHDNZ_READY='1' then
        if flag_cnt_START='1' then
          if cnt_clk < waiting_time then
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
  
  edge_FS_48k_256_BCLK  <=  (d1_FS_48k_256_BCLK) and not(d2_FS_48k_256_BCLK);
  edge_GPIO_MCLK        <=  (d1_GPIO_MCLK)       and not(d2_GPIO_MCLK);
  edge_master_mode      <=  (d1_master_mode)     and not(d2_master_mode);
  edge_I2S_mode         <=  (d1_I2S_mode)        and not(d2_I2S_mode);
  edge_MCLK_root        <=  (d1_MCLK_root)       and not(d2_MCLK_root);
----------------------------------------
  -- purpose: cnt_single_config
  cnt_single_config_proc: process (clk, rstn) is
  begin  -- process flagflag
    if rstn = '0' then                 -- asynchronous reset (active low)
      cnt_single_config_i2c <= 0;
      d1_FS_48k_256_BCLK <= '0';
      d1_GPIO_MCLK <= '0';
      d1_master_mode <= '0';
      d1_I2S_mode <= '0';
      d1_MCLK_root <= '0';
      
      d2_FS_48k_256_BCLK <= '0';
      d2_GPIO_MCLK <= '0';
      d2_master_mode <= '0';
      d2_I2S_mode <= '0';
      d2_MCLK_root <= '0';

      flag_stop_single_config <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge
      d1_FS_48k_256_BCLK <= FS_48k_256_BCLK;
      d1_GPIO_MCLK <= GPIO_MCLK;
      d1_master_mode <= master_mode;
      d1_I2S_mode <= I2S_mode;
      d1_MCLK_root <= MCLK_root;

      d2_FS_48k_256_BCLK <= d1_FS_48k_256_BCLK;
      d2_GPIO_MCLK <= d1_GPIO_MCLK;
      d2_master_mode <=  d1_master_mode;
      d2_I2S_mode <= d1_I2S_mode;
      d2_MCLK_root <= d1_MCLK_root;
      if (edge_I2S_mode='1' or edge_master_mode ='1' or edge_GPIO_MCLK='1' or edge_FS_48k_256_BCLK ='1' or edge_MCLK_root='1') then
        cnt_single_config_i2c <= 0;
        flag_stop_single_config <= '1';
      else
        if (d2_I2S_mode='1' or d2_master_mode ='1' or d2_GPIO_MCLK='1' or d2_FS_48k_256_BCLK ='1' or d2_MCLK_root='1' ) and cnt_single_config_i2c<55580 then
          cnt_single_config_i2c <= cnt_single_config_i2c+1;
          flag_stop_single_config <= '0';
        else
          flag_stop_single_config <= '1';
        end if;
      end if;
    end if;
  end process cnt_single_config_proc;
  
  ----------------------------------------
  -- purpose: fsm
  state_transition_proc: process (clk, rstn) is
  begin  -- process state_transition_proc
    if rstn = '0' then                  -- asynchronous reset (active low)
      state <= idle_state;
    elsif clk'event and clk = '1' then  -- rising clock edge
      state <= next_state;
      if SW_vdd_ok = '0' then           -- every VDD is not ok
        state <= idle_state;
      --next_state <= idle_state;
      else                              -- 
        if SHDNZ_READY='0' then               -- VDD is OK and Shutdown
          state <= hardware_shutdown_state;
        --next_state <= hardware_shutdown_state;
        else
          state <= next_state; 
        end if;
      --state <= next_state;
      end if;
    end if;
  end process state_transition_proc;
  
  state_flow_proc: process (state, cnt_channel, SW_vdd_ok, flag_cnt_STOP, SHDNZ_READY, done, flag_finish_config_progr) is
  begin  -- process state_flow_proc
    next_state <= idle_state;
    case state is --
      when  idle_state =>
        if SW_vdd_ok ='1' then
          next_state <= hardware_shutdown_state;
        else
          next_state <= idle_state;
        end if;
      when  hardware_shutdown_state =>  --2b start
        if SHDNZ_READY = '1' then
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
      when wakeup_state  =>             --3a and 3b start
        if done = '1' then
          next_state <=  woke_state ;
        else
          next_state <=  wakeup_state;
        end if;
      when woke_state =>                --3b stop
        if flag_cnt_STOP = '1' then
          next_state <=  config_and_programm_state;
        else
          next_state <=  woke_state;
        end if;
      -----------------------------------------------------------------------
      -- Override the default configuration registers or
      -- programmable coefficients value as required (optional)
      when config_and_programm_state =>  
        if flag_finish_config_progr = '1' then
          next_state <= powerdown_state;
        else
          next_state <= config_and_programm_state;
        end if;
      -----------------------------------------------------------------------
      -----------------------------------------------------------------------
      when powerdown_state  =>          --3c
        if done = '1' then
          next_state <= config_channel_1_state;
        else
          next_state <= powerdown_state;
        end if;
      when  config_channel_1_state =>     --3c
        if done = '1' then                      --1st channel
          next_state <= config_channel_2_state;
        else
          next_state <= config_channel_1_state;
        end if;
      when  config_channel_2_state =>     --3c
        if done = '1' then                      --2nd  channel
          next_state <= config_channel_3_state;
        else
          next_state <= config_channel_2_state;
        end if;
      when  config_channel_3_state =>     --3c
        if done = '1' then                      --3rd channel
          next_state <= config_channel_4_state;
        else
          next_state <= config_channel_3_state;
        end if;
      when  config_channel_4_state =>     --3c
        if done = '1' then                      --4th  channel
          next_state <= enable_input_state;
        else
          next_state <= config_channel_4_state;
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
      when  APPLY_BCLK_FSYNC_state =>   --3g and 3h and 3i start -- not used in
                                        --master mode
        next_state <=  I2S_working_state;
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
        next_state <=  waiting_state;
      when waiting_state =>
        next_state <=  waiting_state;
      when others => null;
    end case;
    
    if SW_vdd_ok = '0' then           -- every VDD is not ok
      next_state <= idle_state;
    --next_state <= idle_state;
    else                              -- 
      if SHDNZ_READY='0' then               -- VDD is OK and Shutdown
        -- state <= hardware_shutdown_state;
        next_state <= hardware_shutdown_state;
      else
      -- state <= next_state; 
      end if;
    --state <= next_state;
    end if;
    
  end process;

  assignment_proc: process (state,cnt_channel, SW_vdd_ok,SHDNZ_READY,done, 
                            value_wakeup,value_powerdown,value_c1_config, 
                            value_c2_config,value_c3_config,value_c4_config, 
                            value_enable_input,value_enable_output,value_powerup ,
                            value_enable_diagno,
                            flag_finish_config_progr,
                            d2_I2S_mode ,d2_master_mode,d2_GPIO_MCLK ,d2_FS_48k_256_BCLK,d2_MCLK_root,
                            flag_stop_single_config) is
  begin  -- process assignment_proc

    if flag_stop_single_config='1' then
      OUT_config_value <= x"00";
      OUT_config_addr <= x"00";
      flag_cnt_START <= '0';
      waiting_time    <= 0;
      OUT_start       <= '0';
    else 
--      OUT_config_value <= x"00";
--      OUT_config_addr <= x"00";
--      flag_cnt_START <= '0';
--      waiting_time    <= 0;
--      OUT_start       <= '0';
    end if;
    case state is
      when idle_state =>
        flag_cnt_START  <= '0';
        waiting_time    <= 0;
        OUT_start       <= '0';
      when hardware_shutdown_state =>   --2b start
        if SHDNZ_READY = '1' then
          flag_cnt_START <= '1';        
          waiting_time <= 101000;
        else
          flag_cnt_START <= '0';
          waiting_time <= 0;
        end if;
        OUT_start <= '0';
      when SHDNZ_state =>               --2b stop
        OUT_start <= '0';               --Attention : after this, we can config
                                        --the regs
        flag_cnt_START <= '1';
        waiting_time <= 101000;
      when wakeup_state  =>             --3a
        flag_cnt_START <= '0';
        waiting_time <= 0;
        OUT_config_value <= value_wakeup;
        OUT_config_addr <= const_addr_sleep_reg;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when woke_state =>                --3b
        flag_cnt_START <= '1';        
        waiting_time <= 101000;
        OUT_start <= '0';
      -----------------------------------------------------------------------
      -- Override the default configuration registers
      -- or programmable coefficients value as required (optional)
      -----------------------------------------------------------------------
      when config_and_programm_state =>
        -- I2S
        if d2_I2S_mode = '1' and flag_stop_single_config ='0' then
          flag_cnt_START <= '0';
          waiting_time <= 0;
          OUT_config_value <= x"40";
          OUT_config_addr  <= x"07";
          if done='1' then
            OUT_start <= '0';
          else
            OUT_start <= '1';
          end if;
        else
          
        end if;
        --  master mode
        if d2_master_mode = '1'  and flag_stop_single_config ='0' then
          flag_cnt_START <= '0';
          waiting_time <= 0;
          OUT_config_value <= x"81";
          OUT_config_addr  <= x"13";
          if done='1' then
            OUT_start <= '0';
          else
            OUT_start <= '1';
          end if;
        else
          
        end if;
        -- configure GPIO1 as MCLK input
        if d2_GPIO_MCLK = '1' and flag_stop_single_config ='0'  then
          flag_cnt_START <= '0';
          waiting_time <= 0;
          OUT_config_value <= x"a0";
          OUT_config_addr  <= x"21";
          if done='1' then
            OUT_start <= '0';
          else
            OUT_start <= '1';
          end if;
        else
          
        end if;
        -- FS = 44.1/48k BCLK/ratio = 256
        if d2_FS_48k_256_BCLK = '1'  and flag_stop_single_config  ='0' then
          flag_cnt_START <= '0';
          waiting_time <= 0;

          OUT_config_value <= x"46";   --48
          --OUT_config_value <= x"48";

          OUT_config_addr  <= x"14";
          if done='1' then
            OUT_start <= '0';
          else
            OUT_start <= '1';
          end if;
        else
          
        end if;
        -- MCLK_root = 256
        if d2_MCLK_root= '1'  and flag_stop_single_config  ='0' then
          flag_cnt_START <= '0';
          waiting_time <= 0;
          OUT_config_value <= x"88";
          OUT_config_addr  <= x"16";
          if done='1' then
            OUT_start <= '0';
          else
            OUT_start <= '1';
          end if;
        else
          
        end if;
      -------------------------------------------------------------------------
      when powerdown_state  =>          --3c
        flag_cnt_START <= '0';
        waiting_time <= 0;
        OUT_config_value <= value_powerdown;
        OUT_config_addr <= const_addr_interrupt_reg;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when config_channel_1_state =>      --3c
        flag_cnt_START <= '0';
        waiting_time <= 0;
        OUT_config_value <= value_c1_config;  -- 1st channel
        OUT_config_addr <= const_addr_c1_reg;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when config_channel_2_state =>      --3c
        flag_cnt_START <= '0';
        waiting_time <= 0;
        OUT_config_value <= value_c2_config;  -- 2nd channel
        OUT_config_addr <= const_addr_c2_reg;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;

      when config_channel_3_state =>      --3c
        flag_cnt_START <= '0';
        waiting_time <= 0;
        OUT_config_value <= value_c3_config;  -- 3rd channel
        OUT_config_addr <= const_addr_c3_reg;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when config_channel_4_state =>      --3c
        flag_cnt_START <= '0';
        waiting_time <= 0;
        OUT_config_value <= value_c4_config;  -- 4th channel
        OUT_config_addr <= const_addr_c4_reg;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when  enable_input_state =>       --3d
        OUT_config_value <= value_enable_input;
        OUT_config_addr <= const_addr_input_channel_reg;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when enable_output_state =>       --3e
        OUT_config_value <= value_enable_output;
        OUT_config_addr  <= const_addr_8_reg;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when  powerup_state=>             --3f
        OUT_config_value <= value_powerup;
        OUT_config_addr <= const_addr_powerup_reg ;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      --------------------------------------------------------------------------------
      when  APPLY_BCLK_FSYNC_state =>   --3g and 3h and 3i start

        
        flag_cnt_START <= '1';        
        waiting_time <= 1010000;      -- 10 ms
        OUT_start <= '0';
        

        
      --------------------------------------------------------------------------------
      when I2S_working_state =>         --3i stop
        flag_cnt_START <= '1';   
        OUT_start <= '0';
        waiting_time <= 1010000;        -- 10 ms
      when  enable_diagnostics_state => --3j
        flag_cnt_START <= '0';
        waiting_time <= 0;
        OUT_config_value <=  value_enable_diagno;
        OUT_config_addr  <= const_addr_10_reg ;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when  disable_diagnostics_state => --3j
        waiting_time <= 0;
        OUT_start <= '0';
        flag_cnt_START <= '0';
        OUT_config_value <=  value_enable_diagno;
        OUT_config_addr  <= const_addr_10_reg ;
        if done='1' then
          OUT_start <= '0';
        else
          OUT_start <= '1';
        end if;
      when stop_state =>
        OUT_start <= '0';
      when waiting_state =>                 --in this state, forever circle
                                            --waiting for test
        OUT_start <= '0';
      when others => null;
    end case;
  end process assignment_proc;
end architecture arch_ADC_Configuration_Flow_Controller;
