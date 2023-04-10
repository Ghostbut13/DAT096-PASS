LIBRARY ieee;
LIBRARY work;
USE ieee.std_logic_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;
USE work.parameter.ALL;

ENTITY MAXbitor IS 
	PORT(
	clk : IN STD_LOGIC;
	rst_n : IN STD_LOGIC;
	din : IN xcorrdata;
	dout_index : OUT STD_LOGIC_VECTOR(xcorr_INDEX_WIDTH-1 DOWNTO 0)
	);
END ENTITY MAXbitor;

ARCHITECTURE arch_MAXbitor OF MAXbitor IS

  TYPE bitor_array IS ARRAY (0 TO xcorr_DATA_WDITH-1) OF STD_LOGIC_VECTOR(0 TO xcorr_REGISTER_LENGTH-1);

  SIGNAL addIndex_out_signal: xcorrindex := (OTHERS => (OTHERS => '0'));
  SIGNAL transposition_out_signal: xcorrdata_T := (OTHERS => (OTHERS => '0'));
  SIGNAL bitor_input_signal: bitor_array := (OTHERS => (OTHERS => '0');
  SIGNAL bitor_result_signal: STD_LOGIC_VECTOR(xcorr_DATA_WDITH-1 DOWNTO 0) := (OTHERS =>'0');
  SIGNAL bitor_input_last_signal: bitor_array := (OTHERS => (OTHERS => '0');
  
  SIGNAL outputvalue : STD_LOGIC_VECTOR(xcorr_DATA_WDITH-1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL outputvalue_buffer : STD_LOGIC := '0';
  SIGNAL MAXvalue : STD_LOGIC_VECTOR(xcorr_SIGNAL_WIDTH-1 DOWNTO 0) := (OTHERS => '0');

  COMPONENT addIndex IS
  PORT(
    clk : IN STD_LOGIC;
	din : IN xcorrdata;
	dout : OUT xcorrindex;
	);
  END COMPONENT addIndex;
  
  COMPONENT transposition IS
  PORT(
    clk : IN STD_LOGIC;
	input_matrix : IN xcorrdata;
	output_matrix : OUT xcorrdata_T
	);
  END COMPONENT transposition;
  
  COMPONENT shiftregister IS
  GENERIC(INPUT_WIDTH : INTEGER;
          REGISTER_NUM : INTEGER);
  PORT(clk: IN STD_LOGIC;
       rst_n: IN STD_LOGIC;
       din: IN STD_LOGIC_VECTOR(INPUT_WIDTH-1 DOWNTO 0);
       dout: OUT STD_LOGIC_VECTOR(INPUT_WIDTH-1 DOWNTO 0));
  END COMPONENT shiftregister;
  
  COMPONENT bitor IS
  PORT(
	clk : IN STD_LOGIC;
	din : IN STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH-1 DOWNTO 0);
	bitor_last : IN STD_LOGIC;
	din_last : IN STD_LOGIC_VECTOR(xcorr_REGISTER_LENGTH-1 DOWNTO 0);
	dout_bitor : OUT STD_LOGIC
	dout_last : OUT STD_LOGIC
	);
  END COMPONENT bitor;
  
  COMPONENT MAXbuffer IS 
  GENERIC(BUFFER_LENGTH: INTEGER);
  PORT(
    clk : IN STD_LOGIC;
    rst_n : IN STD_LOGIC;
    din : IN STD_LOGIC;
    dout: OUT STD_LOGIC
    );
  END COMPONENT MAXbuffer;

BEGIN
  addIndex_inst:
  COMPONENT addIndex
  PORT MAP(
    clk => clk,
	din => din,
	dout => addIndex_out_signal
  );
  
  transposition_inst:
  COMPONENT transposition
  PORT MAP(
    clk => clk,
    input_matrix => addIndex_out_signal,
	output_matrix => transposition_out_signal
  );
  
  SR: FOR i IN 0 TO xcorr_DATA_WDITH-2 GENERATE
    shiftregister_inst:
	COMPONENT shiftregister
	GENERIC MAP(INPUT_WIDTH => xcorr_REGISTER_LENGTH,
	            REGISTER_NUM => xcorr_DATA_WDITH-1-i)
    PORT MAP(
	  clk => clk,
	  rst_n => rst_n,
	  din => transposition_out_signal(i),
	  dout => bitor_input_signal(i)
	);
  END GENERATE;
  
  bitor_MSB:
  COMPONENT bitor
  PORT MAP(
    clk => clk,
	din => transposition_out_signal(xcorr_DATA_WDITH-1),
	bitor_last => '0',
	din_last => (OTHERS => '1'),
	dout_bitor => bitor_result_signal(xcorr_DATA_WDITH-1),
	dout_last => bitor_input_last_signal(xcorr_DATA_WDITH-1)
  );
  
  bitor: FOR i IN 0 TO xcorr_DATA_WDITH-2 GENERATE
    bitor_inst:
	COMPONENT bitor
	PORT MAP(
	  clk => clk,
	  din => transposition_out_signal(i),
	  bitor_last => bitor_result_signal(i+1),
	  din_last => bitor_input_last_signal(i+1),
	  dout_bitor => bitor_result_signal(i),
	  dout_last => bitor_input_last_signal(i)
  );
  
  maxbuffer: FOR i IN 0 TO xcorr_DATA_WDITH-3 GENERATE
    buffer_inst:
	COMPONENT MAXbuffer
    GENERIC MAP(BUFFER_LENGTH => xcorr_DATA_WDITH-1-i)
    PORT(
      clk => clk,
      rst_n => rst_n,
      din => bitor_result_signal(i)
      dout => outputvalue(i)
    );
  
  outputvalue(0) <= bitor_result_signal(0);
  
  outputvalue_buffer <= bitor_result_signal(1);
  outputvalue(1) <= outputvalue_buffer;
 
  MAXvalue <= outputvalue(xcorr_DATA_WDITH-1 DOWNTO xcorr_INDEX_WIDTH);
  dout_index <= outputvalue(xcorr_INDEX_WIDTH-1 DOWNTO 0);
  
END ARCHITECTURE arch_MAXbitor;