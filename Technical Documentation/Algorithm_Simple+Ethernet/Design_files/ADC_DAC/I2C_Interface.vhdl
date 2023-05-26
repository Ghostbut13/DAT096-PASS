-------------------------------------------------------------------------------
-- Title      : I2C_Interface
-- Project    : DAT096
-------------------------------------------------------------------------------
-- File       : adc_i2c_controller.vhdl
-- Author     : Weihan Gao -- -- weihanga@chalmers.se
-- Company    : 
-- Created    : 2023-02-04
-- Last update: 2023-02-18
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- Get the config-value and addr-register from ACFC.vhdl,
-- and push them into ADC board based on I2C protocol in this code\
-- FPGA IS THE MASTER OF I2C
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-02-04  1.0      weihan	Created
-- 2023-02-06  1.2      weihan  connect with ACFC
-- 2023-02-11  2.0      weihan  correct timing
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.i2c_type_package.all;


entity I2C_Interface is
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
end entity I2C_Interface;

architecture arch_I2C_Interface of I2C_Interface is
  -- constant
  constant const_SCL_period : integer := 2000/2;        --STANDARD-MODE:
                                                        --smaller than 100kHZ
                                                        --real : 50khz
  
  constant const_freebus_period : integer := 5000/10; --STANDARD-MODE:
                                                        --over than 4.7us
                                                        --real: 5us 
  
  constant const_SCLfall_to_SDA_rise : integer :=  3000/10; --STANDARD-MODE:
                                                            --Setup time for STOP condition
                                                        --over than 4.7us
                                                        --real: 7us
                                                        --
  constant addr_i2c_slave : std_logic_vector(7 downto 0) := "10010000";
  
  -- count
  signal cnt_clk : integer;
  signal cnt_delay5us : integer;
  -- fsm
  -- type i2c_state_type is (
  --   idle_state,
  --   start_state,
  --   write_i2c_addr_state_0,
  --   write_i2c_addr_state_1,
  --   write_i2c_addr_state_2,
  --   write_i2c_addr_state_3,
  --   write_i2c_addr_state_4,
  --   write_i2c_addr_state_5,
  --   write_i2c_addr_state_6,
  --   write_i2c_addr_state_7,
  --   RECEIVE_ACK_state_0,

  --   write_reg_addr_state_0,
  --   write_reg_addr_state_1,
  --   write_reg_addr_state_2,
  --   write_reg_addr_state_3,
  --   write_reg_addr_state_4,
  --   write_reg_addr_state_5,
  --   write_reg_addr_state_6,
  --   write_reg_addr_state_7,
  --   RECEIVE_ACK_state_1,

  --   write_reg_data_state_0,
  --   write_reg_data_state_1,
  --   write_reg_data_state_2,
  --   write_reg_data_state_3,
  --   write_reg_data_state_4,
  --   write_reg_data_state_5,
  --   write_reg_data_state_6,
  --   write_reg_data_state_7,
  --   RECEIVE_ACK_state_2,

  --   stop_state,
  --   end_state   
  --   );
  signal state : i2c_state_type;
  signal next_state : i2c_state_type;
  
  -- output/inout signals
  signal OUT_BIT : std_logic;
  signal IN_bit : std_logic;
  -- flag reg
  signal flag_sent : std_logic;          -- 
  signal flag_TURN_ON_I2C_T : std_logic;  -- it's the ture start-signal in I2C
  signal flag_TURN_OFF_I2C : std_logic;
  signal flag_TURN_OFF_I2C_after5us : std_logic; --it's the true done-signal
                                                 --back to ACFC
  signal flag_delayT_busbuf_5us : std_logic;
  
  -- clk reg
  signal clk_scl : std_logic;
  -- data reg
  signal data_config : std_logic_vector(7 downto 0);-- := x"91";
  -- addr reg
  signal addr_config : std_logic_vector(7 downto 0);-- := x"72";
  -- reg
  signal start_d1 : std_logic;
  signal start_d2 : std_logic;
  signal stop_d1 : std_logic;
  signal stop_d2 : std_logic;
  signal edge_on : std_logic;
  signal edge_off : std_logic;
    
  --signal local_start : std_logic;
