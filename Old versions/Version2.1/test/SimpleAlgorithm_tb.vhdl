library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;
USE work.parameter.ALL;


-- entity declaration
entity sa_tb is
 --CONSTANT yourmoma : NATURAL := 22;
end entity sa_tb;

-- architecture start
architecture arch_sa_tb of sa_tb is


  -- component declaration
  component SimpleAlgorithm is
  port(LC1 : in std_logic_vector(16 downto 1);
	   LC2 : in std_logic_vector(16 downto 1);
	   RC1 : in std_logic_vector(16 downto 1);
	   RC2 : in std_logic_vector(16 downto 1);
	   clk : in std_logic;
	   rstn : in std_logic;
	   OUTPUT : out std_logic_vector(16 downto 1);
	   INDEX_OUT : out std_logic_vector(2 downto 0 );
	   PA_INDEXER_OUT : out std_logic_vector(16 downto 1) ;
	   FADER_OUT1 : out std_logic_vector(16 downto 1);
	   FADER_OUT2 : out std_logic_vector(16 downto 1);
	   FADER_OUT3 : out std_logic_vector(16 downto 1);
	   FADER_OUT4 : out std_logic_vector(16 downto 1)
      );
  end component;

  -- constant and type declarations, for example
  constant WL : positive := 16;

  -- adder wordlength
  constant CYCLES : positive := 1255334; --1255334 --100000
  -- number of test vectors to load word_array
  type word_array is array (0 to CYCLES) of std_logic_vector(WL-1 downto 0);
  -- type used to store WL-bit test vectors for CYCLES cycles. array[0-999] every element is 16-bit
  file MAXindexLOG     : text open write_mode is "C:\Users\ammar\Documents\GitHub\DAT096-PASS\Workspace\Ammar\Project\vhdl\source\SimpleAlgorithm\MAXindexLOG.log";
  file PALOG     	   : text open write_mode is "C:\Users\ammar\Documents\GitHub\DAT096-PASS\Workspace\Ammar\Project\vhdl\source\SimpleAlgorithm\PALOG.log";
  file outputLOG       : text open write_mode is "C:\Users\ammar\Documents\GitHub\DAT096-PASS\Workspace\Ammar\Project\vhdl\source\SimpleAlgorithm\outputLOG.log";
  --file errorLOG        : text open write_mode is "C:\Users\ammar\Documents\GitHub\DAT096-PASS\Workspace\Ammar\Project\vhdl\source\SimpleAlgorithm\errorLOG.log";
  file faderLOG        : text open write_mode is "C:\Users\ammar\Documents\GitHub\DAT096-PASS\Workspace\Ammar\Project\vhdl\source\SimpleAlgorithm\faderLOG.log";



  -- file to which you can write information

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
  signal clk_tb_signal  : std_logic := '0';
  signal rstn_tb 		: std_logic := '1';
  signal LC1_tb			: std_logic_vector(16 downto 1);  
  signal LC2_tb			: std_logic_vector(16 downto 1);  
  signal RC1_tb			: std_logic_vector(16 downto 1);  
  signal RC2_tb			: std_logic_vector(16 downto 1);  
  signal OUTPUT_tb 		: std_logic_vector(16 downto 1);
  signal INDEX_OUT_tb 	: std_logic_vector(3 downto 1);
  signal PA_INDEXER_tb  : std_logic_vector(16 downto 1);   
  signal FADER_OUT1_tb	: std_logic_vector(16 downto 1);
  signal FADER_OUT2_tb	: std_logic_vector(16 downto 1);
  signal FADER_OUT3_tb	: std_logic_vector(16 downto 1);
  signal FADER_OUT4_tb	: std_logic_vector(16 downto 1);
  
  signal LC1_array        : word_array;
  signal LC2_array        : word_array;
  signal RC1_array        : word_array;
  signal RC2_array        : word_array;
 
  signal Expected_array : word_array;
  constant clock_period : time := 10 us;

 begin -- start architecture

 clk_proc : process
  begin
    wait for (clock_period/2);
    clk_tb_signal <= not(clk_tb_signal);

  end process;
    
  SA_inst:
    component SimpleAlgorithm
      port map(
	   LC1 => LC1_tb,
	   LC2 => LC2_tb,
	   RC1 => RC1_tb,
	   RC2 => RC2_tb,
	   clk => clk_tb_signal,
	   rstn => rstn_tb,
	   OUTPUT => OUTPUT_tb,
	   INDEX_OUT => INDEX_OUT_tb,
	   PA_INDEXER_OUT => PA_INDEXER_tb,
	   FADER_OUT1 => FADER_OUT1_tb,
	   FADER_OUT2 => FADER_OUT2_tb,
	   FADER_OUT3 => FADER_OUT3_tb,
	   FADER_OUT4 => FADER_OUT4_tb
      );

  -- read input values
  LC1_array        <= load_words(string'("C:\Users\ammar\Documents\GitHub\DAT096-PASS\Workspace\Ammar\Project\vhdl\source\SimpleAlgorithm\simMic_1.txt"));
  LC2_array        <= load_words(string'("C:\Users\ammar\Documents\GitHub\DAT096-PASS\Workspace\Ammar\Project\vhdl\source\SimpleAlgorithm\simMic_2.txt"));
  RC1_array		   <= load_words(string'("C:\Users\ammar\Documents\GitHub\DAT096-PASS\Workspace\Ammar\Project\vhdl\source\SimpleAlgorithm\simMic_3.txt"));
  RC2_array 	   <= load_words(string'("C:\Users\ammar\Documents\GitHub\DAT096-PASS\Workspace\Ammar\Project\vhdl\source\SimpleAlgorithm\simMic_4.txt"));

  rstn_tb <= 	'1' after 0 us,
				'0' after 3 us,
				'1' after 13 us;

  verification_process : process        -- maybe add the loops inside here!
    variable index : natural := 0;
    variable L     : line;
    variable n     : natural := 1;
  begin
  

    wait for clock_period/4;
	  LC1_tb <= LC1_array(0);
	  LC2_tb <= LC2_array(0);
	  RC1_tb <= RC1_array(0);
	  RC2_tb <= RC2_array(0);
    wait for clock_period;
	
    write_output : while n < CYCLES loop
	  LC1_tb <= LC1_array(n);
	  LC2_tb <= LC2_array(n);
	  RC1_tb <= RC1_array(n);
	  RC2_tb <= RC2_array(n);

	  wait for clock_period/2;
	  write(L, INDEX_OUT_tb);
	  writeline(MAXINDEXLOg, L);
	  
	  write(L, PA_INDEXER_tb);
	  writeline(PALOG, L);
	  
	  write(L, FADER_OUT1_tb);
	  writeline(faderLOG, L);
	  write(L, FADER_OUT2_tb);
	  writeline(faderLOG, L);
	  write(L, FADER_OUT3_tb);
	  writeline(faderLOG, L);
	  write(L, FADER_OUT4_tb);
	  writeline(faderLOG, L);
	  write(L, string'("-------------------------"));
	  writeline(faderLOG, L);
	  
	  write(L, OUTPUT_tb);    
	  writeline(outputLOG, L);
	  --assert(INDEX_OUT_tb = "010")
		--report("note") 
			--severity note;
	  wait for clock_period/2;
	  n := n+1;
  end loop write_output;

  assert(false) report "Done" severity failure;

end process verification_process;
end architecture;
