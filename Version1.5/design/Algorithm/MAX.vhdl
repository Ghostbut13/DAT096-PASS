LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MAX IS
  GENERIC ( WORD_LENGHT : integer);
  PORT  (
    reset 	: IN std_logic;
    clk		: IN std_logic;
    DIN1 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN2 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN3 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN4 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    max 	: OUT std_logic_vector (2 downto 0);
	done 	: OUT std_logic
    );
END ENTITY MAX;

ARCHITECTURE ARCH_MAX OF MAX IS

-- Adding thoese variables to help us counting the bits that are printed out
  SIGNAL DIN1_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  SIGNAL DIN2_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  SIGNAL DIN3_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  SIGNAL DIN4_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  SIGNAL done_signal: STD_LOGIC := '0';
  
  SIGNAL max_signal : STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL current_max  : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000"; 
  signal max_finish : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";

  -- number of iteration  = number of inputs -1.
  SIGNAL counter: NATURAL range 0 to 4 := 0;
  constant countermax : integer := WORD_LENGHT;
  
BEGIN

give_max_proc:
 process(clk, reset, counter, DIN1_signal, DIN2_signal, DIN3_signal, DIN4_signal)
	begin
	if reset = '1' then
		max_finish <= "000";
		counter <= 0;
		done_signal <= '0';
	end if;
	if rising_edge(clk) then
		if counter < countermax then
			if DIN1_signal > max_signal then
				max_signal <= DIN1_signal;
				current_max <= "000";
				counter <= counter + 1; 
			elsif DIN2_signal > max_signal then
				max_signal <= DIN2_signal;
				current_max <= "001";
				counter <= counter + 1; 
			elsif DIN3_signal > max_signal then
				max_signal <= DIN3_signal;
				current_max <= "010";
				counter <= counter + 1; 
			elsif DIN4_signal > max_signal then
				max_signal <= DIN4_signal;
				current_max <= "011";
				counter <= counter + 1; 
			end if;
		else 
			counter <= 0;
			max_finish <= current_max;
			done_signal <= '1';
		end if;
	end if;
end process give_max_proc;

 -- Assignement of signals
 DIN1_signal <= DIN1;
 DIN2_signal <= DIN2;
 DIN3_signal <= DIN3;
 DIN4_signal <= DIN4;
 max <= max_finish;
 done <= done_signal;

END ARCH_MAX;
