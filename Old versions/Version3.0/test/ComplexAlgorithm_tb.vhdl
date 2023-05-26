library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;
USE work.parameter.ALL;


-- entity declaration
entity ca_tb is
 --CONSTANT yourmoma : NATURAL := 22;
end entity ca_tb;

-- architecture start
architecture arch_ca_tb of ca_tb is


  -- component declaration
  component complex is
  PORT(
  clk_sysclk : IN STD_LOGIC; --system clk 
  clk_fsync : IN STD_LOGIC; --fsync
  rst_n : IN STD_LOGIC;
  LC1 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  LC2 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  RC1 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  RC2 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  dout_x : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
  dout_y : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  dout : OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0)
  );
  end component;

  -- constant and type declarations, for example
  constant WL : positive := 16;

  -- adder wordlength
  constant CYCLES : positive := 370536;
  -- number of test vectors to load word_array
  type word_array is array (0 to CYCLES) of std_logic_vector(WL-1 downto 0);
  -- type used to store WL-bit test vectors for CYCLES cycles. array[0-999] every element is 16-bit
  
  file Ylog       : text open write_mode is "C:\Users\ammar\Desktop\ModelSim\DAT096\ComplexAlgorithm\Ylog.log";
  file outputLOG  : text open write_mode is "C:\Users\ammar\Desktop\ModelSim\DAT096\ComplexAlgorithm\outputLOG.log";



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
  signal clk_sysclk_tb_signal  : std_logic := '0';
  signal clk_fsync_tb_signal  : std_logic := '0';
  signal rstn_tb 		: std_logic := '1';
  signal LC1_tb			: std_logic_vector(16 downto 1);  
  signal LC2_tb			: std_logic_vector(16 downto 1);  
  signal RC1_tb			: std_logic_vector(16 downto 1);  
  signal RC2_tb			: std_logic_vector(16 downto 1);  
  signal dout_x_tb			: std_logic_vector(6 downto 0);  
  signal dout_y_tb			: std_logic_vector(5 downto 0);  
  signal dout_tb		: std_logic_vector(16 downto 1);  
 
  
  signal LC1_array        : word_array;
  signal LC2_array        : word_array;
  signal RC1_array        : word_array;
  signal RC2_array        : word_array;
 
  signal Expected_array : word_array;
  constant clock_period : time := 0.48 ns;
  constant fsync_period : time := 1 us;

 begin -- start architecture

 clk_proc : process
  begin
    wait for (clock_period/2);
    clk_sysclk_tb_signal <= not(clk_sysclk_tb_signal);
  end process;
  
   fsync_clk_proc : process
  begin
    wait for (fsync_period/2);
    clk_fsync_tb_signal <= not(clk_fsync_tb_signal);
  end process;
    
  ca_inst:
    component complex
      port map(
	  clk_sysclk => clk_sysclk_tb_signal, 
	  clk_fsync => clk_fsync_tb_signal,
	  rst_n => rstn_tb,
	  LC1 => LC1_tb,
	  LC2 => LC2_tb,
	  RC1 => RC1_tb,
	  RC2 => RC2_tb,
	  dout_x => dout_x_tb,
	  dout_y => dout_y_tb,
	  dout => dout_tb
      );

  -- read input values
  LC1_array        <= load_words(string'("C:\Users\ammar\Desktop\ModelSim\DAT096\ComplexAlgorithm\simMic_1.txt"));
  LC2_array        <= load_words(string'("C:\Users\ammar\Desktop\ModelSim\DAT096\ComplexAlgorithm\simMic_2.txt"));
  RC1_array		   <= load_words(string'("C:\Users\ammar\Desktop\ModelSim\DAT096\ComplexAlgorithm\simMic_3.txt"));
  RC2_array 	   <= load_words(string'("C:\Users\ammar\Desktop\ModelSim\DAT096\ComplexAlgorithm\simMic_4.txt"));

  rstn_tb <= 	'1' after 0 us,
				'0' after 3 us,
				'1' after 13 us;

  verification_process : process        -- maybe add the loops inside here!
    variable index : natural := 0;
    variable L     : line;
    variable n     : natural := 1;
  begin
  

    wait for fsync_period/4;
	  LC1_tb <= LC1_array(0);
	  LC2_tb <= LC2_array(0);
	  RC1_tb <= RC1_array(0);
	  RC2_tb <= RC2_array(0);
    wait for fsync_period;
	
    write_output : while n < CYCLES loop
	  LC1_tb <= LC1_array(n);
	  LC2_tb <= LC2_array(n);
	  RC1_tb <= RC1_array(n);
	  RC2_tb <= RC2_array(n);

	  wait for fsync_period/2;
	  write(L, dout_y_tb);
	  writeline(Ylog, L);

	  --assert(INDEX_OUT_tb = "010")
		--report("note") 
			--severity note;
	  wait for fsync_period/2;
	  n := n+1;
  end loop write_output;

  assert(false) report "Done" severity failure;

end process verification_process;
end architecture;
