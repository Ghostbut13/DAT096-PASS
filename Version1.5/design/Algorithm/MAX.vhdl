LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


ENTITY MAX IS
  GENERIC ( WORD_LENGHT : natural range 0 to 16 := 16);
  PORT  (
    rstn 	: IN std_logic;
    clk		: IN std_logic;
    DIN1 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN2 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN3 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    DIN4 	: IN std_logic_vector (WORD_LENGHT-1 downto 0);
    max 	: OUT std_logic_vector (2 downto 0)
    );
END ENTITY MAX;

ARCHITECTURE ARCH_MAX OF MAX IS

-- Adding thoese variables to help us counting the bits that are printed out
  SIGNAL DIN1_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  SIGNAL DIN2_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  SIGNAL DIN3_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  SIGNAL DIN4_signal: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  
  type ARRAY16 is array (2 downto 0) of STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  
  SIGNAL max_signal : ARRAY16 := (others => (others => '0'));
  SIGNAL counter_temp: std_logic_vector(3 downto 0) := "0000";
  signal indexer : std_logic_vector (2 downto 0) := "000";
  
BEGIN

give_max_proc:
 process(clk, rstn, DIN1_signal, DIN2_signal, DIN3_signal, DIN4_signal)
	begin
	if rstn = '0' then
		--counter <= "000";
		indexer <= "000";
		counter_temp <= "0000";
	end if;
	
	if FALLING_EDGE(clk) then
		if DIN1_signal > DIN2_signal then
			if DIN1_signal > DIN3_signal then 
				if DIN1_signal > DIN4_signal then
					indexer <= "001";
				end if;
			end if;
		end if;
		
	
		if DIN2_signal > DIN1_signal then
			if DIN2_signal > DIN3_signal then 
				if DIN2_signal > DIN4_signal then
					indexer <= "010";
				end if;
			end if;
		end if;
		
		if DIN3_signal > DIN1_signal then
			if DIN3_signal > DIN2_signal then 
				if DIN3_signal > DIN4_signal then
					indexer <= "011";
				end if;
			end if;
		end if;

		if DIN4_signal > DIN1_signal then
			if DIN4_signal > DIN2_signal then 
				if DIN4_signal > DIN3_signal then
					indexer <= "100";
				end if;
			end if;
		end if;	

	end if;
end process give_max_proc;



 -- Assignement of signals
 DIN1_signal <= DIN1;
 DIN2_signal <= DIN2;
 DIN3_signal <= DIN3;
 DIN4_signal <= DIN4;
 max <= indexer;

END ARCH_MAX;
