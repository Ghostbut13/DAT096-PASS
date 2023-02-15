LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY I2S IS
 GENERIC(WORD_LENGHT: NATURAL RANGE 1 TO 128) ;
 PORT  (
		bclk:IN STD_LOGIC ;
		start:IN STD_LOGIC ;
		reset:IN STD_LOGIC ;
		fsync:IN STD_LOGIC ;
		LC_1_out : out std_logic_vector (WORD_LENGHT-1 downto 0);
		LC_2_out : out std_logic_vector (WORD_LENGHT-1 downto 0);
		RC_1_out : out std_logic_vector (WORD_LENGHT-1 downto 0);
		RC_2_out : out std_logic_vector (WORD_LENGHT-1 downto 0));
END ENTITY I2S;

ARCHITECTURE ARCH_I2S OF I2S IS

TYPE state_type IS (idle_state, left_channel_1_state, left_channel_2_state,
right_channel_1_state, right_channel_2_state);

SIGNAL present_state_signal:state_type;
SIGNAL next_state_signal:state_type;

-- Adding thoese variables to help us counting the bits that are printed out
SIGNAL stored_data_1: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
SIGNAL stored_data_2: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
SIGNAL stored_data_3: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
SIGNAL stored_data_4: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);

SIGNAL counter1: NATURAL range 0 to WORD_LENGHT := 0;
SIGNAL counter2: NATURAL range 0 to WORD_LENGHT := 0;
SIGNAL counter3: NATURAL range 0 to WORD_LENGHT := 0;
SIGNAL counter4: NATURAL range 0 to WORD_LENGHT := 0;





BEGIN

-- state changing is determined by bclk 
state_transition_proc:
 PROCESS(bclk, reset)
 BEGIN
 IF (reset = '0') THEN
		present_state_signal <= idle_state;
 END IF;
 IF falling_edge(bclk) THEN
	IF (start = '1') THEN
		present_state_signal <= next_state_signal;
	else 
		present_state_signal <= idle_state;
	END IF;
 END IF;
 END PROCESS state_transition_proc;
 

-- flow of the state machine
state_flow_proc:
 PROCESS(present_state_signal, start, counter1, counter3, fsync)
 BEGIN 
	next_state_signal <= present_state_signal;
	case present_state_signal is
		when idle_state =>
			if (start = '1') and (reset /= '0') then
				if falling_edge(fsync) then
					next_state_signal <= left_channel_1_state;
			 end if;
			end if;
		when left_channel_1_state => 
			 if (counter1 = WORD_LENGHT-1) then
				next_state_signal <= left_channel_2_state;
			 end if;

		when left_channel_2_state =>
			 if rising_edge(fsync) then
				next_state_signal <= right_channel_1_state;
			 end if;
		when right_channel_1_state => 
			 if (counter3 = WORD_LENGHT-1) then
				next_state_signal <= right_channel_2_state;
			end if;
		when right_channel_2_state =>
			if falling_edge(fsync) then
					next_state_signal <= left_channel_1_state;
			end if;
		end case;
end process state_flow_proc;
 
 
 -- Counter process that checks for falling edge of bclk to determine where the state machine is
counter_proc:
 process (bclk)
 begin
	if falling_edge(bclk) then
		if reset = '0' or present_state_signal = idle_state then
			counter1 <= 0;
			counter2 <= 0;
			counter3 <= 0;
			counter4 <= 0;
			
		elsif present_state_signal = left_channel_1_state then
			counter4 <= 0;
			if counter1 < WORD_LENGHT-1 then 
				counter1 <= counter1 + 1;
			else 
				counter1 <= 0;
			end if;
			
		elsif present_state_signal = left_channel_2_state then
			counter1 <= 0;
			if counter2 < WORD_LENGHT-1 then 
				counter2 <= counter2 + 1;
			else 
				counter2 <= 0;
			end if;
			
		elsif present_state_signal = right_channel_1_state then
			counter2 <= 0;
			if counter3 < WORD_LENGHT-1 then 
				counter3 <= counter3 + 1;
			else 
				counter3 <= 0;
			end if;
				
		elsif present_state_signal = right_channel_2_state then
			counter3 <= 0;
			if counter4 < WORD_LENGHT-1 then 
				counter4 <= counter4 + 1;
			else 
				counter4 <= 0;
			end if;
		end if;
	end if;



end process;


END ARCH_I2S;
