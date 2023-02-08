LIBRARY ieee ;

USE ieee.std_logic_1164.ALL ;
USE ieee.numeric_std.ALL ;
USE IEEE.std_logic_unsigned.ALL;
USE WORK.type_package_fsm1.All ;

ENTITY fsm1 IS
  GENERIC (WIDTH: NATURAL RANGE 1 TO 16) ; 
  PORT (din             :IN STD_LOGIC_VECTOR(WIDTH DOWNTO 1) ;
        clk             :IN STD_LOGIC ;
        SPI_clk_enable  :IN STD_LOGIC ; 
        reset           :IN STD_LOGIC ; 
        load            :IN STD_LOGIC ;
        start           :IN STD_LOGIC ;
        s               :OUT STD_LOGIC;
        done            :OUT STD_LOGIC;
        
        
        data            :out STD_LOGIC_VECTOR(WIDTH DOWNTO 1);
        empty_flag      :out std_logic;
        state           :out state_type_fsm1;
        next_state      :out state_type_fsm1;
        cnt_out         :out NATURAL range 0 to width) ; 
END ENTITY fsm1 ;

ARCHITECTURE arch_fsm1 of fsm1 IS
  signal state_signal       : state_type_fsm1;
  signal next_state_signal  : state_type_fsm1;
  signal d_reg              : std_logic_vector(width-1 downto 0);
  signal cnt                : NATURAL range 0 to width;
  signal empty_flag_signal  : std_logic;
  signal cnt_delay1         : NATURAL range 0 to width;
    
  begin   
    state       <=  state_signal;
    next_state  <=  next_state_signal;
    cnt_out     <=  cnt;
    data        <=  d_reg;
    empty_flag  <=  empty_flag_signal;   
          
    cnt_proc:
    process(clk,reset) begin
      if rising_edge(clk) then
        if (reset = '1') then 
          cnt         <= width;
          cnt_delay1  <= width;
        else
          if (start = '1' and state_signal = fsm1_eat_state and cnt/=0 and empty_flag_signal = '0') then
            cnt         <= cnt-1;
            cnt_delay1  <= cnt;
          else
            cnt         <= width;
            cnt_delay1  <= width;
          end if;
        end if;
      end if;
    end process cnt_proc;
       
    empty_flag_signal_proc:
    process(clk,reset) begin
      if rising_edge(clk) then
        if (reset = '1') then
          empty_flag_signal <= '0';
        else
          if (cnt = 0) then
            empty_flag_signal <= '1';
          end if;
          
        end if;
      end if;
    end process empty_flag_signal_proc;
      
    state_transition_proc:
    process(clk,reset) begin
      if rising_edge(clk) then
        if (reset='1') then
          state_signal <= idle_state;
        elsif (SPI_clk_enable = '1') then
          state_signal <= next_state_signal;
        else 
          state_signal <= state_signal;
        end if;
      end if;
    end process state_transition_proc;
  
    state_flow_proc:
    process(state_signal,load,cnt) begin
      case state_signal is
      when idle_state =>
        if (load = '1') then
          next_state_signal <= fsm1_eat_state;
        else
          next_state_signal <= idle_state;
        end if;
      when fsm1_eat_state =>
        if (cnt = 1) then
          next_state_signal <= end_state;
        --else 
          --next_state_signal <= fsm1_eat_state;
        end if;
      when end_state  =>
        next_state_signal   <= idle_state;
      end case;
    end process state_flow_proc ;
      
    assignment_proc:
    process(state_signal,start,cnt,load) begin
      s <= '0';
      case state_signal is 
      when idle_state =>
        s <= '0';
      when fsm1_eat_state =>
        if (load = '1') then
          d_reg <= din;
        end if;
        if (start = '1') then
          s <= d_reg(cnt_delay1-1);
        else 
          s <= '0';
        end if;
      when end_state =>
        if (cnt = 0) then
          s <= d_reg(cnt_delay1-1);
        else
          s <= '0';
        end if;
      end case;
    end process assignment_proc;
    
  done_proc:
  process(clk,reset) begin
    if rising_edge(clk) then
      if (reset = '1') then 
        done <= '1';
      else
        if (load ='1') then
          done <= '0';
        end if;
        if (cnt = 0) then
          done <= '1';
        end if;
      end if;
    end if;
  end process done_proc;
        
    
    
end architecture;
          
          
    
    
  
  
