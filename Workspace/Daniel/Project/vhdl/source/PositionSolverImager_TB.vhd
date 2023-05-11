library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;
USE work.parameter.ALL;

entity PositionSolverImager_TB is
    
end PositionSolverImager_TB;

architecture Behavioral of PositionSolverImager_TB is
	COMPONENT PositionSolverImager IS 	-- look-up-table with vectors for each pixel in each correlation line
	port(
		sysCLK:		in STD_LOGIC; --system clock 100MHz
		reset:		in STD_LOGIC; --system reset
		PositionX:	out STD_LOGIC_VECTOR(6 DOWNTO 0); -- position 0 to 128, middle 64
		PositionY:	out STD_LOGIC_VECTOR(5 DOWNTO 0); -- position 0 to 64
		Correlation1:	in corrData;
		Correlation2:	in corrData;
		Correlation3:	in corrData
    );
    END COMPONENT PositionSolverImager;
	
  -- constant and type declarations, for example
  constant WL : positive := 32;

  -- adder wordlength
  constant CYCLES : positive := 280;
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
 
	signal  clk_tb : std_logic := '0';
	
	signal	reset_tb : std_logic := '1';
	signal	PositionX_tb : STD_LOGIC_VECTOR(6 DOWNTO 0);
	signal	PositionY_tb : STD_LOGIC_VECTOR(5 DOWNTO 0);

	signal  Correlation_tb_1 : corrData;
	signal  Correlation_tb_2 : corrData;
	signal  Correlation_tb_3 : corrData;
    
	signal correlation1_ARRAY: word_array;
	signal correlation2_ARRAY: word_array;
	signal correlation3_ARRAY: word_array;
	
--    signal temp_array1 : corrData  := (others=>(others => '0'));
--	signal temp_array2 : corrData  := (others=>(others => '0'));
--	signal temp_array3 : corrData  := (others=>(others => '0'));

	

		
   begin -- start architecture
   reset_tb <= '0' after 0 ns,
               '1' after 6 ns;
   
   
	-- clk generation
	process
	begin
		wait for 5 ns;
		clk_tb <= not(clk_tb);
	end process;
	
	-- inst
	P : PositionSolverImager
	port map(
		sysCLK		=> clk_tb,
		reset		=> reset_tb,
		PositionX	=> PositionX_tb,
		PositionY	=> PositionY_tb,
		Correlation1 => Correlation_tb_1,
		Correlation2 => Correlation_tb_2,
		Correlation3 => Correlation_tb_3
		);
	
   -- change these to your destinatino on the PC
   correlation1_ARRAY  <= load_words(string'("Z:\Desktop\DAT096-PASS-main\DAT096-PASS-main\Workspace\Daniel\Project\vhdl\source\corr1.txt"));
   correlation2_ARRAY  <= load_words(string'("Z:\Desktop\DAT096-PASS-main\DAT096-PASS-main\Workspace\Daniel\Project\vhdl\source\corr2.txt"));
   correlation3_ARRAY  <= load_words(string'("Z:\Desktop\DAT096-PASS-main\DAT096-PASS-main\Workspace\Daniel\Project\vhdl\source\corr3.txt"));
   
	
   to_array_proc:
    process(reset_tb)
     variable i : integer := 0;
     begin 
	  if (reset_tb = '0') then
		Correlation_tb_1 <= (others=>(others => '0'));
		Correlation_tb_2 <= (others=>(others => '0'));
		Correlation_tb_3 <= (others=>(others => '0'));
	  else
		FOR i IN 0 TO CYCLES-1 LOOP
		 Correlation_tb_1(i) <= correlation1_ARRAY(i);
		 Correlation_tb_2(i) <= correlation2_ARRAY(i);
		 Correlation_tb_3(i) <= correlation3_ARRAY(i);
		END LOOP;
      end if;
	end process;	
end Behavioral;
