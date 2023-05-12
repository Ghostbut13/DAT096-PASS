
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.fixed_float_types.all;
--use ieee.fixed_pkg.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;


entity iir_b_tb is
end iir_b_tb;


architecture arc_iir_b_tb of iir_b_tb is

		
		
		constant CYCLES : positive := 1255046; --1255334 --100000
		constant WL : positive := 16;
		constant clock_period : time := 10 us;
		
		type word_array is array (0 to CYCLES) of std_logic_vector(WL-1 downto 0);
		signal filter_in_tb: std_logic_vector(15 downto 0):=(others=>'0');
		signal filter_out_tb: std_logic_vector(15 downto 0):=(others=>'0');
		signal clk: std_logic:='0'; 
		signal rst_n_tb: std_logic:='1';
		signal filter_en_tb: std_logic :='1';
		--constant WL : positive := 16;
		signal LC1_array        : word_array;
		
		component iir_b is
			port(clk:in std_logic;
				filter_en: in std_logic;
				reset_n: in std_logic;
				filter_in: in std_logic_vector(15 downto 0);
				filter_out: out std_logic_vector(15 downto 0));
		end component;

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

	begin
		LC1_array <= load_words(string'("D:\Kami no chikara\Chalmers_study_periods\study_period 4\DAT096\digital_filters\my_filter\simMic_1.txt"));
		
		
			iir_b_inst: component iir_b 
				port map(clk=>clk, filter_en=>filter_en_tb, reset_n=>rst_n_tb, filter_in =>filter_in_tb, filter_out=>filter_out_tb);
			
			clk_proc: process
			begin
				wait for 10 us;
				clk <= not clk;
			end process;
			
		input_proc: process
		variable n     : natural := 1;
		begin
			wait for clock_period/4;
			filter_in_tb <= LC1_array(0);
			wait for clock_period;
			write_output : while n < CYCLES loop
				filter_in_tb <= LC1_array(n);
	 
	  -- wait for clock_period/2;
	  -- write(L, INDEX_OUT_tb);
	  -- writeline(MAXINDEXLOg, L);
	  
	  -- write(L, PA_INDEXER_tb);
	  -- writeline(PALOG, L);
	  
	  -- write(L, FADER_OUT1_tb);
	  -- writeline(faderLOG, L);
	  -- write(L, FADER_OUT2_tb);
	  -- writeline(faderLOG, L);
	  -- write(L, FADER_OUT3_tb);
	  -- writeline(faderLOG, L);
	  -- write(L, FADER_OUT4_tb);
	  -- writeline(faderLOG, L);
	  -- write(L, string'("-------------------------"));
	  -- writeline(faderLOG, L);
	  
	  -- write(L, OUTPUT_tb);    
	  -- writeline(outputLOG, L);
	  --assert(INDEX_OUT_tb = "010")
		--report("note") 
			--severity note;
	  wait for clock_period;
	  n := n+1;
  end loop write_output;
		
		end process input_proc;
			
			
			
end arc_iir_b_tb;
