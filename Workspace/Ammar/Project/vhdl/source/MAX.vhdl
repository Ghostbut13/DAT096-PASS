LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY BUBBLE_SORT IS
  GENERIC ( WORD_LENGHT : integer := 4);
  PORT  (
    clk		: IN std_logic;
    DIN1 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN2 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN3 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN4 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    max 	: out std_logic_vector (1 downto 0)
    );
END ENTITY BUBBLE_SORT;

ARCHITECTURE ARCH_BUBBLE_SORT OF BUBBLE_SORT IS

-- Adding thoese variables to help us counting the bits that are printed out
  --SIGNAL DIN1_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0) := (OTHERS => '0');
  --SIGNAL DIN2_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0) := (OTHERS => '0');
  --SIGNAL DIN3_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0) := (OTHERS => '0');
  --SIGNAL DIN4_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL DIN1_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0) := "0110";
  SIGNAL DIN2_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0) := "0100";
  SIGNAL DIN3_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0) := "1110";
  SIGNAL DIN4_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0) := "0001";
  SIGNAL max_signal : STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0) := (OTHERS => '0') ;
  SIGNAL max_index : STD_LOGIC_VECTOR (1 DOWNTO 0) := (OTHERS => '0'); 


  SIGNAL temp_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL counter: NATURAL range 0 to 4 := 0;
  constant countermax : integer := 4;
  signal clk_signal : std_logic := '0';
  
BEGIN

DIN1_signal <= DIN1;
DIN2_signal <= DIN2;
DIN3_signal <= DIN3;
DIN4_signal <= DIN4;
max <= max_index;

	
bubble_sort_proc:
 process(clk, counter, DIN1_signal, DIN2_signal, DIN3_signal, DIN4_signal)
	begin
	if rising_edge(clk) then
		if counter < countermax then
			if DIN1_signal > max_signal then
				max_signal <= DIN1_signal;
				max_index <= "00";
				counter <= counter + 1; 
			elsif DIN2_signal > max_signal then
				max_signal <= DIN2_signal;
				max_index <= "01";
				counter <= counter + 1; 
			elsif DIN3_signal > max_signal then
				max_signal <= DIN3_signal;
				max_index <= "10";
				counter <= counter + 1; 
			elsif DIN4_signal > max_signal then
				max_signal <= DIN4_signal;
				max_index <= "11";
				counter <= counter + 1; 
			end if;
		else 
			counter <= 0;
		end if;
	end if;
end process;

END ARCH_BUBBLE_SORT;
