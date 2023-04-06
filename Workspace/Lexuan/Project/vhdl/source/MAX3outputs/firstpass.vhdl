-- sort function in complex algorithm
LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;

ENTITY firstpass IS 
	PORT(
	clk: IN STD_LOGIC;
	rst_n : IN STD_LOGIC;

	din1: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);	-- four input data from power estimation
	din2: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	din3: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
	din4: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);

	dout_loudest: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);	-- index of the loudest microphone
	
    dout1: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0); -- three microphones left
	dout2: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);
	dout3: OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0)
	);
END ENTITY firstpass;

ARCHITECTURE arch_firstpass OF firstpass IS 

  TYPE first_sortdata IS ARRAY(0 TO 3) OF STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);
  
  SIGNAL input_array : first_sortdata := (OTHERS => (OTHERS => '0'));
  SIGNAL sorted_array : first_sortdata := (OTHERS => (OTHERS => '0'));
  
  SIGNAL buffer_0: STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0'); -- delay the output by two cycles
  SIGNAL buffer_1: STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
  
  FUNCTION bubblesort_firstpass(tobesort: first_sortdata) RETURN first_sortdata IS
  
    VARIABLE temp : STD_LOGIC_VECTOR(SIGNAL_WIDTH+2 DOWNTO 0);
	VARIABLE i : INTEGER;
	VARIABLE sorted: first_sortdata;
	
  BEGIN
    sorted := tobesort;
    FOR i IN 0 TO 2 LOOP
      IF sorted(i) > sorted(i+1) THEN
		  temp := sorted(i);
	      sorted(i) := sorted(i+1);
		  sorted(i+1) := temp;
	  END IF;
    END LOOP;
    i := i + 1;
    RETURN sorted;
  END bubblesort_firstpass;
  
BEGIN
  input_array(0) <= din1 & "001"; -- add the index of microphone to the end of the power vector
  input_array(1) <= din2 & "010";
  input_array(2) <= din3 & "011";
  input_array(3) <= din4 & "100";
	
sort_proc:
PROCESS(clk,rst_n)
BEGIN
  IF rst_n = '0' THEN 
  END IF;
  IF FALLING_EDGE(clk) THEN
	sorted_array <= bubblesort_firstpass(input_array);
	buffer_0 <= sorted_array(3)(SIGNAL_WIDTH-14 DOWNTO 0);
	buffer_1 <= buffer_0;
  END IF;
END PROCESS sort_proc;
  
  dout_loudest <= buffer_1;
  dout1 <= sorted_array(0);
  dout2 <= sorted_array(1);
  dout3 <= sorted_array(2);
	
END ARCHITECTURE arch_firstpass;