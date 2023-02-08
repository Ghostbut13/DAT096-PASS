-------------------------------
-- MAC_gen_min_12_17.vhdl    --
-- multiply/accumulate (MAC) --
-- direct implementation     --
-- using GENERATE            --
-- 12 bit signal             --
-- 12 bit coefficients       --
-- 17 taps                   --
-- mini version              --
-- Sven Knutsson             --
-------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE WORK.MAC_gen_min_12_17_package.ALL;

ENTITY MAC_gen_min_12_17 IS
   GENERIC(SIGNAL_WIDTH:INTEGER:=12;
            COEFF_WIDTH:INTEGER:=12;
            TAPS:INTEGER:=17);
   PORT(resetn:STD_LOGIC;
        start:STD_LOGIC;
        clk:IN STD_LOGIC;
        x:IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
--        y:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+COEFF-1 DOWNTO 0));
        y:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
END MAC_gen_min_12_17;

ARCHITECTURE arch_MAC_gen_min_12_17 OF MAC_gen_min_12_17 IS
 
 SIGNAL x_array_signal:signal_array_type;
--   SIGNAL coeff_array_signal:coeff_array_type;
   SIGNAL y_array_signal:double_signal_array_type;
   SIGNAL old_start_signal:STD_LOGIC;

   COMPONENT  FIR_tap is
      GENERIC(SIGNAL_WIDTH:INTEGER:=12;
              COEFF_WIDTH:INTEGER:=8);
      PORT(x:IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
           x_1:IN STD_LOGIC_VECTOR(SIGNAL_WIDTH+COEFF_WIDTH-1 DOWNTO 0);
           coeff:IN STD_LOGIC_VECTOR(COEFF_WIDTH-1 DOWNTO 0);
           y:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+COEFF_WIDTH-1 DOWNTO 0));
--           y:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+COEFF_WIDTH-1 DOWNTO SIGNAL_WIDTH));
   END COMPONENT FIR_tap;

BEGIN
   G:FOR i IN 0 TO TAPS-2 GENERATE
      FIR_tap_comp_i:
      COMPONENT FIR_tap
         GENERIC MAP(SIGNAL_WIDTH => SIGNAL_WIDTH,
                     COEFF_WIDTH => COEFF_WIDTH)
         PORT MAP(x => x_array_signal(i),
                  x_1 => y_array_signal(i+1),
                  coeff => coeff_array_constant(i), --coeff_array_signal(i),
                  y => y_array_signal(i));
   END GENERATE;

   FIR_tap_comp_taps:
   COMPONENT FIR_tap
      GENERIC MAP(SIGNAL_WIDTH => SIGNAL_WIDTH,
                  COEFF_WIDTH => COEFF_WIDTH)
      PORT MAP(x => x_array_signal(TAPS-1),
               x_1 => (OTHERS=>'0'),
               coeff => coeff_array_constant(TAPS-1), --coeff_array_signal(TAPS-1),
               y => y_array_signal(TAPS-1));

   FIR_process:
   PROCESS(resetn,clk)
   BEGIN
      IF (resetn='0') THEN
         FOR i IN 0 TO x_array_signal'HIGH LOOP
              x_array_signal(i)<=(OTHERS=>'0');
         END LOOP;
--         FOR i IN 0 TO TAPS-1 LOOP
--	    coeff_array_signal(i)<=coeff_array_constant(i);
--         END LOOP;
         old_start_signal <= '0';
      ELSIF RISING_EDGE(clk) THEN
         IF ((start = '1') AND (old_start_signal = '0')) THEN
         old_start_signal<='1';
         ELSIF ((start = '0') AND (old_start_signal = '1')) THEN
--            y <= y_array_signal(0)(SIGNAL_WIDTH+COEFF_WIDTH-1 DOWNTO 0); 
            y <= y_array_signal(0)(SIGNAL_WIDTH+COEFF_WIDTH-1 DOWNTO COEFF_WIDTH);
            FOR i IN x_array_signal'HIGH DOWNTO 1 LOOP
               x_array_signal(i) <= x_array_signal(i-1);
            END LOOP;
            x_array_signal(0) <= x;
            old_start_signal <= '0';
         END IF;
      END IF;
   END PROCESS FIR_process;

END arch_MAC_gen_min_12_17;