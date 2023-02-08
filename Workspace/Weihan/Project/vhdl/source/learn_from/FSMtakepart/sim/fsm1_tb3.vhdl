-- test bench for fsm1.  / ljs Sep 13 2021

LIBRARY ieee ;

USE ieee.std_logic_1164.ALL ;
USE ieee.numeric_std.ALL ;
use work.type_package_fsm1.all;

ENTITY fsm1_tb IS
  CONSTANT THE_WIDTH: NATURAL := 16 ;
  --CONSTANT TESTVEC: STD_LOGIC_VECTOR(THE_WIDTH downto 1) := "101001011010" ;
  CONSTANT TESTVEC: STD_LOGIC_VECTOR(THE_WIDTH downto 1) := "1000101001011011" ;
END ENTITY fsm1_tb ;

ARCHITECTURE arch OF fsm1_tb IS

  COMPONENT fsm1 IS
    GENERIC (WIDTH: NATURAL RANGE 1 TO 16) ; 
    PORT (din:IN STD_LOGIC_VECTOR(WIDTH-1 DOWNTO 0) ;
          clk:IN STD_LOGIC ;
          SPI_clk_enable:IN STD_LOGIC ; 
          reset:IN STD_LOGIC ; 
          load:IN STD_LOGIC ;
          start:IN STD_LOGIC ;
          s:OUT STD_LOGIC ;
          done:OUT STD_LOGIC;
          
          data            :out STD_LOGIC_VECTOR(WIDTH DOWNTO 1);
          empty_flag      :out std_logic;
          state           :out state_type_fsm1;
          next_state      :out state_type_fsm1;
          cnt_out         :out NATURAL range 0 to width-1
          ) ;
  END COMPONENT fsm1 ;

  SIGNAL din_tb: STD_LOGIC_VECTOR(THE_WIDTH DOWNTO 1) ;
  SIGNAL clk_tb: STD_LOGIC := '1';
  SIGNAL reset_tb: STD_LOGIC ;
  SIGNAL load_tb: STD_LOGIC ;
  SIGNAL start_tb: STD_LOGIC ;
  SIGNAL s_tb: STD_LOGIC ;
  SIGNAL done_tb: STD_LOGIC ;
  SIGNAL CE_tb: STD_LOGIC ; 
  
  signal counter_tb: NATURAL range 0 to the_width;
  signal empty_flag_tb      :  std_logic;
  signal next_state_tb : state_type_fsm1;
  signal state_tb : state_type_fsm1;
  signal data_tb  : STD_LOGIC_VECTOR(THE_WIDTH DOWNTO 1);

BEGIN

  fsm1_inst:
    COMPONENT fsm1
      GENERIC MAP (WIDTH => THE_WIDTH) 
      PORT MAP (din => din_tb,
                clk => clk_tb,
                SPI_clk_enable => CE_tb,
                reset => reset_tb,
                load => load_tb,
                start => start_tb,
                s => s_tb,
                done => done_tb,
                
                data=>data_tb,
                state => state_tb,
                next_state => next_state_tb,
                cnt_out => counter_tb,
                empty_flag=>empty_flag_tb
                ) ;

  clk_proc:
  PROCESS
  BEGIN
    WAIT FOR 5 ns ;
    clk_tb <= NOT(clk_tb) ;
  END PROCESS clk_proc ;

  CE_proc:
  PROCESS
  BEGIN
    CE_tb <= '1' ;
    WAIT FOR 10 ns ;
    CE_tb <= '0' ;
    WAIT FOR 490 ns ; 
  END PROCESS CE_proc ; 

  din_tb <= TESTVEC ;
  
  reset_tb <= '0',
              '1' after 50 ns,
              '0' after 250 ns ;

  load_tb <= '0',
             '1' after 350 ns,
             '0' after 550 ns ;

  start_tb <= '0',
              '1' after 850 ns,
              '0' after 1050 ns ;
              

  test_proc:
  PROCESS
  BEGIN
    WAIT FOR 200 ns ;
    ASSERT (reset_tb = '1')
      REPORT "no reset"
      SEVERITY ERROR ;
    ASSERT (done_tb = '1')
      REPORT "done not set"
      SEVERITY error ;
    ASSERT (s_tb = '0')
      REPORT "s not 0"
      SEVERITY ERROR ; 

    WAIT FOR 310 ns ;
    ASSERT (load_tb = '1')
      REPORT "no load"
      SEVERITY error ;

    WAIT FOR 500 ns ; 
    ASSERT (start_tb = '1')     
      REPORT "no start"
      SEVERITY ERROR ;

    WAIT FOR 10000 ns ; 
    
  END PROCESS test_proc ; 

END ARCHITECTURE arch ;
  
