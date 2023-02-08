-------------------------------
-- MAC_ser_min_12_17.vhdl    --
-- multiply/accumulate (MAC) --
-- serial implementation     --
-- 12 bit signal             --
-- 12 bit coefficients       --
-- 17 taps                   --
-- mini version              --
-- Sven Knutsson             --
-------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE WORK.MAC_ser_min_12_17_package.ALL;

ENTITY MAC_ser_min_12_17 IS
   GENERIC(SIGNAL_WIDTH:INTEGER := SIGNAL_WIDTH;
           COEFF_WIDTH:INTEGER := COEFF_WIDTH;
           TAPS:NATURAL := 17);
   PORT(resetn:STD_LOGIC;
        start:STD_LOGIC;
        clk:STD_LOGIC;
        x:IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
--        y:OUT STD_LOGIC_VECTOR(2*SIGNAL_WIDTH-1 DOWNTO 0);
        y:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
        finished:OUT STD_LOGIC);
END MAC_ser_min_12_17;

ARCHITECTURE arch_MAC_ser_min_12_17 OF MAC_ser_min_12_17 IS
 
   SIGNAL x_array_signal:signal_array_type;
--   SIGNAL coeff_array_signal:coeff_array_type;
   SIGNAL count_signal:NATURAL RANGE 0 TO TAPS;
   SIGNAL started_signal:STD_LOGIC;
   SIGNAL test_signal:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
BEGIN
   FIR_proc:
   PROCESS(resetn,clk)
      VARIABLE address_variable:NATURAL RANGE 0 TO TAPS;
      VARIABLE y_variable:SIGNED(SIGNAL_WIDTH+COEFF_WIDTH-1 DOWNTO 0);
   BEGIN
      IF (resetn = '0') THEN
         y_variable := (OTHERS => '0');
         FOR i IN x_array_signal'HIGH DOWNTO 0 LOOP
            x_array_signal(i) <= (OTHERS => '0');
         END LOOP;
--         FOR i IN 0 TO TAPS-1 LOOP
--              coeff_array_signal(i) <= coeff_array_constant(i);
--         END LOOP;
         started_signal <= '0';
         finished <= '0'; 
         y <= (OTHERS => '0');
      ELSIF RISING_EDGE(clk) THEN
         IF (start = '1') THEN
            count_signal <= 0;
            finished <= '0';
            x_array_signal(0) <= x;
            y_variable:=(OTHERS=>'0');
            started_signal<='1';
         ELSIF (count_signal < TAPS AND started_signal='1') THEN
            test_signal <= x_array_signal(count_signal);
            y_variable := y_variable+SIGNED(x_array_signal(count_signal))*
                                  SIGNED(coeff_array_constant(count_signal)); --SIGNED(coeff_array_signal(count_signal));
            IF (count_signal = TAPS-1)THEN
               FOR i IN x_array_signal'HIGH DOWNTO 2 LOOP
                  x_array_signal(i) <= x_array_signal(i-1);
               END LOOP;
               x_array_signal(1) <= x;
--               y <= STD_LOGIC_VECTOR(y_variable(SIGNAL_WIDTH+COEFF_WIDTH-2 DOWNTO 0)&'0');
               y <= STD_LOGIC_VECTOR(y_variable(SIGNAL_WIDTH+COEFF_WIDTH-2 DOWNTO COEFF_WIDTH)&'0');

               finished <= '1';
               started_signal <= '0';
            END IF;
            count_signal <= count_signal + 1;
         END IF;
      END IF;
   END PROCESS FIR_proc;

END arch_MAC_ser_min_12_17;