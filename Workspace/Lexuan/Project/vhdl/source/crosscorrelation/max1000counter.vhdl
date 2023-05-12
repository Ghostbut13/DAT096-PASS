LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY MAX1000counter IS 
	PORT(
	bclk : IN STD_LOGIC;
	fsync : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din : IN xcorrdata;
	dout : OUT STD_LOGIC_VECTOR(45 DOWNTO 0) -- last 14 bits is the index first 16 is the actual value
	);
END ENTITY MAX1000counter;

ARCHITECTURE arch_MAX1000counter OF MAX1000counter IS

TYPE state_type IS (idle_state, calculating_state, done_state, waiting_state);

SIGNAL present_state_signal:state_type;
SIGNAL next_state_signal:state_type;

signal current_index : integer := 0; -- index in decimal
signal current_MAX : std_logic_vector(31 downto 0) := (others=>'0'); -- the actual number itself
signal final_MAX : std_logic_vector(31 downto 0) := (others=>'0');
signal MAX_INDEX : std_logic_vector(13 downto 0) := (others=>'0'); --index in binary
signal final_MAX_index : std_logic_vector(13 downto 0) := (others=>'0');
signal crosscorrelation : std_logic_vector(31 downto 0) := (others => '0');

 begin   
 
 -- state changing is determined by bclk 
 state_transition_proc:
 PROCESS(bclk, rst_n) --rstn
 BEGIN
 IF (rst_n = '0') THEN
		present_state_signal <= idle_state;
 
 ELSIF rising_edge(bclk) THEN
		present_state_signal <= next_state_signal;
 END IF;
 END PROCESS state_transition_proc;
  
  
 -- flow of the state machine
 state_flow_proc:
  PROCESS(present_state_signal, rst_n, fsync, bclk)
  BEGIN 
	next_state_signal <= present_state_signal;
	case present_state_signal is
		when idle_state =>
			if fsync = '1' then
				next_state_signal <= waiting_state;
			
			elsif fsync = '0' then
				next_state_signal <= calculating_state;
			end if;
		when calculating_state => 
			 if current_index > (280-1) then
				if fsync = '0' then
					next_state_signal <= done_state;
				end if;
			 end if;
		when done_state => 
			if fsync = '1' then
				next_state_signal <= waiting_state;
			end if;
		when waiting_state =>
			if fsync = '0' then
				next_state_signal <= calculating_state;
			end if;
		end case;
	end process;
  
  -- counter process
  counter_proc: 
	process(din, rst_n, bclk, present_state_signal)
	  BEGIN
	  
	  if rising_edge(bclk) then
	  
		if rst_n = '0' or present_state_signal = idle_state then
			current_MAX <= (others=>'0');
			MAX_INDEX <= (others => '0');
			current_index <= 0;
	
		elsif present_state_signal = calculating_state then	
			if current_index < 280 then	
                 crosscorrelation <= din(current_index);	
				if SIGNED(din(current_index)) > SIGNED(current_MAX) then
					current_MAX <= din(current_index);
					MAX_INDEX <= std_logic_vector(to_unsigned(current_index+1, MAX_INDEX'length));
				end if;
			end if;
		current_index <= current_index + 1;
			
		elsif present_state_signal = done_state then
			current_index <= 0;
			final_MAX <= current_MAX;
			final_MAX_index <= MAX_INDEX;
			
		elsif present_state_signal = waiting_state then
			current_index <= 0;
			final_MAX <= current_MAX;
			final_MAX_index <= MAX_INDEX;
		end if;
	  end if;
	END process;

  dout <= final_MAX & final_MAX_index;
  
END arch_MAX1000counter;
