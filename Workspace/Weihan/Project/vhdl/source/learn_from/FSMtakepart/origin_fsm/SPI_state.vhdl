----------------------------------------
-- SPI_state.vhdl                     --
-- state version of SPI configuration --
-- of a MicroChip MCP4822 DAC         --
-- Sven Knutsson                      --
----------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE WORK.type_package.ALL;

ENTITY SPI_state IS
   PORT (reset:IN STD_LOGIC;
         clk:IN STD_LOGIC;
         start:IN STD_LOGIC;
         SPI_clk_enable:IN STD_LOGIC;
         A_B:IN STD_LOGIC;
         GA:IN STD_LOGIC;
         DATA_in:IN STD_LOGIC_VECTOR(11 DOWNTO 0);
         CS:OUT STD_LOGIC;
         SDI:OUT STD_LOGIC;
	 state:OUT state_type;
	 next_state:OUT state_type);
END SPI_state;

ARCHITECTURE arch_SPI_state OF SPI_state IS
   CONSTANT SHDN:STD_LOGIC := '1';
   SIGNAL state_signal:state_type;
   SIGNAL next_state_signal:state_type;

BEGIN
   state <= state_signal;
   next_state <= next_state_signal;

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
   PROCESS(state_signal,start)
   BEGIN     
      CASE state_signal IS
         WHEN idle_state => 
            IF (start = '1') THEN
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
	           --next_state_signal <= data_state_0;
         WHEN SHDN_state =>
            next_state_signal <= data_state_11;
         WHEN data_state_11 =>
            next_state_signal <= data_state_10;
         WHEN data_state_10 =>
            next_state_signal <= data_state_9;
         WHEN data_state_9 =>
            next_state_signal <= data_state_8;
         WHEN data_state_8 =>
            next_state_signal <= data_state_7;
         WHEN data_state_7 =>
            next_state_signal <= data_state_6;
         WHEN data_state_6 =>
            next_state_signal <= data_state_5;
         WHEN data_state_5 =>
            next_state_signal <= data_state_4;
         WHEN data_state_4 =>
            next_state_signal <= data_state_3;
         WHEN data_state_3 =>
            next_state_signal <= data_state_2;
         WHEN data_state_2 =>
            next_state_signal <= data_state_1;
         WHEN data_state_1 =>
            next_state_signal <= data_state_0;
         WHEN data_state_0 =>
            next_state_signal <= end_state;
         WHEN end_state =>
            next_state_signal <= idle_state;
      END CASE;
   END PROCESS state_flow_proc;
      
   assignment_proc:
   PROCESS(state_signal,DATA_in,A_B,GA)
   BEGIN
      SDI <= '0';
      CS <= '1';
      CASE state_signal IS
         WHEN idle_state =>
            SDI <= '0';
         WHEN start_state =>
            SDI <= '0';
         WHEN A_B_state =>
            CS <= '0';
            --CS <= '1';
            SDI <= A_B;
         WHEN zero_state =>
            CS <= '0';
            SDI <= '0';
         WHEN GA_state =>
            CS <= '0';
            SDI <= GA;
         WHEN SHDN_state =>
            CS <= '0';
            SDI <= SHDN;
         WHEN data_state_11 =>
            CS <= '0';
            SDI <= DATA_in(11);
         WHEN data_state_10 =>
            CS <= '0';
            SDI <= DATA_in(10);
         WHEN data_state_9 =>
            CS <= '0';
            SDI <= DATA_in(9);
         WHEN data_state_8 =>
            CS <= '0';
            SDI <= DATA_in(8);
         WHEN data_state_7 =>
            CS <= '0';
            SDI <= DATA_in(7);
         WHEN data_state_6 =>
            CS <= '0';
            SDI <= DATA_in(6);
         WHEN data_state_5 =>
            CS <= '0';
            SDI <= DATA_in(5);
         WHEN data_state_4 =>
            CS <= '0';
            SDI <= DATA_in(4);
         WHEN data_state_3 =>
            CS <= '0';
            SDI <= DATA_in(3);
         WHEN data_state_2 =>
            CS <= '0';
            SDI <= DATA_in(2);
         WHEN data_state_1 =>
            CS <= '0';
            SDI <= DATA_in(1);
         WHEN data_state_0 =>
            CS <= '0';
            SDI <= DATA_in(0);
         WHEN end_state =>
            CS <= '1';
      END CASE;
   END PROCESS assignment_proc;
   

END arch_SPI_state;
