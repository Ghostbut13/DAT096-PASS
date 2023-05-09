library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;
LIBRARY work;
USE work.parameter.ALL;

--bclk: 6MHz -> 0,1667x10^(-6) ->166.7 * 10^(-9) ->166 ns
--fsync: 48kHz ->0,0208x10^(-3) -> 20,8x10^(-6) -> 20800ns
ENTITY shiftregister_tb IS
--
END shiftregister_tb;

ARCHITECTURE arch_shiftregister_tb OF shiftregister_tb IS


 COMPONENT shiftregister IS
 PORT(clk_read: IN STD_LOGIC;
     clk_write: IN STD_LOGIC;
     rst_n: IN STD_LOGIC;
     din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
     dout_PE: OUT outputdata;
	 dout_xcorr: OUT outputdata
	 );
  END COMPONENT shiftregister;

  -- constant and type declarations, for example
  constant WL : positive := 16;

  -- adder wordlength
  constant CYCLES : positive := 10000;
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

  SIGNAL din_tb:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  SIGNAL clk_fsync_tb: STD_LOGIC := '0';
  SIGNAL clk_bclk_tb: STD_LOGIC := '0';
  SIGNAL dout_PE_tb:outputdata  := (OTHERS => (OTHERS => '0'));
  SIGNAL dout_xcorr_tb:outputdata  := (OTHERS => (OTHERS => '0'));
  signal A_array        : word_array;



  BEGIN -- start architecture 

	bclk_proc:
	PROCESS
	BEGIN
	  WAIT FOR 5 ns;
	  clk_bclk_tb <= NOT(clk_bclk_tb);
	END PROCESS bclk_proc;

	fsync_proc:
	PROCESS
	BEGIN
	  WAIT FOR 10400 ns;
	  clk_fsync_tb <= NOT(clk_fsync_tb);
	END PROCESS fsync_proc;

   
  
  shiftregister_inst:
  COMPONENT shiftregister
    PORT MAP(clk_read => clk_bclk_tb,
     clk_write => clk_fsync_tb,
     rst_n => '1',
     din => din_tb,
     dout_PE => dout_PE_tb,
	 dout_xcorr => dout_xcorr_tb
	 );
	 
	 -- read input values
     A_array  <= load_words(string'("C:\Users\ammar\Desktop\ModelSim\DAT096\MAX1000\data10000.txt"));


verification_proc:
PROCESS 

  variable n     : natural := 1;
  begin

    wait for 5200 ns;
      din_tb <= A_array(0);
    wait for 20800 ns;
    write_output : while n < CYCLES loop
      din_tb <= A_array(n);
      --assert(1 = 1) report("correct") severity warning;
      wait for 20800 ns;
      n := n+1;
  end loop write_output;

  assert(false) report "Done" severity failure;
end process verification_proc;

END arch_shiftregister_tb;


