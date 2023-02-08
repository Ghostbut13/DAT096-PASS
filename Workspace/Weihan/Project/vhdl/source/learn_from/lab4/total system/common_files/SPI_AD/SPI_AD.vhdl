---------------------------------------------------
-- SPI_AD.vhdl                                   --
-- module for communication with the ADC MCP3202 --
-- from Microchip using SPI protocol             --
-- Sven Knutsson                                 --
---------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SPI_AD is
   GENERIC (SIGNAL_WIDTH:INTEGER:=12);
   PORT(resetn:IN STD_LOGIC;
        clk:IN STD_LOGIC;
        SCLK_enable:IN STD_LOGIC;
        ODD_SIGN:IN STD_LOGIC;
        receive:IN STD_LOGIC;
        CS_AD:OUT STD_LOGIC;
        DIN_AD:OUT STD_LOGIC;
        DOUT_AD:IN STD_LOGIC;
        DATA_valid_AD:OUT STD_LOGIC;
        AD_data:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
END SPI_AD;

ARCHITECTURE arch_SPI_AD OF SPI_AD IS
   CONSTANT start_constant:STD_LOGIC:='1';
   CONSTANT SIGL_DIFF_constant:STD_LOGIC:='1';
   CONSTANT MS_BF_constant:STD_LOGIC:='1';
   CONSTANT NULL_BIT_constant:STD_LOGIC:='1';
   SIGNAL AD_data_signal:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
   SIGNAL CS_signal:STD_LOGIC;

BEGIN
   AD_receive:
   PROCESS(resetn,clk)
   VARIABLE bitcount_variable:INTEGER RANGE 0 TO 20;
   BEGIN
      IF (resetn = '0') THEN
         AD_DATA_signal <= (OTHERS => '0');
         CS_signal <= '1';
         DATA_valid_AD <= '0';
      ELSIF RISING_EDGE(clk) THEN
         IF (CS_signal = '1' AND receive = '1') THEN
            bitcount_variable := 0;
            CS_signal <= '0';
            DATA_valid_AD <= '0';
            DIN_AD <= '1';
         ELSIF (CS_signal = '0' AND SCLK_enable = '1') THEN  
            IF (bitcount_variable = 0) THEN
               AD_data_signal <= (OTHERS => '0');
               DIN_AD <= SIGL_DIFF_constant;
            ELSIF (bitcount_variable = 1) THEN
               DIN_AD <= ODD_SIGN;
            ELSIF (bitcount_variable = 2) THEN
               DIN_AD <= MS_BF_constant;
            ELSIF (bitcount_variable = 3) THEN
               DIN_AD <= NULL_BIT_constant;
            ELSIF (bitcount_variable = 17) THEN
               CS_signal <= '1';
               DATA_valid_AD <= '1';
               AD_data <= AD_data_signal;
            ELSE
               AD_data_signal <= AD_DATA_signal(SIGNAL_WIDTH-2 DOWNTO 0)&DOUT_AD;
            END IF;
            bitcount_variable := bitcount_variable + 1;
         END IF;
      END IF;
   END PROCESS AD_receive;
   CS_AD <= CS_signal;
END arch_SPI_AD;
