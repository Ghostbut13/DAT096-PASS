library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity AttenuationComp is
  port(
	CLK :		in STD_LOGIC; --48kHz clock
	mic1:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	mic2:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	mic3:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	mic4:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	y_pos_in:   in std_logic_vector(6 downto 1);
	output_DAC:		out STD_LOGIC_VECTOR(16 downto 1)
    );
end AttenuationComp;

architecture Behavioral of AttenuationComp is
	SIGNAL distance_cm	   : std_logic_vector(10 downto 1) := (others => '0'); -- max number is 504
	SIGNAL mic1_multiplied : std_logic_vector(16 DOWNTO 1);
	SIGNAL mic2_multiplied : std_logic_vector(16 DOWNTO 1);
	SIGNAL mic3_multiplied : std_logic_vector(16 DOWNTO 1);
	SIGNAL mic4_multiplied : std_logic_vector(16 DOWNTO 1);	
	
	SIGNAL temp1 : std_logic_vector(26 downto 1) := (others => '0');
	SIGNAL temp2 : std_logic_vector(26 downto 1) := (others => '0');
	SIGNAL temp3 : std_logic_vector(26 downto 1) := (others => '0');
	SIGNAL temp4 : std_logic_vector(26 downto 1) := (others => '0');
	SIGNAL output_signal   : std_logic_vector (16 downto 1);
	
	component Mixer
	port(
	CLK:		in STD_LOGIC; --48kHz clock
	Input1:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input2:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input3:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Input4:		in STD_LOGIC_VECTOR(16 DOWNTO 1);
	Output:		OUT STD_LOGIC_VECTOR(16 DOWNTO 1)
    );
	end component;

begin

 Mixer_inst:
   component Mixer
   port map(
   CLK => CLK,
   Input1 => mic1_multiplied,
   Input2 => mic2_multiplied,
   Input3 => mic3_multiplied,
   Input4 => mic4_multiplied,
   Output => output_signal
   );
   
   assign_proc:
   process(clk)
   begin
   if falling_edge(clk) then
		output_DAC <= output_signal;
		mic1_multiplied <= temp1(22 downto 7);
		mic2_multiplied <= temp2(22 downto 7);
		mic3_multiplied <= temp3(22 downto 7);
		mic4_multiplied <= temp4(22 downto 7); 
	end if;
   end process;
	
	process(distance_cm, y_pos_in, mic1, mic2, mic3, mic4)
	begin
    distance_cm <= (y_pos_in * "1000");
	if distance_cm < "000110010" then -- set natural compensation at 100cm maybe? at 13 pixels
		temp1(22 downto 7) <= mic1;
		temp2(22 downto 7) <= mic2;
		temp3(22 downto 7) <= mic3;
		temp4(22 downto 7) <= mic4;
	
	else
		temp1 <= std_logic_vector(signed(distance_cm) * signed(mic1));
		temp2 <= std_logic_vector(signed(distance_cm) * signed(mic2));
		temp3 <= std_logic_vector(signed(distance_cm) * signed(mic3));
		temp4 <= std_logic_vector(signed(distance_cm) * signed(mic4));
	end if;
	end process;
end Behavioral;
