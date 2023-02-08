-------------------------------
-- MAC_loop_min_12_17.vhdl   --
-- multiply/accumulate (MAC) --
-- direct implementation     --
-- using FOR...LOOP          --
-- 12 bit signal             --
-- 12 bit coefficients       --
-- 17 taps                   --
-- mini version              --
-- Sven Knutsson             --
-------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE WORK.MAC_loop_min_12_17_package.ALL;

ENTITY MAC_loop_min_12_17 IS
   GENERIC(SIGNAL_WIDTH:INTEGER := SIGNAL_WIDTH;
            COEFF_WIDTH:INTEGER := COEFF_WIDTH;
            TAPS:INTEGER := 17);
   PORT(resetn:STD_LOGIC;
        start:STD_LOGIC;
        clk:IN STD_LOGIC;
        x:IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
--        y:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+COEFF_WIDTH-1 DOWNTO 0));
        y:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
END MAC_loop_min_12_17;

ARCHITECTURE arch_MAC_loop_min_12_17 OF MAC_loop_min_12_17 IS

   SIGNAL x_array_signal:signal_array_type;
--   SIGNAL coeff_array_signal:coeff_array_type;
   SIGNAL old_start_signal:STD_LOGIC;
BEGIN
   FIR_process:
   PROCESS(resetn,clk)
   VARIABLE address_variable:NATURAL RANGE 0 TO TAPS;   
   VARIABLE y_variable:SIGNED(SIGNAL_WIDTH+COEFF_WIDTH-1 DOWNTO 0);
--   VARIABLE old_start_variable:STD_LOGIC;
   BEGIN
      IF (resetn = '0') THEN
         y_variable := (OTHERS=>'0');
         FOR i IN 0 TO x_array_signal'HIGH LOOP
              x_array_signal(i) <= (OTHERS => '0');
         END LOOP;
--         FOR i IN 0 TO TAPS-1 LOOP
--	    coeff_array_signal(i) <= coeff_array_constant(i);
--         END LOOP;
	        old_start_signal <= '0';
      ELSIF RISING_EDGE(clk) THEN
         IF ((start = '1') AND (old_start_signal = '0')) THEN
	        old_start_signal <= '1';
         ELSIF ((start = '0') AND (old_start_signal = '1')) THEN
            y_variable := SIGNED(x)*SIGNED(coeff_array_constant(0));
												FOR i IN 1 TO coeff_array_constant'HIGH LOOP
               y_variable := y_variable + SIGNED(x_array_signal(i-1))*
                                        SIGNED(coeff_array_constant(i));
            END LOOP;
--            y <= STD_LOGIC_VECTOR(y_variable(SIGNAL_WIDTH+COEFF_WIDTH-2 DOWNTO 0)&'0'); 
            y <= STD_LOGIC_VECTOR(y_variable(SIGNAL_WIDTH+COEFF_WIDTH-2 DOWNTO COEFF_WIDTH-1));
            FOR i IN x_array_signal'HIGH DOWNTO 1 LOOP
               x_array_signal(i) <= x_array_signal(i-1);
            END LOOP;
            x_array_signal(0) <= x;
	           old_start_signal <= '0';
         END IF;
      END IF;
   END PROCESS FIR_process;

END arch_MAC_loop_min_12_17;