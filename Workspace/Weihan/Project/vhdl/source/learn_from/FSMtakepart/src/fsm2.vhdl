
----------------------------------------
-- SPI_state.vhdl                     --
-- state version of SPI configuration --
-- of a MicroChip MCP4822 DAC         --
-- Sven Knutsson                      --
----------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE WORK.type_package_fsm2.ALL;

ENTITY fsm2 IS
  PORT (reset          :IN STD_LOGIC;
        clk            :IN STD_LOGIC;
        fsm2_start     :IN STD_LOGIC;
        SPI_clk_enable :IN STD_LOGIC;
        A_B            :IN STD_LOGIC;
        GA             :IN STD_LOGIC;
        
        --DATA_in        :IN STD_LOGIC_VECTOR(11 DOWNTO 0);
        CS             :OUT STD_LOGIC;
        SDI            :OUT STD_LOGIC;        
        state          :OUT state_type_fsm2;
        next_state     :OUT state_type_fsm2;
        
        fsm1_done      :in std_logic;
        fsm1_empty_flag:in std_logic;
        fsm1_s         :in std_logic;
        
        fsm1_load      :out std_logic;
        fsm1_start     :out std_logic
        
        
        );
END fsm2;

ARCHITECTURE arch_fsm2 OF fsm2 IS
  CONSTANT SHDN:STD_LOGIC  := '1';
  
  SIGNAL state_signal      :state_type_fsm2;
  SIGNAL next_state_signal :state_type_fsm2;
  
  signal fsm1_load_signal  :std_logic;
  signal fsm1_start_signal :std_logic;
  

BEGIN
  state      <= state_signal;
  next_state <= next_state_signal;
  
  fsm1_load  <= fsm1_load_signal;
  fsm1_start <= fsm1_start_signal;
  

  state_transition_proc:
  PROCESS(reset,clk)
  BEGIN
    
    IF rising_edge(clk) THEN
      IF (reset = '1') THEN
        state_signal <= idle_state;
      ELSIF (SPI_clk_enable = '1') THEN
        state_signal <= next_state_signal;
      ELSE
        state_signal <= state_signal;
      END IF;
    END IF;
  END PROCESS state_transition_proc;

  state_flow_proc:
  PROCESS(state_signal,fsm2_start,fsm1_done)
  BEGIN     
    CASE state_signal IS
      WHEN idle_state => 
        IF (fsm2_start = '1') THEN
          next_state_signal <= start_state;
        ELSE
          next_state_signal <= idle_state;
        END IF;
      WHEN start_state =>
        next_state_signal <= A_B_state;
      WHEN A_B_state =>
        next_state_signal <= zero_state;
      WHEN zero_state =>
        next_state_signal <= GA_state;
      WHEN GA_state =>
        next_state_signal <= SHDN_state;
      WHEN SHDN_state =>
        next_state_signal <= fsm2_data_state;
      WHEN fsm2_data_state =>
        if (fsm1_done = '1') then
          --if (fsm1_empty_flag = '1') then
          next_state_signal <= end_state;
        else
          next_state_signal <= fsm2_data_state;
        end if;
      WHEN end_state =>
        next_state_signal <= idle_state;
    END CASE;
  END PROCESS state_flow_proc;
  
  assignment_proc:
  PROCESS(state_signal,A_B,GA,fsm1_s)
  BEGIN
    SDI <= '0';
    CS <= '1';
    CASE state_signal IS
      WHEN idle_state =>
        SDI <= '0';
        fsm1_load_signal <= '0';
        fsm1_start_signal <= '0';
      WHEN start_state =>
        SDI <= '0';
        fsm1_load_signal <= '1';
        fsm1_start_signal <= '0';
      WHEN A_B_state =>
        CS <= '0';
        SDI <= A_B;
        fsm1_load_signal <= '0';
        fsm1_start_signal <= '0';
      WHEN zero_state =>
        CS <= '0';
        SDI <= '0';
        fsm1_load_signal <= '0';
        fsm1_start_signal <= '0';
      WHEN GA_state =>
        CS <= '0';
        SDI <= GA;
        fsm1_load_signal <= '0';
        fsm1_start_signal <= '0';
      WHEN SHDN_state =>
        CS <= '0';
        SDI <= SHDN;
        fsm1_load_signal <= '0';
        fsm1_start_signal <= '0';
      WHEN fsm2_data_state =>
        CS <= '0';
        SDI <= fsm1_s;
        fsm1_load_signal <= '0';
        fsm1_start_signal <= '1';        
      WHEN end_state =>
        CS <= '1';
        fsm1_load_signal <= '0'; 
        fsm1_start_signal <= '0';
    END CASE;
  END PROCESS assignment_proc;
  

END architecture arch_fsm2;

