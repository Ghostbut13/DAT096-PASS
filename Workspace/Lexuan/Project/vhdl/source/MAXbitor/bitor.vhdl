-- Leuxan Tang 2023/04/10

-- sub-block in maxbitor block
-- function: calculate the maximumu value by bit or operations
-- if the or result from the last column is '0', we just or all the bits
-- if the or result from the last column is '1, we filter out those vectors which have '0'

LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY bitor IS
  PORT(
	clk : IN STD_LOGIC;
--	rst_n : IN STD_LOGIC;
	din : IN STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH-1 DOWNTO 0);
	din_last : IN STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH-1 DOWNTO 0);
	dout_bitor : OUT STD_LOGIC;
	dout_last : OUT STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH-1 DOWNTO 0)
	);
END ENTITY bitor;

ARCHITECTURE arch_MAXbitor OF bitor IS

  SUBTYPE function_output IS STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH DOWNTO 0); 
  
  FUNCTION bitor(input : STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH-1 DOWNTO 0); last_column : STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH-1 DOWNTO 0)) RETURN function_output IS 
  
	VARIABLE orresult : STD_LOGIC := '0';
	VARIABLE marked_input : STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH-1 DOWNTO 0) := (OTHERS => '0');
	VARIABLE output : STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH DOWNTO 0) := (OTHERS => '0');
	
  BEGIN
    FOR i IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP 
	    IF last_column(i) = '1' THEN
		  orresult := orresult or input(i);
        END IF;
    END LOOP;
    
    IF 	orresult = '0' THEN 
	  marked_input := last_column;
	ELSE 
	  marked_input := input and last_column;
	END IF;
	
	output := marked_input & orresult;
	RETURN output;
	
  END bitor;
  
BEGIN

bitor_proc:
PROCESS(clk)
BEGIN
	IF FALLING_EDGE(clk) THEN 
	  dout_bitor <= bitor(din ,din_last)(0);
	  dout_last <= bitor(din ,din_last)(xcorr_REGISTER_LENGTH DOWNTO 1);
	END IF;
END PROCESS bitor_proc;

END ARCHITECTURE arch_MAXbitor;