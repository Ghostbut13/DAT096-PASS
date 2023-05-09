LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
LIBRARY work;
USE work.parameter.ALL;

--bclk: 6MHz -> 0,1667x10^(-6) ->166.7 * 10^(-9) ->166 ns
--fsync: 48kHz ->0,0208x10^(-3) -> 20,8x10^(-6) -> 20800ns
ENTITY shiftregister_tb IS
--
END shiftregister_tb;

ARCHITECTURE arch_shiftregister_tb OF shiftregister_tb IS

SIGNAL din_tb:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
SIGNAL clk_fsync_tb: STD_LOGIC := '0';
SIGNAL clk_bclk_tb: STD_LOGIC := '0';
SIGNAL dout_PE_tb:outputdata  := (OTHERS => (OTHERS => '0'));
SIGNAL dout_xcorr_tb:outputdata  := (OTHERS => (OTHERS => '0'));

 COMPONENT shiftregister IS
 PORT(clk_read: IN STD_LOGIC;
     clk_write: IN STD_LOGIC;
     rst_n: IN STD_LOGIC;
     din: IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
     dout_PE: OUT outputdata;
	 dout_xcorr: OUT outputdata
	 );
  END COMPONENT shiftregister;

BEGIN
  shiftregister_inst:
  COMPONENT shiftregister
--    GENERIC MAP(SIGNAL_WIDTH => SIGNAL_WIDTH_tb,
--                REGISTER_LENGTH => REGISTER_LENGTH_tb)
    PORT MAP(clk_read => clk_bclk_tb,
     clk_write => clk_fsync_tb,
     rst_n => '1',
     din => din_tb,
     dout_PE => dout_PE_tb,
	 dout_xcorr => dout_xcorr_tb
	 );

din_tb <= "0000000000000001" after 13 ns,
          "0000000000000010" after 20713 ns,
		  "0000000000000011" after 41513 ns,
		  "0000000000000100" after 62313 ns,
		  "0000000000000101" after 83113 ns;
          
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

verification_proc:
PROCESS 
begin
wait for 10 ns;
assert(dout_PE_tb(0) = "0000000000000000") report("correct") severity note;
assert(dout_PE_tb(1) = "0000000000000000") report("correct") severity note;
assert(dout_xcorr_tb(0) = "0000000000000000") report("correct") severity note;
assert(dout_xcorr_tb(1) = "0000000000000000") report("correct") severity note;
end process verification_proc;

END arch_shiftregister_tb;


