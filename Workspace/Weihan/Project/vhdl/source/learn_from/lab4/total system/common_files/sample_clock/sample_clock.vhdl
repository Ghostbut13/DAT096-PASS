---------------------------------------------------
-- sample_clock.vhdl                             --
-- generation of sample clock_enable signal      --
-- from system clock and requested sample clock  --
-- the clock frequencies are given in kilo Hertz --
-- Sven Knutsson                                 --
---------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sample_clock is
    GENERIC(system_clk:POSITIVE := 100000;
            sample_clk:POSITIVE := 40);
     PORT(resetn:IN STD_LOGIC;
     clk:IN STD_LOGIC;
         sample_en:OUT STD_LOGIC);
END sample_clock;

ARCHITECTURE arch_sample_clock OF sample_clock IS
CONSTANT PERIOD_constant:INTEGER:=system_clk/sample_clk;
--Short period for simulation
--CONSTANT PERIOD_constant:INTEGER := 10;
SIGNAL sample_count_signal:INTEGER RANGE 0 TO PERIOD_constant;
ATTRIBUTE X_INTERFACE_INFO : STRING;
ATTRIBUTE X_INTERFACE_INFO of sample_en: SIGNAL is "xilinx.com:signal:interrupt:1.0 sample_en INTERRUPT";
ATTRIBUTE X_INTERFACE_PARAMETER : STRING;
ATTRIBUTE X_INTERFACE_PARAMETER of sample_en: SIGNAL is "SENSITIVITY EDGE_RISING";

BEGIN
   sample_clock:
   PROCESS(resetn,clk)
   BEGIN
      IF (resetn = '0') THEN
         sample_count_signal <= 0;
         sample_en <= '0';
      ELSIF RISING_EDGE(clk) THEN
         IF (sample_count_signal = 0) THEN
            sample_en <= '1';
         ELSE
            sample_en <= '0';
         END IF;
         sample_count_signal <= sample_count_signal + 1;         
         IF (sample_count_signal = PERIOD_constant-1) THEN
            sample_count_signal <= 0;
         END IF;
      END IF;
   END PROCESS sample_clock;
END arch_sample_clock;
