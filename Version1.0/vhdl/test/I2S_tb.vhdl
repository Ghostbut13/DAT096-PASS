library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity I2S_tb is

	

end I2S_tb;

architecture ARCH_I2S_tb of I2S_tb is
  constant WORD_LENGTH_TB : integer := 16;
  
  component I2S is
  port  (
		bclk:IN STD_LOGIC ;
		start:IN STD_LOGIC ;
		reset:IN STD_LOGIC ;
		fsync:IN STD_LOGIC;
		DIN : IN STD_LOGIC;
		L1_out : out std_logic_vector (15 downto 0);
		L2_out : out std_logic_vector (15 downto 0);
		R1_out : out std_logic_vector (15 downto 0);
		R2_out : out std_logic_vector (15 downto 0)
		--SDOUT : OUT std_logic
		);
  end component I2S;
  

  signal start_tb : std_logic;
  signal reset_tb:std_logic;
  signal bclk_tb:std_logic := '1';
  signal fsync_tb : std_logic := '0';
  
  signal DIN_tb : std_logic := '0';
  signal LC1_tb : std_logic_vector (WORD_LENGTH_TB-1 downto 0); 
  signal LC2_tb : std_logic_vector (WORD_LENGTH_TB -1 downto 0); 
  signal RC1_tb : std_logic_vector (WORD_LENGTH_TB -1 downto 0); 
  signal RC2_tb : std_logic_vector (WORD_LENGTH_TB -1 downto 0); 
  
  
  
  constant fsync_delay : time :=  2560 ns; -- 20.83 us; -- one period 48kHz 
  constant bclk_delay : time :=   10 ns;-- 81.380 ns; -- one period 12.288MHz
  constant data_rate : time := 10 ns;
  signal clk_output : std_logic := '0';


  begin
  I2S_inst:
  component I2S
  port map(
		bclk => bclk_tb,
		start=>start_tb,
		reset=> reset_tb,
		fsync => fsync_tb,
		DIN => DIN_tb,
		L1_out => LC1_tb,
		L2_out => LC2_tb,
		R1_out => RC1_tb,
		R2_out => RC2_tb
		);
				
 bclk_process:
  process
  begin
	wait for bclk_delay/2;
	bclk_tb <= not(bclk_tb);
  end process bclk_process;
  
  generate_DIN_process:
   process
   begin
     wait for 1.5*data_rate;
	 DIN_tb <= not(DIN_tb);
	end process generate_DIN_process;
	
  
 fsync_process:
  process
  begin
	wait for fsync_delay/2;
	fsync_tb <= not(fsync_tb);
  end process fsync_process;
   
  start_tb <= '0' ,
			  '1' after 120 ns,
			  '0' after 600 ns,
			  '1' after 650 ns;
  
  reset_tb <= 	'1',
				'0' after 320 ns,
				'1' after 400 ns,
				'0' after 900 ns,
				'1' after 950 ns;   
				

clk_counter_proc:
	process(bclk_tb)
	variable i : natural range 0 to 129 := 0;
    begin
	if reset_tb = '0' then
		i := 0;
	end if;
	if rising_edge(bclk_tb) then
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