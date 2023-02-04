-------------------------------------------------------------------------------
-- Title      : adc_i2c_fsm_controller
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adc_i2c_controller.vhdl
-- Author     : Weihan Gao -- -- weihanga@chalmers.se
-- Company    : 
-- Created    : 2023-02-04
-- Last update: 2023-02-04
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Get the config-value from adc_config.vhdl,
-- and push them into adc board through the I2C
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

entity adc_i2c_controller is
  port (
    clk  : in std_logic;
    rstn : in std_logic;
    start : in std_logic;
    done : out std_logic;

    SDA : inout std_logic;
    SCL : out std_logic
    );

end entity adc_i2c_controller;

architecture arch_adc_i2c_fsm_controller of adc_i2c_controller is
  -- constant

  -- count

  -- fsm
  type i2c_state_type is (
    idle_state,
    start_state,
    
    write_i2c_addr_state_0,
    write_i2c_addr_state_1,
    write_i2c_addr_state_2,
    write_i2c_addr_state_3,
    write_i2c_addr_state_4,
    write_i2c_addr_state_5,
    write_i2c_addr_state_6,
    write_i2c_addr_state_7,
    RECEIVE_ACK_state,

    write_reg_addr_state_0,
    write_reg_addr_state_1,
    write_reg_addr_state_2,
    write_reg_addr_state_3,
    write_reg_addr_state_4,
    write_reg_addr_state_5,
    write_reg_addr_state_6,
    write_reg_addr_state_7,
    RECEIVE_ACK_state,

    write_reg_data_state_0,
    write_reg_data_state_1,
    write_reg_data_state_2,
    write_reg_data_state_3,
    write_reg_data_state_4,
    write_reg_data_state_5,
    write_reg_data_state_6,
    write_reg_data_state_7,
    RECEIVE_ACK_state,

    end_state   
    
    );
  signal state : i2c_state_type;
  signal next_state : i2c_state_type;
  
  -- output/inout signals
  signal OUT_BIT : std_logic;
  signal IN_bit : std_logic;
  -- flag reg
  signal flag_sent : std_logic;
  -- clk reg
  signal clk_10k : std_logic;
  
begin  -- architecture arch_adc_i2c_fsm_controller
  SCL           <=      clk_10k;
  IN_bit        <=      SDA;
  SDA           <=      OUT_BIT when flag_sent='1' else
                        'Z';

  ----------------------------------------
  -- purpose: i2c_protocol_fsm
  state_transimit_proc: process (clk, rstn) is
  begin  -- process state_transimit_proc
    if rstn = '0' then                  -- asynchronous reset (active low)
      
    elsif clk'event and clk = '1' then  -- rising clock edge
      
    end if;
  end process state_transimit_proc;

end architecture arch_adc_i2c_fsm_controller;
