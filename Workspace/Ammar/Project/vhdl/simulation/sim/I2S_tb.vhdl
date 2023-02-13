library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2S_tb is

	constant WORD_LENGTH_TB : integer := 64;

end I2S_tb;

architecture ARCH_I2S_tb of I2S_tb is

  component I2S is
  generic(WORD_LENGHT: NATURAL RANGE 1 TO 128) ;
  port  (
		bclk:IN STD_LOGIC ;
		start:IN STD_LOGIC ;
		reset:IN STD_LOGIC ;
		fsync:IN STD_LOGIC);
  end component I2S;
  

  signal start_tb : std_logic;
  signal reset_tb:std_logic;
  signal bclk_tb:std_logic := '0';
  signal fsync_tb : std_logic := '0';
  
  constant fsync_delay : time :=  1 us; -- 20.83 us; -- one period 48kHz 
  constant bclk_delay : time :=   3.9 ns;-- 81.380 ns; -- one period 12.288MHz
  signal clk_output : std_logic := '0';


  begin
  I2S_inst:
  component I2S
  generic map(WORD_LENGHT => WORD_LENGTH_TB)
  port map(
		bclk => bclk_tb,
		start=>start_tb,
		reset=> reset_tb,
		fsync => fsync_tb);  

				
 bclk_process:
  process
  begin
	wait for bclk_delay/2;
	bclk_tb <= not(bclk_tb);
  end process bclk_process;
  
 fsync_process:
  process
  begin
	wait for fsync_delay/2;
	fsync_tb <= not(fsync_tb);
  end process fsync_process;
   
  start_tb <= '0' ,
			  '1' after 3 us,
			  '0' after 11 us,
			  '1' after 13 us;
  
  reset_tb <= 	'1',
				'0' after 4 us,
				'1' after 5.5 us,
				'0' after 15 us,
				'1' after 17 us;   
				

clk_counter_proc:
	process(bclk_tb)
	variable i : natural range 0 to 129 := 0;
    begin
	if reset_tb = '0' then
		i := 0;
	end if;
	if falling_edge(bclk_tb) then
		i := i + 1;
		if i = 64 then
			i := 0;
			clk_output <= '1';
		else 
		clk_output <= '0';
		end if;
	end if;
	end process;
end ARCH_I2S_tb;