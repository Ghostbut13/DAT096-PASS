
library ieee;
use ieee.std_logic_1164.all;
USE IEEE.std_logic_unsigned.ALL;
use work.type_package_fsm1.all;
use work.type_package_fsm2.all;

entity top is
  generic (data_width :natural range 1 to 16);
  PORT (reset:IN STD_LOGIC;
         clk:IN STD_LOGIC;
         start:IN STD_LOGIC;
         SPI_clk_enable:IN STD_LOGIC;
         A_B:IN STD_LOGIC;
         GA:IN STD_LOGIC;
         DATA_in:IN STD_LOGIC_VECTOR(data_width DOWNTO 1);
         CS:OUT STD_LOGIC;
         
	       
	       --simulation signal 
          --s               :OUT STD_LOGIC;
        
          --done            :OUT STD_LOGIC;
          --data            :out STD_LOGIC_VECTOR(WIDTH DOWNTO 1);
          --empty_flag      :out std_logic;
          --state           :out state_type_fsm2;
          --next_state      :out state_type_fsm2;
          --cnt_out         :out NATURAL range 0 to width;
          --load            :IN STD_LOGIC ;
          --start           :IN STD_LOGIC ;
          
          
          SDI:OUT STD_LOGIC
          );
END entity top;

architecture arch_top of top is
  component fsm1 is
    GENERIC (WIDTH: NATURAL RANGE 1 TO 16) ; 
    PORT (din             :IN STD_LOGIC_VECTOR(WIDTH DOWNTO 1) ;
          clk             :IN STD_LOGIC ;
          SPI_clk_enable  :IN STD_LOGIC ; 
          reset           :IN STD_LOGIC ; 
          load            :IN STD_LOGIC ;
          start           :IN STD_LOGIC ;
        
          s               :OUT STD_LOGIC ;
          done            :OUT STD_LOGIC;
        
        
          data            :out STD_LOGIC_VECTOR(WIDTH DOWNTO 1);
          empty_flag      :out std_logic;
          state           :out state_type_fsm1;
          next_state      :out state_type_fsm1;
          cnt_out         :out NATURAL range 0 to width) ; 
  end component fsm1;
  
  component fsm2 is
   PORT (reset          :IN STD_LOGIC;
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
	       fsm1_start     :out std_logic
	       );
	 end component fsm2;
	 

	 -- inner
	 signal fsm1_done_top:std_logic;
	 signal fsm1_empty_flag_top:std_logic;
	 signal fsm1_s_top:std_logic;
	 signal fsm1_load_top:std_logic;
	 signal fsm1_start_top:std_logic;
	 
	 begin
     fsm2_inst_1: fsm2
	   port map (reset          => reset,
              clk             => clk,
              fsm2_start      => start,
              SPI_clk_enable  => SPI_clk_enable,
              A_B             => A_B,
              GA              => GA,
              CS              => CS, 
	            --state           => ,
	            --next_state      => ,
	            fsm1_done         => fsm1_done_top,
	            fsm1_empty_flag   => fsm1_empty_flag_top,
	            fsm1_s            => fsm1_s_top,
	            fsm1_load         => fsm1_load_top,
	            fsm1_start        => fsm1_start_top,
	             
	            SDI             => SDI
	            );
	            
	     fsm1_inst_1: fsm1
	     generic map (WIDTH => data_width)
	     port map (din => DATA_in,
              clk => clk,
              
              reset => reset, 
              start => fsm1_start_top,
              load => fsm1_load_top,
              s => fsm1_s_top,
              done =>fsm1_done_top,
              --data => ;
              empty_flag =>fsm1_empty_flag_top,
              --state,
              --next_state,
              --cnt_out,
              
              SPI_clk_enable => SPI_clk_enable
              ); 

end ARCHITECTURE arch_top;
  
