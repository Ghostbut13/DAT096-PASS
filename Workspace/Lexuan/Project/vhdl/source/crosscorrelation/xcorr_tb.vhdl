library IEEE;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_textio.all;
use STD.textio.all;
LIBRARY work;
USE work.parameter.ALL;

ENTITY xcorr_tb IS 
--
END ENTITY xcorr_tb;

ARCHITECTURE arch_xcorr_tb OF xcorr_tb IS
  
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

  SIGNAL din_1_tb:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  SIGNAL din_2_tb:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  SIGNAL clk_fsync_tb: STD_LOGIC := '0';
  SIGNAL clk_bclk_tb: STD_LOGIC := '0';
  SIGNAL dout_PE_1_tb:outputdata  := (OTHERS => (OTHERS => '0'));
  SIGNAL dout_PE_2_tb:outputdata  := (OTHERS => (OTHERS => '0'));
  SIGNAL dout_xcorr_lag_1_tb:outputdata  := (OTHERS => (OTHERS => '0'));
  SIGNAL dout_xcorr_lag_2_tb:outputdata  := (OTHERS => (OTHERS => '0'));
  SIGNAL dout_xcorr_ref_1_tb:outputdata  := (OTHERS => (OTHERS => '0'));
  SIGNAL dout_xcorr_ref_2_tb:outputdata  := (OTHERS => (OTHERS => '0'));
  SIGNAL dout_tb : xcorrdata := (OTHERS => (OTHERS => '0'));
  signal A_array : word_array;

COMPONENT shiftregister IS
PORT(clk_read: IN STD_LOGIC; --system clk 
     clk_write: IN STD_LOGIC; --fsync
     rst_n: IN STD_LOGIC;
     din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
     dout_PE: OUT outputdata;
	 dout_xcorr_lag: OUT outputdata;
	 dout_xcorr_ref: OUT outputdata
	 );
END COMPONENT shiftregister;

COMPONENT Xcc IS
	PORT(
	clk_en: IN STD_LOGIC;
	clk : IN STD_LOGIC;
	din_reference : IN outputdata;
	din_xcorr : IN outputdata;
	rst_n: IN STD_LOGIC;
	dout: OUT xcorrdata
	);
END COMPONENT Xcc;

BEGIN 

  shiftregister_channel1_inst:
  COMPONENT shiftregister
    PORT MAP(clk_read => clk_bclk_tb,
     clk_write => clk_fsync_tb,
     rst_n => '1',
     din => din_1_tb,
     dout_PE => dout_PE_1_tb,
	 dout_xcorr_lag => dout_xcorr_lag_1_tb,
	 dout_xcorr_ref => dout_xcorr_ref_1_tb
	 );
	 
  shiftregister_channel2_inst:
  COMPONENT shiftregister
    PORT MAP(clk_read => clk_bclk_tb,
     clk_write => clk_fsync_tb,
     rst_n => '1',
     din => din_2_tb,
     dout_PE => dout_PE_2_tb,
	 dout_xcorr_lag => dout_xcorr_lag_2_tb,
	 dout_xcorr_ref => dout_xcorr_ref_2_tb
	 );

  xcorr_inst:
  COMPONENT Xcc
	PORT MAP(
	clk_en => clk_fsync_tb,
	clk => clk_bclk_tb,
	din_reference => dout_xcorr_ref_1_tb,
	din_xcorr => dout_xcorr_lag_2_tb,
	rst_n => '1',
	dout => dout_tb
	);
	
  -- read input values
  A_array  <= load_words(string'("C:\Users\lexuan\Downloads\DAT096-PASS-main (1)\DAT096-PASS-main\Workspace\Lexuan\Project\vhdl\source\shiftregister\data10000.txt"));

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
 
 verification_1_proc:
 PROCESS 
 VARIABLE n : natural := 1;
 BEGIN

  WAIT FOR 5200 ns;
    din_1_tb <= A_array(0);
  WAIT FOR 20800 ns;
  
  write_output : 
  WHILE n < CYCLES LOOP
    din_1_tb <= A_array(n);
      --assert(1 = 1) report("correct") severity warning;
    WAIT FOR 20800 ns;
    n := n+1;
  END LOOP write_output;

  ASSERT(false) REPORT "Done" SEVERITY failure;
  
  END PROCESS verification_1_proc;
 
  verification_2_proc:
 PROCESS 
 VARIABLE n : natural := 1;
 BEGIN

  WAIT FOR 26000 ns;
    din_2_tb <= A_array(0);
  WAIT FOR 20800 ns;
  
  write_output : 
  WHILE n < CYCLES LOOP
    din_2_tb <= A_array(n);
      --assert(1 = 1) report("correct") severity warning;
    WAIT FOR 20800 ns;
    n := n+1;
  END LOOP write_output;

  ASSERT(false) REPORT "Done" SEVERITY failure;
  
  END PROCESS verification_2_proc;

END ARCHITECTURE arch_xcorr_tb;