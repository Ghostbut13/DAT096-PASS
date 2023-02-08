----------------------------------------
-- SPI_state_tb3.vhdl                 --
-- Test bench to simulate a           --
-- state version of SPI configuration --
-- of a MicroChip MCP4822 DAC         --
-- Sven Knutsson                      --
----------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE WORK.type_package.ALL;

ENTITY SPI_state_tb3 IS
   CONSTANT SIGNAL_WIDTH:INTEGER := 4;
END SPI_state_tb3;

ARCHITECTURE arch_SPI_state_tb3 OF
                         SPI_state_tb3 IS

   COMPONENT SPI_state IS
   PORT (reset:IN STD_LOGIC;
         clk:IN STD_LOGIC;
         start:IN STD_LOGIC;
         SPI_clk_enable:IN STD_LOGIC;
         A_B:IN STD_LOGIC;
         GA:IN STD_LOGIC;
         DATA_in:IN STD_LOGIC_VECTOR(11 DOWNTO 0);
         state:OUT state_type;
         next_state:OUT state_type;
         CS:OUT STD_LOGIC;
         SDI:OUT STD_LOGIC);
   END COMPONENT SPI_state;

   SIGNAL reset_tb3_signal:STD_LOGIC;
   SIGNAL clk_tb3_signal:STD_LOGIC := '1';
   SIGNAL start_tb3_signal:STD_LOGIC;
   SIGNAL SPI_clk_enable_tb3_signal:STD_LOGIC := '1';
   SIGNAL A_B_tb3_signal:STD_LOGIC;
   SIGNAL GA_tb3_signal:STD_LOGIC;
   SIGNAL D_tb3_signal:STD_LOGIC_VECTOR(11 DOWNTO 0);
   SIGNAL CS_tb3_signal:STD_LOGIC;
   SIGNAL SDI_tb3_signal:STD_LOGIC;
   SIGNAL state_tb3_signal:state_type;
   SIGNAL next_state_tb3_signal:state_type;
   
BEGIN

   SPI_state_tb_comp:
   COMPONENT SPI_state
      PORT MAP(reset => reset_tb3_signal,
               clk => clk_tb3_signal,
               start => start_tb3_signal,
               SPI_clk_enable => SPI_clk_enable_tb3_signal,
               A_B => A_B_tb3_signal,
               GA => GA_tb3_signal,
               DATA_in => D_tb3_signal,
               state => state_tb3_signal,
	       --next_state => next_state_tb3_signal,
               CS => CS_tb3_signal,
               SDI => SDI_tb3_signal);

   A_B_tb3_signal <= '0';
   GA_tb3_signal <= '0';
   D_tb3_signal <= "110100110001";
   
   clk_tb3_proc:
   PROCESS
   BEGIN
      WAIT FOR 5 ns;
      clk_tb3_signal <= NOT(clk_tb3_signal);
   END PROCESS clk_tb3_proc;
   
   SPI_clk_enable_tb3_proc:
   PROCESS
   BEGIN
      SPI_clk_enable_tb3_signal <= '1';
      WAIT FOR 10 ns;
      SPI_clk_enable_tb3_signal <= '0';
      WAIT FOR 490 ns;
   END PROCESS SPI_clk_enable_tb3_proc; 

   reset_tb3_signal <= '0',
                       '1' AFTER 123 ns,
                       '0' AFTER 333 ns;

   start_tb3_signal <= '0',
                        '1' AFTER 423 ns,
                        '0' AFTER 623 ns;

   test_proc:
   PROCESS
   BEGIN
      WAIT FOR 200 ns; --200 ns
      ASSERT (state_tb3_signal = idle_state)
      REPORT "Not in idle_state"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '1')
      REPORT "CS is not high"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --700 ns
      ASSERT (state_tb3_signal = start_state)
      REPORT "Not in start_state"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '1')
      REPORT "CS is not high"
      SEVERITY ERROR;
      WAIT FOR 500 ns; --1200 ns
      ASSERT (state_tb3_signal = A_B_state)
      REPORT "Not in A_B_state"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --1700 ns
      ASSERT (state_tb3_signal = zero_state)
      REPORT "Not in zero_state"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --2200 ns
      ASSERT (state_tb3_signal = GA_state)
      REPORT "Not in GA_state"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --2700 ns
      ASSERT (state_tb3_signal = SHDN_state)
      REPORT "Not in SHDN_state"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --3200 ns
      ASSERT (state_tb3_signal = data_state_11)
      REPORT "Not in data_state_11"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(11))
      REPORT "Not D(11)"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;
      
      WAIT FOR 500 ns; --3700 ns
      ASSERT (state_tb3_signal = data_state_10)
      REPORT "Not in data_state_10"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(10))
      REPORT "Not D(10)"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;
      
      WAIT FOR 500 ns; --4200 ns
      ASSERT (state_tb3_signal = data_state_9)
      REPORT "Not in data_state_9"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(9))
      REPORT "Not D(9)"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --4700 ns
      ASSERT (state_tb3_signal = data_state_8)
      REPORT "Not in data_state_8"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(8))
      REPORT "Not D(8)"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --5200 ns
      ASSERT (state_tb3_signal = data_state_7)
      REPORT "Not in data_state_7"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(7))
      REPORT "Not D(7)"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --5700 ns
      ASSERT (state_tb3_signal = data_state_6)
      REPORT "Not in data_state:6"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(6))
      REPORT "Not D(6)"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --6200 ns
      ASSERT (state_tb3_signal = data_state_5)
      REPORT "Not in data_state_5"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(5))
      REPORT "Not D(5)"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --6700 ns
      ASSERT (state_tb3_signal = data_state_4)
      REPORT "Not in data_state_4"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(4))
      REPORT "Not D(4)"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --7200 ns
      ASSERT (state_tb3_signal = data_state_3)
      REPORT "Not in data_state_3"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(3))
      REPORT "Not D(3)"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --7700 ns
      ASSERT (state_tb3_signal = data_state_2)
      REPORT "Not in data_state_2"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(2))
      REPORT "Not D(2)"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --8200 ns
      ASSERT (state_tb3_signal = data_state_1)
      REPORT "Not in data_state_1"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(1))
      REPORT "Not D(1)"
      SEVERITY ERROR;
      ASSERT (CS_tb3_signal = '0')
      REPORT "CS is not low"
      SEVERITY ERROR;

      WAIT FOR 500 ns; --8700 ns
      ASSERT (state_tb3_signal = data_state_0)
      REPORT "Not in data_state_0"
      SEVERITY ERROR;
      ASSERT (SDI_tb3_signal = D_tb3_signal(0))
      REPORT "Not D(0)"
      SEVERITY ERROR;
      
      WAIT FOR 500 ns; --9200 ns
      ASSERT (state_tb3_signal = end_state)
      REPORT "Not in end_state"
      SEVERITY ERROR;
            
      WAIT FOR 500 ns; --9700 ns

   END PROCESS test_proc;

END arch_SPI_state_tb3;
