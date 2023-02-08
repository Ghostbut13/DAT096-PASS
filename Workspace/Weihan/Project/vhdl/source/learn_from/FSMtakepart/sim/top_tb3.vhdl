----------------------------------------
-- SPI_state_tb3.vhdl                 --
-- Test bench to simulate a           --
-- state version of SPI configuration --
-- of a MicroChip MCP4822 DAC         --
-- Sven Knutsson                      --
----------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
--USE WORK.type_package.ALL;

ENTITY top_tb3 IS
   CONSTANT SIGNAL_WIDTH:INTEGER := 16;
   CONSTANT TESTVEC: STD_LOGIC_VECTOR(SIGNAL_WIDTH downto 1) := "1000101001011011" ;
END top_tb3;

ARCHITECTURE arch_top_tb3 OF
                         top_tb3 IS

   COMPONENT top IS
   generic (data_width :natural range 1 to 16);
   PORT (reset:IN STD_LOGIC;
         clk:IN STD_LOGIC;
         start:IN STD_LOGIC;
         SPI_clk_enable:IN STD_LOGIC;
         A_B:IN STD_LOGIC;
         GA:IN STD_LOGIC;
         DATA_in:IN STD_LOGIC_VECTOR(data_width DOWNTO 1);
         CS:OUT STD_LOGIC;
         SDI:OUT STD_LOGIC);
   END COMPONENT top;

   SIGNAL reset_tb3_signal:STD_LOGIC;
   SIGNAL clk_tb3_signal:STD_LOGIC := '1';
   SIGNAL start_tb3_signal:STD_LOGIC;
   SIGNAL SPI_clk_enable_tb3_signal:STD_LOGIC := '1';
   SIGNAL A_B_tb3_signal:STD_LOGIC;
   SIGNAL GA_tb3_signal:STD_LOGIC;
   SIGNAL D_tb3_signal:STD_LOGIC_VECTOR(SIGNAL_WIDTH DOWNTO 1);
   SIGNAL CS_tb3_signal:STD_LOGIC;
   SIGNAL SDI_tb3_signal:STD_LOGIC;
   
   
BEGIN
    top_inst_1: top
     generic map (data_width => signal_width)
      PORT MAP(reset => reset_tb3_signal,
               clk => clk_tb3_signal,
               start => start_tb3_signal,
               SPI_clk_enable => SPI_clk_enable_tb3_signal,
               A_B => A_B_tb3_signal,
               GA => GA_tb3_signal,
               DATA_in => D_tb3_signal,
               CS => CS_tb3_signal,
               SDI => SDI_tb3_signal);

   A_B_tb3_signal <= '0';
   GA_tb3_signal <= '0';
   D_tb3_signal <= TESTVEC;
   
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

   

END arch_top_tb3;


