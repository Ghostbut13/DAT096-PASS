library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;


entity PositionSolverImager is
    port(
		sysCLK:			in STD_LOGIC; --system clock 100MHz
		reset:			in STD_LOGIC; --system reset
		PositionX:		out STD_LOGIC_VECTOR(6 DOWNTO 0); -- position 0 to 128, middle 64
		PositionY:		out STD_LOGIC_VECTOR(5 DOWNTO 0); -- position 0 to 64
		Correlation1:	in xcorrdata;
		Correlation2:	in xcorrdata;
		Correlation3:	in xcorrdata
    );
end PositionSolverImager;

architecture Behavioral of PositionSolverImager is
	COMPONENT LUTv IS 	-- look-up-table with vectors for each pixel in each correlation line
	PORT (				-- 12 bits of position data (6 bit X and 6 bit for Y), 95(128) points per line, 140 lines (17920)
		clka: 	IN STD_LOGIC;
		addra: 	IN STD_LOGIC_VECTOR(14 DOWNTO 0);
		douta: 	OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
	);
    END COMPONENT LUTv;
	
	COMPONENT Picture_Frame IS 	-- picture frame to store image from each cross-correlation.
	PORT (						-- 32 bit depth of grayscale value, 64 by 128 pixels
		clka: 	IN STD_LOGIC;
		wea:  	IN STD_LOGIC_VECTOR(0 DOWNTO 0);
		addra: 	IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		dina: 	IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		clkb: 	IN STD_LOGIC;
		addrb: 	IN STD_LOGIC_VECTOR(12 DOWNTO 0);
		doutb: 	OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
	END COMPONENT Picture_Frame;
	
	COMPONENT maxLUT IS 
	PORT (
	   clk: 		IN STD_LOGIC;
	   rst_n: 		IN STD_LOGIC;
	   din: 		IN STD_LOGIC_VECTOR (33 downto 0);
	   xy_pos_in: 	IN STD_LOGIC_VECTOR(12 DOWNTO 0);
	   xy_pos_out:	OUT STD_LOGIC_VECTOR(12 DOWNTO 0)
	);
    END COMPONENT maxLUT;
	
	
	SIGNAL lag: 		STD_LOGIC_VECTOR(8 DOWNTO 0); -- signal representing the lag value (-140 to 140)
	Signal pCounter: 	STD_LOGIC_VECTOR(6 DOWNTO 0); -- point counter, (0 to 94);
	Signal LUTXY:		STD_LOGIC_VECTOR(11 DOWNTO 0);
	
	TYPE state_type IS (reset_state, newLine_state, pixelComp_state, pixelAdd_state, MaxAndResetFrame_state);
	SIGNAL present_state_signal:state_type;
	SIGNAL next_state_signal:state_type;


	SIGNAL corr1:		STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL corr2:		STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL corr3:		STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL currentPixel1: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL currentPixel2: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL currentPixel3: STD_LOGIC_VECTOR(31 DOWNTO 0);
	
	SIGNAL replacePixel1: STD_LOGIC :='0';
	SIGNAL replacePixel2: STD_LOGIC :='0';
	SIGNAL replacePixel3: STD_LOGIC :='0';
	
	SIGNAL LUTlag:	STD_LOGIC_VECTOR(8 DOWNTO 0);
	
	SIGNAL PICaddr: std_logic_vector(14 DOWNTO 0);
	SIGNAL PIXY1: 	std_logic_vector(12 DOWNTO 0);
	SIGNAL PIXY2: 	std_logic_vector(12 DOWNTO 0);
	SIGNAL PIXY3: 	std_logic_vector(12 DOWNTO 0);
	SIGNAL MaxCounter: 	std_logic_vector(12 DOWNTO 0);
	SIGNAL maxReset: 	std_logic;
	SIGNAL pixelVal123: std_logic_vector(33 DOWNTO 0);
	SIGNAL XY_signal: 	std_logic_vector(12 DOWNTO 0);
	
	
	SIGNAL writeEnable: STD_LOGIC := '0';
	SIGNAL wea1: STD_LOGIC_vector(0 downto 0) :=(others => '0');
	SIGNAL wea2: STD_LOGIC_vector(0 downto 0) :=(others => '0');
	SIGNAL wea3: STD_LOGIC_vector(0 downto 0) :=(others => '0');
	
begin
    PICaddr <= LUTlag(7 DOWNTO 0) & pCounter;
    pixelVal123 <= ("00" & currentPixel1) + ("00" & currentPixel2) + ("00" & currentPixel3);
    
    
    wea1 <= "1" when (writeEnable='1' AND replacePixel1='1') else "0";
    wea2 <= "1" when (writeEnable='1' AND replacePixel2='1') else "0";
    wea3 <= "1" when (writeEnable='1' AND replacePixel3='1') else "0";
    
	LUTv_Inst:
	component LUTv
	port map(
		clka 	=> sysCLK,
		addra 	=> PICaddr,
		douta 	=> LUTXY
	);
	
	Frame1:
	component Picture_Frame
	port map(
		clka 	=> sysCLK,
		wea 	=> wea1,
		addra 	=> PIXY1,
		dina 	=> corr1,
		clkb 	=> sysCLK,
		addrb 	=> PIXY1,
		doutb 	=> currentPixel1
	);
	Frame2:
	component Picture_Frame
	port map(
		clka 	=> sysCLK,
		wea 	=> wea2,
		addra 	=> PIXY2,
		dina 	=> corr2,
		clkb 	=> sysCLK,
		addrb 	=> PIXY2,
		doutb 	=> currentPixel2
	);
	Frame3:
	component Picture_Frame
	port map(
		clka 	=> sysCLK,
		wea 	=> wea3,
		addra 	=> PIXY3,
		dina 	=> corr3,
		clkb 	=> sysCLK,
		addrb 	=> PIXY3,
		doutb 	=> currentPixel3
	);

    max:
    COMPONENT maxLUT
	port map (
	   clk 			=> sysCLK,
	   rst_n 		=> maxReset,
	   din 			=> pixelVal123,
	   xy_pos_in 	=> PIXY2,
	   xy_pos_out 	=> XY_signal
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
	PROCESS(sysCLK, lag, pCounter, present_state_signal, MaxCounter)
	BEGIN
		case present_state_signal is
			when reset_state =>
				next_state_signal <= newLine_state;
			
			when newLine_state =>
				-- loop through the 280 available lag lines
				if lag < 279 then
					next_state_signal <= pixelComp_state;
				else
					next_state_signal <= MaxAndResetFrame_state;
				end if;
				
			when pixelComp_state =>
			     next_state_signal <= pixelAdd_state;
				
			when pixelAdd_state =>
				-- loop through every available point in each lag line
				if pCounter < 95 then
					next_state_signal <= pixelComp_state;
				else
					next_state_signal <= newLine_state;
				end if;
				
			when MaxAndResetFrame_state =>
				-- loop through every pixel in the overlapping window of pictureFrames
				if MaxCounter >= 6592 then -- 103*64
					next_state_signal <= reset_state;
				else
					next_state_signal <= MaxAndResetFrame_state;
				end if;
		end case;
	END PROCESS solver_flow_proc;

	
	solver_state_proc:
	PROCESS(sysCLK, lag, LUTXY, present_state_signal, MaxCounter)
	BEGIN
	if RISING_EDGE(sysCLK) then
		case present_state_signal is
			when reset_state =>
				-- resets accumulators and stores the position from the previous run to the output
				lag <= (others => '0');
				pCounter <= (others => '0');
				MaxCounter <= (others => '0');
				maxReset <= '0';
				PositionX <= XY_signal(12 DOWNTO 6);
				PositionY <= XY_signal(5 DOWNTO 0);
			when newLine_state =>
				-- grab new correlation line and its correlation value
				lag <= lag +1;
				pCounter <= (others => '0');
				
				-- retrieve new corr1/2/3 values
				corr1 <= correlation1(TO_INTEGER(unsigned(lag)));
				corr2 <= correlation2(TO_INTEGER(unsigned(lag)));
				corr3 <= correlation3(TO_INTEGER(unsigned(lag)));
			when pixelComp_state =>
				-- compare the correlation value corresponding to the lag line with the current pixel value and sets the flag accordingly
				if signed(currentPixel1) < signed(corr1) then
					replacePixel1 <= '1';
				else
					replacePixel1 <= '0';
				end if;
				
				if signed(currentPixel2) < signed(corr2) then
					replacePixel2 <= '1';
				else
					replacePixel2 <= '0';
				end if;
				
				if signed(currentPixel3) < signed(corr3) then
					replacePixel3 <= '1';
				else
					replacePixel3 <= '0';
				end if;
				
				
			when pixelAdd_state =>
				-- prepare to read new pixel. writeEnable = true so if replacePixelx is true then a new value will be written to the pictureFrame
				pCounter <= pCounter +1;
				
			when MaxAndResetFrame_state =>
				-- read each picture frame and send to MAXlut, aswell as reset pixel value to 0
				maxReset <= '1';
			    	MaxCounter <= MaxCounter +1;
				corr1 <= (others => '0');
				corr2 <= (others => '0');
				corr3 <= (others => '0');
				replacePixel1 <= '1';
				replacePixel2 <= '1';
				replacePixel3 <= '1';
				lag <= (others => '0'); -- prevent non allocated memory access
		end case;
	end if;
	
	
	if present_state_signal = pixelAdd_state OR present_state_signal = MaxAndResetFrame_state then
	   writeEnable <= '1';
	else
	   writeEnable <= '0';
	end if;
	
	if present_state_signal = pixelAdd_state OR present_state_signal = pixelComp_state then
	   if lag < 140 then
		  LUTlag <= lag;
		  PIXY1 <= ('1' & LUTXY);
		  PIXY2 <= ('1' & LUTXY);
		  PIXY3 <= ('1' & LUTXY);
	   else
		  LUTlag <= lag-140;
		  PIXY1 <= '0' & LUTXY;
		  PIXY2 <= '0' & LUTXY;
		  PIXY3 <= '0' & LUTXY;
	   end if;
	elsif present_state_signal = MaxAndResetFrame_state then
	   PIXY1 <= MaxCounter + 1664; -- 26*64 (shift 26 pixels in X)
	   PIXY2 <= MaxCounter + 832; --13* 64 (shift 13 pixels in X)
	   PIXY3 <= MaxCounter;
	   LUTlag  <= (others => '0');
    else
        PIXY1 <= (others => '0');
        PIXY2 <= (others => '0');
        PIXY3 <= (others => '0');
	    LUTlag  <= (others => '0');
	   
	end if;
	END PROCESS solver_state_proc;
	
	

	
end Behavioral;