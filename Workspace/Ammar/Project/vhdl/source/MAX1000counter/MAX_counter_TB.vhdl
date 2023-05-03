library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;
USE work.parameter.ALL;


-- entity declaration
entity MAX_counter_TB is
--CONSTANT THE_WL : NATURAL := 16
end entity MAX_counter_TB;

-- architecture start
architecture arch_MAX_counter_TB of MAX_counter_TB is


  -- component declarations, for example
  component MAX1000counter is
	PORT(
	bclk : IN STD_LOGIC;
	fsync : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din : IN xcorrdata;
	dout : OUT STD_LOGIC_VECTOR(29 DOWNTO 0)
	);
  end component MAX1000counter;

  -- constant and type declarations, for example
  constant WL : positive := 16;

  -- adder wordlength
  constant CYCLES : positive := 1000;
  -- number of test vectors to load word_array
  type word_array is array (0 to CYCLES) of std_logic_vector(WL-1 downto 0);
  -- type used to store WL-bit test vectors for CYCLES cycles. array[0-999] every element is 16-bit

 -- functions
  function to_std_logic (char : character) return std_logic is
    variable result : std_logic;
  begin
    case char is
      when '0'    => result := '0';
      when '1'    => result := '1';
      when 'x'    => result := '0';
      when others => assert (false) report "no valid binary character read" severity failure;
    end case;
    return result;
  end to_std_logic;


  function load_words (file_name : string) return word_array is
    file object_file : text open read_mode is file_name;
    variable memory  : word_array;
    variable L       : line;
    variable index   : natural := 0;
    variable char    : character;
  begin
	  while not endfile(object_file) loop
      readline(object_file, L);
      for i in WL-1 downto 0 loop
        read(L, char);
        memory(index)(i) := to_std_logic(char);
      end loop;
      index := index + 1;
    end loop;
    return memory;
  end load_words;


  -- testbench codes
 
  signal clk_tb   : std_logic := '0';
  signal fsync_tb   : std_logic := '0';
  signal reset_tb : std_logic := '1';
  signal dout_tb   : std_logic_vector(29 downto 0) := (others=>'0');
  --type din_tb is array(3 downto 0) of std_logic_vector(15 downto 0) := (DIN1_tb, DIN2_tb, DIN3_tb, DIN4_tb);

  signal A_array        : word_array;
  signal temp_array : xcorrdata  := (others=>(others => '0'));
  constant clock_period : time := 10 ns;
  constant fsync_period : time := 20 ms;

 
 begin -- start architecture



 clk_proc : process
  begin
    wait for (clock_period/2);
    clk_tb <= not(clk_tb);
  end process;
  
  fsync_proc : process
  begin
    wait for (fsync_period/2);
    fsync_tb <= not(fsync_tb);
  end process;
  
  
  MAX1000_inst:
  component MAX1000counter
  port map(
  		bclk => clk_tb,
		fsync => fsync_tb,
		rst_n => reset_tb,
		din => temp_array,
		dout => dout_tb
		);
		
  	reset_tb <= '1' after 0 ns,
				'0' after 70 ns,
				'1' after 87 ns;
		
   -- read input values
   A_array  <= load_words(string'("C:\Users\ammar\Desktop\ModelSim\DAT096\MAX_state_machine\A.txt"));
   
   assign_proc:
    process(reset_tb)
     variable i : integer := 0;
     begin 
	  if (reset_tb = '0') then
		temp_array <= (others=>(others => '0'));
	  else
		FOR i IN 0 TO xcorr_REGISTER_LENGTH-1 LOOP
		 temp_array(i) <= A_array(i);
		END LOOP;
      end if;
	end process;

end architecture;
