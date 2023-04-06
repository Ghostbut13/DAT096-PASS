-- sort function in complex algorithm
LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY secondpass IS 
	PORT(
	clk: IN STD_LOGIC;
	rst_n : IN STD_LOGIC;

	din1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);	-- three input data from first pass
	din2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);
	din3: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);

	dout_second: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	-- index of the second loudest microphone
	
    dout1: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0); -- two microphones left
	dout2: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0)
	);
END ENTITY secondpass;

ARCHITECTURE arch_secondpass OF secondpass IS 

  TYPE second_sortdata IS ARRAY(0 TO 2) OF STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);
  
  SIGNAL input_array : second_sortdata := (OTHERS => (OTHERS => '0'));
  SIGNAL sorted_array : second_sortdata := (OTHERS => (OTHERS => '0'));
  
  SIGNAL buffer_0: STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0'); -- delay the output by one cycles
  
  FUNCTION bubblesort_secondpass(tobesort: second_sortdata) RETURN second_sortdata IS 
  
    VARIABLE temp : STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);
	VARIABLE i : INTEGER;
	VARIABLE sorted: second_sortdata;
	
  BEGIN
    sorted := tobesort;
    FOR i IN 0 TO 1 LOOP
      IF sorted(i) > sorted(i+1) THEN
		  temp := sorted(i);
	      sorted(i) := sorted(i+1);
		  sorted(i+1) := temp;
	  END IF;
    END LOOP;
    i := i + 1;
    RETURN sorted;
  END bubblesort_secondpass;
  
BEGIN
  input_array(0) <= din1;
  input_array(1) <= din2;
  input_array(2) <= din3;
	
sort_proc:
PROCESS(clk,rst_n)
BEGIN
  IF rst_n = '0' THEN 
  END IF;
  IF FALLING_EDGE(clk) THEN
	sorted_array <= bubblesort_secondpass(input_array);
	buffer_0 <= sorted_array(2)(SIGNAL_WIDTH-14 DOWNTO 0);
  END IF;
END PROCESS sort_proc;
  
  dout_second <= buffer_0;
  dout1 <= sorted_array(0);
  dout2 <= sorted_array(1);
	
 END ARCHITECTURE arch_secondpass;