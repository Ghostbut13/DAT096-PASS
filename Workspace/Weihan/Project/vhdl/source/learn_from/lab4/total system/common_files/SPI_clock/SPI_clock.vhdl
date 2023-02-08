---------------------------------------------------
-- SPI_clock.VHDL                                --
-- generation of SPI clcok signal and            --
-- SPI clock enable signal                       --
-- from system clock and requested SPI clock     --
-- the clock frequencies are given in kilo Hertz --
-- Sven Knutsson                                 --
---------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY SPI_clock is
   GENERIC(system_clk:POSITIVE := 100000; -- for hardware
           spi_clk:POSITIVE := 2000);     -- for hardware
--   GENERIC(system_clk:POSITIVE := 1000;   -- for simulation
--           spi_clk:POSITIVE := 100);      -- for simulation
   PORT(resetn:IN STD_LOGIC;
        clk:IN STD_LOGIC;
        SCLK:OUT STD_LOGIC;
        SCLK_enable:OUT STD_LOGIC);
END SPI_clock;

ARCHITECTURE arch_SPI_clock OF SPI_clock IS
CONSTANT PERIOD_constant:INTEGER := system_clk/spi_clk;
SIGNAL serial_count:INTEGER RANGE 0 TO PERIOD_constant;
SIGNAL SCLK_signal:STD_LOGIC;

BEGIN
   serialclock:
   PROCESS(resetn,clk)
   BEGIN
      IF (resetn= '0' ) THEN
         serial_count <= 0;
         SCLK_enable <= '0';
         SCLK_signal <= '0';
      ELSIF RISING_EDGE(clk) THEN
         IF (serial_count = 0) THEN
            SCLK_enable <= '1';
            SCLK_signal <= '0';
         ELSIF (serial_count = PERIOD_constant/2) THEN
            SCLK_enable <= '0';
            SCLK_signal <= '1';
         ELSE
            SCLK_enable <= '0';
         END IF;
         serial_count <= serial_count + 1;
         IF (serial_count = PERIOD_constant - 1) THEN
            serial_count <= 0;
         END IF;
      END IF;
   END PROCESS serialclock;
   
   SCLK <= SCLK_signal;
   
END arch_SPI_clock;
