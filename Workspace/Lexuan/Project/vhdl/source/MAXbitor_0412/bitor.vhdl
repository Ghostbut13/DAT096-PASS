-- Leuxan Tang 2023/04/10

-- sub-block in maxbitor block
-- function: calculate the maximumu value by bit or operations
-- if the or result from the last column is '0', we just or all the bits
-- if the or result from the last column is '1, we filter out those vectors which have '0'

LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY bitor IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din : IN xcorrindex;
	dout_index : OUT STD_LOGIC_VECTOR(xcorr_INDEX_WIDTH-1 DOWNTO 0)
	);
END ENTITY bitor;

ARCHITECTURE arch_bitor OF bitor IS

  SUBTYPE column IS STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH-1 DOWNTO 0); 
  
  FUNCTION extract_column(input : xcorrindex; column_index : INTEGER) RETURN column IS 
    VARIABLE return_column : column :=(OTHERS => '0');	
  BEGIN
    FOR row_index IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
	  return_column(row_index) := input(row_index)(column_index);
    END LOOP;	
	RETURN return_column;
  END extract_column;
  
  FUNCTION bitor(input: STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH-1 DOWNTO 0);mark: STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH-1 DOWNTO 0)) RETURN STD_LOGIC IS 
    VARIABLE result: STD_LOGIC := '0';
  BEGIN
    FOR i IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
	  result := (input(i) or result) and mark(i);
	END LOOP;
	RETURN result;
  END bitor;
  
  SIGNAL index_column : INTEGER := 0; 
  SIGNAL bitor_done :STD_LOGIC := '0';
  SIGNAL bitor_start :STD_LOGIC  := '0';
  SIGNAL bitor_output :STD_LOGIC  := '0';
  SIGNAL marked_input : column := (OTHERS => '1');
  SIGNAL current_column : column := (OTHERS => '0');
  SIGNAL output : STD_LOGIC_VECTOR(xcorr_DATA_WIDTH-1 DOWNTO 0) := (OTHERS => '0');

BEGIN

-- At the beginning of the clk
-- output the result from last cycle
-- extract the first column
-- activate the first bitor action
initialize_proc:
PROCESS(clk,rst_n)
BEGIN
  IF FALLING_EDGE(clk) THEN
    dout_index <= output(xcorr_INDEX_WIDTH-1 DOWNTO 0);
    current_column <= extract_column(din,0);
	bitor_start <= '1';
  END IF;
END PROCESS initialize_proc;

increment_proc:
PROCESS(bitor_done)
BEGIN
  IF RISING_EDGE(bitor_done) THEN
    index_column <= index_column + 1;
	current_column <= extract_column(din,index_column);
	IF output(index_column-1) = '1' THEN
	  marked_input <= marked_input and extract_column(din,index_column-1);
	ELSE
	  marked_input <= marked_input;
	END IF;
	bitor_done <= '0';
    bitor_start <= '1';
  END IF;
END PROCESS increment_proc;
	
bitor_proc:
PROCESS(bitor_start)
BEGIN
  IF RISING_EDGE(bitor_start) THEN
   IF index_column < 32 THEN
     output(index_column) <= bitor(current_column,marked_input);
     bitor_done <= '1';
     bitor_start <= '0';
   ELSE 
     bitor_done <= '0'; 
     bitor_done <= '1';  
    END IF;
  END IF;
END PROCESS bitor_proc;
  
END ARCHITECTURE arch_bitor;