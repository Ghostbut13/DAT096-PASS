library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
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
	
	signal  clk_tb : std_logic := '0';
	
	signal	reset_tb : std_logic := '1';
	signal	PositionX_tb : STD_LOGIC_VECTOR(6 DOWNTO 0);
	signal	PositionY_tb : STD_LOGIC_VECTOR(5 DOWNTO 0);

	signal  Correlation_tb_1 : corrData := (others => "000000");
	signal  Correlation_tb_2 : corrData := (others => "000000");
	signal  Correlation_tb_3 : corrData := (others => "000000");
	
	
	
begin
	
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
	
	Correlation_tb_1(1) <= "010000";
	
	process
	begin
	
		wait for 5 ns;
		clk_tb <= not(clk_tb);
	end process;
	
	
	

	
end Behavioral;
