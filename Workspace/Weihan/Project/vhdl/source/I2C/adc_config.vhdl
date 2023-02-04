-------------------------------------------------------------------------------
-- Title      : adc_config
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adc_config.vhdl
-- Author     : weihan gao -- -- weihanga@chalmers.se
-- Company    : 
-- Created    : 2023-02-04
-- Last update: 2023-02-04
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

entity adc_config is
  port (
    rstn         : in  std_logic;
    clk          : in  std_logic;
    done         : in  std_logic;
    start        : out std_logic;
    config_value : out std_logic_vector(7 downto 0)
    );

end entity adc_config;

architecture arch_adc_config of adc_config is
  -- constant
  constant const_channel                : integer := 4;  -- the number of channel
  constant const_sleep_reg              : std_logic_vector(7 downto 0) := "10000101";
  constant const_interrupt_reg          : std_logic_vector(7 downto 0) := "00010000";
  constant const_c1_reg                 : std_logic_vector(7 downto 0) := "00011000";
  constant const_c2_reg                 : std_logic_vector(7 downto 0) := "00011000";
  constant const_c3_reg                 : std_logic_vector(7 downto 0) := "00011000";
  constant const_c4_reg                 : std_logic_vector(7 downto 0) := "00011000";
  constant const_input_channel_reg      : std_logic_vector(7 downto 0) := "11110000";
  constant const_8_reg                  : std_logic_vector(7 downto 0) := "11110000";
  constant const_powerup_reg            : std_logic_vector(7 downto 0) := "11100000";
  constant const_10_reg                 : std_logic_vector(7 downto 0) := "11110000";
  
  -- counter
  signal cnt_clk : integer;
  signal cnt_i2c : integer;
  signal cnt_channel : integer;
  
  -- fsm
  type adc_config_state_type is (
    idle_state,
    sleep_state,
    Interrupt_state,
    channel_state,
    input_state,
    power_up_state,
    stop_state,
    end_state
    );
  signal state : adc_config_state_type;
  signal next_state : adc_config_state_type;
  -- global control signals
  
  -- output signals
  signal OUT_start : std_logic;
  signal OUT_config_value : std_logic_vector(7 downto 0);
  -- registers
  
  

begin  -- architecture arch_adc_config
  start <= OUT_start;
  config_value <= OUT_config_value;

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
  
  state_flow_proc: process (state) is
  begin  -- process state_flow_proc
    case state is
      when idle_state =>
        next_state <= sleep_state;
      when sleep_state <=
        next_state <= Interrupt_state;
      when Interrupt_state =>
        next_state <= channel_state;
      when channel_state =>
        if cnt_channel < 5 then
          next_state <= channel_state;
        else
          next_state <= input_state;
        end if;
      when input_state =>
        next_state <= power_up_state;
      when power_up_state =>
        next_state <= stop_state;
      when stop_state => 
        next_state <= end_state;
      when others => null;
    end case;
  end process;

  assignment_proc: process (state) is
  begin  -- process assignment_proc
    case state is
      when idle_state =>
        OUT_start <= '0';
      when sleep_state =>
        OUT_config_value <= const_sleep_reg;
        OUT_start <= '1';
      when Interrupt_state =>
        OUT_config_value <= const_interrupt_reg;
        OUT_start <= '1';
      when channel_state =>
        if cnt_channel = 1 then
          OUT_config_value <= const_c1_reg;
        elsif cnt_channel = 2 then
          OUT_config_value <= const_c2_reg;
        elsif cnt_channel = 3 then
          OUT_config_value <= const_c3_reg;
        elsif cnt_channel = 4 then
          OUT_config_value <= const_c4_reg;
        else
          OUT_config_value <= "00000000";
        end if;
        OUT_start <= '1';
      when input_state =>
        OUT_config_value <= const_input_channel_reg;
        OUT_start <= '1';
      when power_up_state =>
        OUT_config_value <= const_powerup_reg;
        OUT_start <= '1';
      when stop_state =>
        OUT_start <= '0';
      when others => null;
    end case;
  end process assignment_proc;

  ----------------------------------------
  
end architecture arch_adc_config;
