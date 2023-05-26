
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.fixed_float_types.all;
--use ieee.fixed_pkg.all;


entity iir_b is
	port(clk:in std_logic;
		filter_en: in std_logic;
		reset_n: in std_logic;
		filter_in: in std_logic_vector(15 downto 0);
		filter_out: out std_logic_vector(15 downto 0));
end iir_b;


architecture arc_iir_b of iir_b is 
	
	constant	Coef_b0	:	std_logic_vector(31 downto 0) := "00011100000100100011011011110001";				-- N0 - 0.7691
	constant	Coef_b1	:	std_logic_vector(31 downto 0) := "10101011110010010101101100101100";				-- N1	-2.3072
	constant	Coef_b2	:	std_logic_vector(31 downto 0) := "01010100001101101010010011010011";				-- N2	2.3072	
	constant 	coef_b3 : std_logic_vector(31 downto 0) := "11100011111011011100100100001110";					--N3  -0.7691
 	
	constant	Coef_a1	:	std_logic_vector(31 downto 0) := "10101000010111110010011010011101";				-- d1 -2.4778
	constant	Coef_a2	:	std_logic_vector(31 downto 0) := "01010000010100001111001111000010";		-- d2 2.08333	
	constant 	coef_a3 :	std_logic_vector(31 downto 0) := "11100111011000000001010110011100"; 	 			-- -0.5915
	
	signal x0, x1,x2,x3, y1,y2,y3 :std_logic_vector(31 downto 0):= (others=>'0');
	--signal yout_68 : std_logic_vector()
	signal x0_64, x1_64,x2_64,x3_64, y1_64,y2_64,y3_64 : std_logic_vector(63 downto 0):= (others=>'0');
	
	signal y_out :std_logic_vector(31 downto 0):= (others=>'0');
	
	begin
	clk_proc: process(clk,reset_n)
		begin 
			if reset_n = '0' then	
				x0 <= (others=>'0');
				x1 <= (others=>'0');
				x2 <= (others=>'0');
				x3 <= (others=>'0');
				
				y1 <= (others=>'0');
				y2 <= (others=>'0');
				y3 <= (others=>'0');
			elsif falling_edge(clk) then
				if filter_en = '1' then
					x0 <= filter_in(15) & filter_in(15) & filter_in & "00000000000000";
					x1<=x0;
					x2<=x1;
					x3<=x2;
				
					y1<= y_out;
					y2<= y1;
					y3<=y2;
					
					
					--
					--x0 <= x0_64(61 downto 30);
					--x1 <= x1_64(61 downto 30);
					--x2 <= x2_64(61 downto 30);
					--x3 <= x3_64(61 downto 30);
					
					--y1 <= y1_64(61 downto 30);
					--y2 <= y2_64(61 downto 30);
					--y3 <= y3_64(61 downto 30);
					
					y_out <= std_logic_vector(signed(x0_64(61 downto 30)) +  signed(x1_64(61 downto 30)) +  signed(x2_64(61 downto 30)) +
							 signed(x3_64(61 downto 30)) -  signed(y1_64(61 downto 30)) -  signed(y2_64(61 downto 30)) -
							 signed(y3_64(61 downto 30)));
					
					filter_out <= y_out(30 downto 15);
				
				end if;
			end if;
	end process clk_proc;
	
	
		
	
				x0_64 <= std_logic_vector( signed(Coef_b0) * signed(x0));
				x1_64 <= std_logic_vector( signed(Coef_b1) * signed(x1));
				x2_64 <= std_logic_vector( signed(Coef_b2) * signed(x2));
				x3_64 <= std_logic_vector( signed(Coef_b3) * signed(x3));
				
				y1_64 <= std_logic_vector( signed(Coef_a1) * signed(y_out));
				y2_64 <= std_logic_vector( signed(Coef_a2) * signed(y1));
				y3_64 <= std_logic_vector( signed(Coef_a3) * signed(y2));
	
end arc_iir_b;
	