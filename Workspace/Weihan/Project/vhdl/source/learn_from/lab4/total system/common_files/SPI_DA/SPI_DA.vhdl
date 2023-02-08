---------------------------------------------------
-- SPI_DA.vhdl                                   --
-- module for communication with the DAC MCP4822 --
-- from Microchip using SPI protocol             --
-- Sven Knutsson                                 --
---------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SPI_DA is
    GENERIC(SIGNAL_WIDTH:INTEGER := 12);
    PORT(resetn:IN STD_LOGIC;
         clk:IN STD_LOGIC;
         SCLK_enable:IN STD_LOGIC;
--         LDAC_in:IN STD_LOGIC;
         send:IN STD_LOGIC;
         DA_channel:IN STD_LOGIC;
         DA_gain:IN STD_LOGIC;
         DA_data:IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
         CS_DA:OUT STD_LOGIC;
         SDI_DA:OUT STD_LOGIC;
         LDAC_out:OUT STD_LOGIC;
         DATA_valid_DA:OUT STD_LOGIC);
END SPI_DA;

ARCHITECTURE arch_SPI_DA OF SPI_DA IS
   SIGNAL bitcount_signal:INTEGER;
   SIGNAL DA_data_signal:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
   SIGNAL CS_signal:STD_LOGIC;
   CONSTANT SHDN:STD_LOGIC:='1';
--   SIGNAL DA_data:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);

BEGIN
--   DA_data<="111100000000";
 
   DA_send:
   PROCESS(resetn,clk)
   BEGIN
      IF (resetn = '0') THEN
         SDI_DA <= '0';
         CS_signal <= '1';
         DATA_valid_DA <= '0'; 
      ELSIF RISING_EDGE(clk) THEN
         IF ((CS_signal = '1') AND (send= '1')) THEN
            bitcount_signal <= 0;
            CS_signal <= '0';
            DATA_valid_DA <= '0';
            SDI_DA <= DA_channel;
            DA_data_signal <= DA_DATA;
         ELSIF ((CS_signal= '0') AND (SCLK_enable = '1')) THEN
            IF ((bitcount_signal = 0) OR (bitcount_signal = 1)) THEN
               SDI_DA <= DA_gain;
            ELSIF (bitcount_signal = 2) THEN
               SDI_DA <= SHDN;
            ELSIF (bitcount_signal = 15) THEN
               CS_signal <= '1';
               DATA_valid_DA <= '1';
            ELSE
               SDI_DA <= DA_data_signal(SIGNAL_WIDTH-1);
               DA_data_signal <= DA_data_signal(SIGNAL_WIDTH-2 DOWNTO 0) & '0';
            END IF;
            bitcount_signal <= bitcount_signal + 1;
         END IF;
      END IF;
   END PROCESS DA_send;
--   LDAC_out<=LDAC_in;
   LDAC_out <= '0';
   CS_DA <= CS_signal;
END arch_SPI_DA;
