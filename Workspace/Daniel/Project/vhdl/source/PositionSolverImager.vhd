library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;


entity PositionSolverImager is
    port(
		sysCLK:		in STD_LOGIC; --system clock 100MHz
		reset:		in STD_LOGIC; --system reset
		PositionX:	out STD_LOGIC_VECTOR(6 DOWNTO 0); -- position 0 to 128, middle 64
		PositionY:	out STD_LOGIC_VECTOR(5 DOWNTO 0); -- position 0 to 64
		Correlation1:	in corrData;
		Correlation2:	in corrData;
		Correlation3:	in corrData
    );
end PositionSolverImager;

architecture Behavioral of PositionSolverImager is
	COMPONENT LUTv IS 	-- look-up-table with vectors for each pixel in each correlation line
	PORT (				-- 12 bits of position data (6 bit X and 6 bit for Y), 95(128) points per line, 140 lines (17920)
		clka : IN STD_LOGIC;
		addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
    END COMPONENT LUTv;
	
	COMPONENT Picture_Frame IS 	-- picture frame to store image from each cross-correlation.
	PORT (						-- 6 bit depth of grayscale value, 64 by 128 pixels
		clka : IN STD_LOGIC;
		wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		dina : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
		clkb : IN STD_LOGIC;
		addrb : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		doutb : OUT STD_LOGIC_VECTOR(5 DOWNTO 0)
	);
	END COMPONENT Picture_Frame;
	
	
	SIGNAL lag: 		STD_LOGIC_VECTOR(8 DOWNTO 0); -- signal representing the lag value (-140 to 140)
	Signal pCounter: 	STD_LOGIC_VECTOR(6 DOWNTO 0); -- pixel counter, (0 to 94);
	Signal LUTXY:		STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL maxIsDone:	STD_LOGIC;	--done flag from max function
	
	TYPE state_type IS (reset_state, newLine_state, pixelAdd_state, MaxAndResetFrame_state);
	SIGNAL present_state_signal:state_type;
	SIGNAL next_state_signal:state_type;


	SIGNAL corr1:		STD_LOGIC_VECTOR(5 DOWNTO 0) := "000001";
	SIGNAL corr2:		STD_LOGIC_VECTOR(5 DOWNTO 0) := "000010";
	SIGNAL corr3:		STD_LOGIC_VECTOR(5 DOWNTO 0) := "000011";
	
	SIGNAL currentPixel1: STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL currentPixel2: STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL currentPixel3: STD_LOGIC_VECTOR(5 DOWNTO 0);
	
	SIGNAL replacePixel1: STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL replacePixel2: STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL replacePixel3: STD_LOGIC_VECTOR(0 DOWNTO 0);
	
	SIGNAL LUTlag:	STD_LOGIC_VECTOR(8 DOWNTO 0);
	
	SIGNAL PICaddr: std_logic_vector(14 DOWNTO 0);
	SIGNAL PIXY: std_logic_vector(12 DOWNTO 0);
	
begin
    PICaddr <= LUTlag(7 DOWNTO 0) & pCounter;
    
    
	LUTv_Inst:
	component LUTv
	port map(
		clka => sysCLK,
		addra => PICaddr,
		douta => LUTXY
	);
	
	Frame1:
	component Picture_Frame
	port map(
		clka => sysCLK,
		wea => replacePixel1,
		addra => PIXY,
		dina => corr1,
		clkb => sysCLK,
		addrb => PIXY,
		doutb => currentPixel1
	);
	Frame2:
	component Picture_Frame
	port map(
		clka => sysCLK,
		wea => replacePixel2,
		addra => PIXY,
		dina => corr2,
		clkb => sysCLK,
		addrb => PIXY,
		doutb => currentPixel2
	);
	Frame3:
	component Picture_Frame
	port map(
		clka => sysCLK,
		wea => replacePixel3,
		addra => PIXY,
		dina => corr3,
		clkb => sysCLK,
		addrb => PIXY,
		doutb => currentPixel3
	);

	
	solver_tran_proc:
	PROCESS(sysCLK, reset)
	BEGIN
		if reset = '0' then
			present_state_signal <= reset_state;
		elsif RISING_EDGE(sysCLK) then
			present_state_signal <= next_state_signal;
		end if;
	END PROCESS solver_tran_proc;
	
	
	solver_flow_proc:
	PROCESS(sysCLK, lag, pCounter, maxIsDone, present_state_signal)
	BEGIN
		case present_state_signal is
			when reset_state =>
				next_state_signal <= newLine_state;
			
			when newLine_state =>
				if lag < 280 then
					next_state_signal <= pixelAdd_state;
				else
					next_state_signal <= MaxAndResetFrame_state;
				end if;
				
			when pixelAdd_state =>
				if pCounter < 95 then
					next_state_signal <= pixelAdd_state;
				else
					next_state_signal <= newLine_state;
				end if;
				
			when MaxAndResetFrame_state =>
				if maxIsDone='1' then
					next_state_signal <= reset_state;
				else
					next_state_signal <= MaxAndResetFrame_state;
				end if;
		end case;
	END PROCESS solver_flow_proc;

	
	solver_state_proc:
	PROCESS(sysCLK, lag, LUTXY)
	BEGIN
	if RISING_EDGE(sysCLK) then
		case present_state_signal is
			when reset_state =>
				lag <= (others => '0');
				pCounter <= (others => '0');
			when newLine_state =>
				lag <= lag +1;
				pCounter <= (others => '0');
				
				-- retrieve new corr1/2/3 values
				corr1 <= correlation1(TO_INTEGER(unsigned(lag)));
				corr2 <= correlation2(TO_INTEGER(unsigned(lag)));
				corr3 <= correlation3(TO_INTEGER(unsigned(lag)));
			when pixelAdd_state =>
				pCounter <= pCounter +1;
				
				if currentPixel1 < corr1 then
					replacePixel1 <= "1";
				else
					replacePixel1 <= "0";
				end if;
				
				if currentPixel2 < corr2 then
					replacePixel2 <= "1";
				else
					replacePixel2 <= "0";
				end if;
				
				if currentPixel3 < corr3 then
					replacePixel3 <= "1";
				else
					replacePixel3 <= "0";
				end if;
				
			when MaxAndResetFrame_state =>
				corr1 <= (others => '0');
				corr2 <= (others => '0');
				corr3 <= (others => '0');
		end case;
	end if;
	
	if lag < 141 then
		LUTlag <= lag;
		PIXY <= '0' & LUTXY;
	else
		LUTlag <= lag-141;
		PIXY <= '1' & LUTXY;
	end if;
	
	END PROCESS solver_state_proc;
	
	

	
end Behavioral;
