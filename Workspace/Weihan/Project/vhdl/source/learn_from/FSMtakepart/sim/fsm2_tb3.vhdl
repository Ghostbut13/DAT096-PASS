--------------------------------------------
-- name        : fsm2_tb3.vhdl             --
-- author      : Weihan Gao                --
-- discribtion :
--  testbench of fsm2 in lab2;             --
--  generate the fsm1_done,fsm1_empty_flag,--
--  fsm1_s from fsm1 and monitor SDI,start,--
--  load.


library ieee;
use ieee.std_logic_1164.all;
use work.type_package_fsm2.all;

entity fsm2_tb3 is
  CONSTANT FSM2_WIDTH: NATURAL := 16 ;
  CONSTANT TESTVEC: STD_LOGIC_VECTOR(FSM2_WIDTH downto 1) := "1000101001011011" ;
end entity fsm2_tb3;


architecture arch_fsm2_tb3 of fsm2_tb3 is
  component fsm2 is
    port (reset          :IN STD_LOGIC;
          clk            :IN STD_LOGIC;
          fsm2_start     :IN STD_LOGIC;
          SPI_clk_enable :IN STD_LOGIC;
          A_B            :IN STD_LOGIC;
          GA             :IN STD_LOGIC;
          CS             :OUT STD_LOGIC;
          SDI            :OUT STD_LOGIC;        
	         state          :OUT state_type_fsm2;
	         next_state     :OUT state_type_fsm2;
	         
	         
	         fsm1_done      :in std_logic;
	         fsm1_empty_flag:in std_logic;
	         fsm1_s         :in std_logic;
	       
	         fsm1_load      :out std_logic;
	         fsm1_start     :out std_logic);
	end component;
	
	SIGNAL reset_tb3_signal:STD_LOGIC;
  SIGNAL clk_tb3_signal:STD_LOGIC := '1';
  SIGNAL fsm2_start_tb3_signal:STD_LOGIC;
  SIGNAL SPI_clk_enable_tb3_signal:STD_LOGIC := '1';
  SIGNAL A_B_tb3_signal:STD_LOGIC;
  SIGNAL GA_tb3_signal:STD_LOGIC;
  
  
  SIGNAL CS_tb3_signal:STD_LOGIC;
  SIGNAL SDI_tb3_signal:STD_LOGIC;
  SIGNAL state_tb3_signal:state_type_fsm2;
  SIGNAL next_state_tb3_signal:state_type_fsm2;
	
	
	-- generated signal
	SIGNAL fsm1_done_tb3_signal      :std_logic:= '1';  
	SIGNAL fsm1_empty_flag_tb3_signal:std_logic:= '0';
	SIGNAL fsm1_s_tb3_signal         :std_logic:= '0';
	
	-- monitored signal
	SIGNAL fsm1_load_tb3_signal      :std_logic:= '0';
	SIGNAL fsm1_start_tb3_signal     :std_logic:= '0';
	
	SIGNAL i : integer;
	
	
	begin
	  --1:instance 
	  fsm2_inst_1: fsm2
	   port map (reset          => reset_tb3_signal,
              clk             => clk_tb3_signal,
              fsm2_start      => fsm2_start_tb3_signal,
              SPI_clk_enable  => SPI_clk_enable_tb3_signal,
              A_B             => A_B_tb3_signal,
              GA              => GA_tb3_signal,
              CS              => CS_tb3_signal,
              SDI             => SDI_tb3_signal,
	            state           => state_tb3_signal,
	            next_state      => next_state_tb3_signal,
	         
	         
	             fsm1_done         => fsm1_done_tb3_signal,
	             fsm1_empty_flag   => fsm1_empty_flag_tb3_signal,
	             fsm1_s            => fsm1_s_tb3_signal,
	             fsm1_load         => fsm1_load_tb3_signal,
	             fsm1_start        => fsm1_start_tb3_signal);
	           
	           
	  --2:initial the configration(key) singal : A_B & GA
	  A_B_tb3_signal <= '0';
    GA_tb3_signal <= '0';
    
    
	  --3:initial period signal : clk & spi_clk_enable
	  clk_proc:
    process
    begin
      wait for 5 ns;
      clk_tb3_signal <= not(clk_tb3_signal);
    end process clk_proc;
    
    SPI_clk_enable_tb3_proc:
    PROCESS
    BEGIN
      SPI_clk_enable_tb3_signal <= '1';
      WAIT FOR 10 ns;
      SPI_clk_enable_tb3_signal <= '0';
      WAIT FOR 490 ns;
    END PROCESS SPI_clk_enable_tb3_proc; 
    
    --4:generate the ON signal 
    reset_tb3_signal <= '0',
                        '1' AFTER 123 ns,
                        '0' AFTER 333 ns;

    fsm2_start_tb3_signal <= '0',
                             '1' AFTER 423 ns,
                             '0' AFTER 623 ns;
                             
                             
    --5:imitate the fsm1's action by generating the fsm1's signal
    --based on the wave from fsm1.vhdl
    fsm1_done_tb3_signal        <=  '1',
                                    '0' after 3000 ns,
                                    '1' after 3160 ns;
                            
	  fsm1_empty_flag_tb3_signal   <= '0',
	                                  '1' after 3160 ns,
	                                  '0' after 3170 ns;


	  fsm1_s_imitation:
	  process begin
	  wait for 3000 ns;           
	  for i in FSM2_WIDTH downto 1 loop
	    fsm1_s_tb3_signal <= TESTVEC(i);
	    wait for 10 ns;
	  end loop;
	  fsm1_s_tb3_signal<='0';
	  end process fsm1_s_imitation;
	  
	  
	  
     
	  
end architecture arch_fsm2_tb3;
	      