begin  -- architecture arch_adc_i2c_fsm_controller
  
  SCL           <=      clk_scl;
  IN_bit        <=      SDA;
  SDA           <=      OUT_BIT when flag_sent='1' else
                        'Z';
  done          <=      flag_TURN_OFF_I2C_after5us;

  data_config   <=      config_value;
  addr_config   <=      config_addr;
  
  ----------------------------------------
  -- purpose: edge detecting in start signal (input port, from config-fsm-flow)
  edge_detecting_proc : process (clk, rstn) is
  begin  -- process 
    if rstn = '0' then                  -- asynchronous reset (active low)
      start_d1 <= '0';
      start_d2 <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      start_d1 <= start;
      start_d2 <= start_d1;
    end if;
  end process edge_detecting_proc;
  edge_on <= start_d1 and not(start_d2);
  ----------------------------------------
  -- purpose: using the flag_TURN_ON_I2C_T, rather than input port "start", to launch the I2C
  i2claunch_proc : process (clk, rstn) is
  begin  -- process flag_of_Turn_ON_proc
    if rstn = '0' then                  -- asynchronous reset (active low)
      flag_TURN_ON_I2C_T <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if edge_on = '1' then
        flag_TURN_ON_I2C_T <= '1';
      end if;
      if flag_TURN_OFF_I2C = '1' then
        flag_TURN_ON_I2C_T <= '0';
      end if;
    end if;
  end process i2claunch_proc;
  ----------------------------------------
  -- purpose: count to period
  clk_divide_proc: process (clk, rstn) is
  begin  -- process clk_divide
    if rstn = '0' then                  -- asynchronous reset (active low)
      cnt_clk <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if flag_TURN_ON_I2C_T='0' then
        cnt_clk <= 0;
      else      -- flag_TURN_ON = '1'
        if flag_TURN_OFF_I2C='0' then
          if (cnt_clk < const_SCL_period) then
            cnt_clk <= cnt_clk + 1;
          else
            cnt_clk <= 0;
          end if;
        else    -- flag_TURN_OFF_I2C='1'
          if (cnt_clk>const_SCLfall_to_SDA_rise and cnt_clk<const_SCL_period) then 
            cnt_clk <= cnt_clk+1;
          elsif (cnt_clk = const_SCL_period-1) then
            cnt_clk <= 0;
          end if;
        end if;
      end if;
    end if;
  end process clk_divide_proc;
  -- purpose: divide clk based on the cnt
  scl_gen_proc: process (clk, rstn) is
  begin  -- process scl_gen
    if rstn = '0' then                  -- asynchronous reset (active low)
      clk_scl <= '1';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if flag_TURN_ON_I2C_T='0' then
        clk_scl <= '1';
      else      -- flag_TURN_ON_I2C_T='1'
        if flag_TURN_OFF_I2C='0' then
          
          if cnt_clk = const_SCL_period then
            if state/= setup_stop_state then
              clk_scl <= not(clk_scl);
            else
              clk_scl <= '1';
            end if;
          end if;
        else    -- flag_TURN_OFF_I2C='1'
          if cnt_clk = const_SCL_period-1 then
            clk_scl <= '1';
          else
            clk_scl <= clk_scl;
          end if;
        end if;
      end if;
    end if;
  end process scl_gen_proc;

  
  -- purpose: i2c_protocol_fsm
  state_transimit_proc: process (clk, rstn) is
  begin  -- process state_transimit_proc
    if rstn = '0' then                  -- asynchronous reset (active low)
      state <= idle_state;
    elsif clk'event and clk = '1' then  -- rising clock edge
      state <= next_state;
    end if;
  end process state_transimit_proc;

  state_flow_proc: process (state,flag_TURN_ON_I2C_T,clk_scl,cnt_clk,flag_TURN_OFF_I2C) is
  begin  -- process state_flow_proc
   next_state <= idle_state;
    case state is
      when  idle_state =>
        if flag_TURN_ON_I2C_T = '1' and flag_TURN_OFF_I2C='0' then
          next_state <= start_state;
        else
          next_state <= idle_state;
        end if;
      when start_state =>
        if (clk_scl='1' or (clk_scl='0' and cnt_clk < const_SCLfall_to_SDA_rise ))then
          next_state <= start_state;
        else
          next_state <= write_i2c_addr_state_0;
        end if;
      ----------------------------------------
      -- wirte i2c slave addr
      when write_i2c_addr_state_0 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_i2c_addr_state_0;
        else
          next_state <= write_i2c_addr_state_1;
        end if;
      when write_i2c_addr_state_1 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_i2c_addr_state_1;
        else
          next_state <= write_i2c_addr_state_2;
        end if;
      when write_i2c_addr_state_2 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_i2c_addr_state_2;
        else
          next_state <= write_i2c_addr_state_3;
        end if;
      when write_i2c_addr_state_3 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_i2c_addr_state_3;
        else
          next_state <= write_i2c_addr_state_4;
        end if;
      when write_i2c_addr_state_4 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_i2c_addr_state_4;
        else
          next_state <= write_i2c_addr_state_5;
        end if;
      when write_i2c_addr_state_5 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_i2c_addr_state_5;
        else
          next_state <= write_i2c_addr_state_6;
        end if;
      when write_i2c_addr_state_6 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_i2c_addr_state_6;
        else
          next_state <= write_i2c_addr_state_7;
        end if;
      when write_i2c_addr_state_7 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_i2c_addr_state_7;
        else
          next_state <= RECEIVE_ACK_state_0;
        end if;
      when RECEIVE_ACK_state_0 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= RECEIVE_ACK_state_0;
        else
          next_state <= write_reg_addr_state_0;
        end if;
      ----------------------------------------
      -- wirte register addr
      when write_reg_addr_state_0 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_addr_state_0;
        else
          next_state <= write_reg_addr_state_1;
        end if;
      when write_reg_addr_state_1 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_addr_state_1;
        else
          next_state <= write_reg_addr_state_2;
        end if;
      when write_reg_addr_state_2 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_addr_state_2;
        else
          next_state <= write_reg_addr_state_3;
        end if;
      when write_reg_addr_state_3 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_addr_state_3;
        else
          next_state <= write_reg_addr_state_4;
        end if;
      when write_reg_addr_state_4 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_addr_state_4;
        else
          next_state <= write_reg_addr_state_5;
        end if;
      when write_reg_addr_state_5 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_addr_state_5;
        else
          next_state <= write_reg_addr_state_6;
        end if;
      when write_reg_addr_state_6 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_addr_state_6;
        else
          next_state <= write_reg_addr_state_7;
        end if;
      when write_reg_addr_state_7 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_addr_state_7;
        else
          next_state <= RECEIVE_ACK_state_1;
        end if;
      when RECEIVE_ACK_state_1 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= RECEIVE_ACK_state_1;
        else
          next_state <= write_reg_data_state_0;
        end if;
      ----------------------------------------
      -- wirte configeration data in register 
      when write_reg_data_state_0 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_data_state_0;
        else
          next_state <= write_reg_data_state_1;
        end if;
      when write_reg_data_state_1 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_data_state_1;
        else
          next_state <= write_reg_data_state_2;
        end if;
      when write_reg_data_state_2 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_data_state_2;
        else
          next_state <= write_reg_data_state_3;
        end if;
      when write_reg_data_state_3 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_data_state_3;
        else
          next_state <= write_reg_data_state_4;
        end if;
      when write_reg_data_state_4 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_data_state_4;
        else
          next_state <= write_reg_data_state_5;
        end if;
      when write_reg_data_state_5 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_data_state_5;
        else
          next_state <= write_reg_data_state_6;
        end if;
      when write_reg_data_state_6 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_data_state_6;
        else
          next_state <= write_reg_data_state_7;
        end if;
      when write_reg_data_state_7 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= write_reg_data_state_7;
        else
          next_state <= RECEIVE_ACK_state_2;
        end if;
      when RECEIVE_ACK_state_2 =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or clk_scl='1' or (cnt_clk<const_SCLfall_to_SDA_rise and clk_scl='0') then
          next_state <= RECEIVE_ACK_state_2;
        else
          next_state <= setup_stop_state;
        end if;
      -------------------------------------------------------------------------
      -- stop i2c
      when setup_stop_state =>
        if (cnt_clk>const_SCLfall_to_SDA_rise and clk_scl='0') or ( clk_scl='1' and cnt_clk<500 ) then
          next_state <= setup_stop_state;
        else
          next_state <= stop_state;
        end if;
      when stop_state =>
        if clk_scl='0'  then
          next_state <= stop_state;
        else
          next_state <= end_state;
        end if;
      when end_state =>
        next_state <= idle_state;
      when others => null;
    end case;
  end process state_flow_proc;

  
  assignment_proc: process (state,data_config,addr_config) is
  begin  -- process assignment_proc
    
   flag_TURN_OFF_I2C <= '0';
   OUT_BIT   <= '1';
   flag_sent <= '1';
    
    case state is
      when  idle_state =>
        flag_TURN_OFF_I2C <= '0';
        flag_sent <= '1';
        OUT_BIT   <= '1';
      when start_state =>
        flag_sent <= '1';
        OUT_BIT   <= '0';                             --SDA = '1' -> '0', SCL = '1'
      when write_i2c_addr_state_0 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_i2c_slave(7);               --SDA = addr_i2c_slave[7]
      when write_i2c_addr_state_1 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_i2c_slave(6);               --SDA = addr_i2c_slave[6]
      when write_i2c_addr_state_2 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_i2c_slave(5);               --SDA = addr_i2c_slave[5]
      when write_i2c_addr_state_3 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_i2c_slave(4);               --SDA = addr_i2c_slave[4]
      when write_i2c_addr_state_4 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_i2c_slave(3);               --SDA = addr_i2c_slave[3]
      when write_i2c_addr_state_5 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_i2c_slave(2);               --SDA = addr_i2c_slave[2]
      when write_i2c_addr_state_6 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_i2c_slave(1);               --SDA = addr_i2c_slave[1]
      when write_i2c_addr_state_7 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_i2c_slave(0);               --SDA = addr_i2c_slave[0]
      when RECEIVE_ACK_state_0 =>
        flag_sent <= '0';
        OUT_BIT   <= '0';
        
      when write_reg_addr_state_0 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_config(7);               --SDA = addr_config_register[7]
      when write_reg_addr_state_1 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_config(6);               --SDA = addr_config_register[6]
      when write_reg_addr_state_2 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_config(5);               --SDA = addr_config_register[5]
      when write_reg_addr_state_3 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_config(4);               --SDA = addr_config_register[4]
      when write_reg_addr_state_4 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_config(3);               --SDA = addr_config_register[3]
      when write_reg_addr_state_5 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_config(2);               --SDA = addr_config_register[2]
      when write_reg_addr_state_6 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_config(1);               --SDA = addr_config_register[1]
      when write_reg_addr_state_7 =>
        flag_sent <= '1';
        OUT_BIT   <= addr_config(0);               --SDA = addr_config_register[0]
      when RECEIVE_ACK_state_1 =>
        flag_sent <= '0';
        OUT_BIT   <= '0';
        
      when write_reg_data_state_0 =>
        flag_sent <= '1';
        OUT_BIT   <= data_config(7);               --SDA = data_config[7]
      when write_reg_data_state_1 =>
        flag_sent <= '1';
        OUT_BIT   <= data_config(6);               --SDA = data_config[6]
      when write_reg_data_state_2 =>
        flag_sent <= '1';
        OUT_BIT   <= data_config(5);               --SDA = data_config[5]
      when write_reg_data_state_3 =>
        flag_sent <= '1';
        OUT_BIT   <= data_config(4);               --SDA = data_config[4]
      when write_reg_data_state_4 =>
        flag_sent <= '1';
        OUT_BIT   <= data_config(3);               --SDA = data_config[3]
      when write_reg_data_state_5 =>
        flag_sent <= '1';
        OUT_BIT   <= data_config(2);               --SDA = data_config[2]
      when write_reg_data_state_6 =>
        flag_sent <= '1';
        OUT_BIT   <= data_config(1);               --SDA = data_config[1]
      when write_reg_data_state_7 =>
        flag_sent <= '1';
        OUT_BIT   <= data_config(0);               --SDA = data_config[0]
        -- OUT_BIT   <= '0'; --for test only
      when RECEIVE_ACK_state_2 =>
        flag_sent <= '0';
        OUT_BIT   <= '0';

      when setup_stop_state =>
        
        flag_sent <= '1';
        OUT_BIT   <= '0';
        
      when stop_state =>
        flag_TURN_OFF_I2C <= '1';           -- SCL = '1'
        flag_sent <= '1';
        OUT_BIT   <= '0';               --SDA = '0', SCL = '0'
      when end_state =>
        flag_TURN_OFF_I2C <= '1';           -- SCL = '1'
        flag_sent <= '1';
        OUT_BIT   <= '1';               -- SDA = '0' -> '1'

      when others => null;
    end case;
  end process assignment_proc;


  --------------------------------------------------------------------------------
  -- detect the falling edge of off signal, used by generating 5us Tbusbuf
  -- delay the stop signal (from the edge) to 5us
  --------------------------------------------------------------------------------
  -- purpose: edge
  edge_detecting_trunoff_proc: process (clk, rstn) is
  begin  -- process edge_detecting_trunoff_proc
    if rstn = '0' then                  -- asynchronous reset (active low)
      stop_d1 <= '0';
      stop_d2 <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      stop_d2 <= stop_d1;
      stop_d1 <= flag_TURN_OFF_I2C;
    end if;
  end process edge_detecting_trunoff_proc;
  edge_off <= not(stop_d1) and stop_d2;
  
  -- purpose: delayT 5us
  delayT_valid_proc: process (clk, rstn) is
  begin  -- process turn_off_T_proc
    if rstn = '0' then                  -- asynchronous reset (active low)
      flag_delayT_busbuf_5us <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if edge_off='1' then              --when the falling edge coming
        flag_delayT_busbuf_5us <= '1';
      end if;
      if cnt_delay5us > const_freebus_period-1 then --when cnt finished
        flag_delayT_busbuf_5us <= '0';
      end if;
    end if;
  end process delayT_valid_proc;
  -- purpose: generate OFF
  OFF_true_proc: process (clk, rstn) is
  begin  -- process 
    if rstn = '0' then                  -- asynchronous reset (active low)
      cnt_delay5us <= 0;
      flag_TURN_OFF_I2C_after5us <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      if flag_delayT_busbuf_5us='1' then       --when valid 5us
        if cnt_delay5us < const_freebus_period then
          cnt_delay5us <= cnt_delay5us +1;
          flag_TURN_OFF_I2C_after5us <= '0';
        else
          cnt_delay5us <= 0;
          flag_TURN_OFF_I2C_after5us <= '1';
        end if;
      else                            --when 5us finished
        cnt_delay5us <= 0;
        flag_TURN_OFF_I2C_after5us <= '0';
      end if;
    end if;
  end process OFF_true_proc;

  
end architecture arch_I2C_Interface;
