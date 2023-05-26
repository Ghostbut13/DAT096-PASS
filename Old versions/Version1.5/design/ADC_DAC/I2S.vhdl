LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY I2S IS
  PORT  (
    bclk:IN STD_LOGIC ;
    --clk  : IN STD_LOGIC;
    start:IN STD_LOGIC ;
    reset:IN STD_LOGIC ;
    fsync:IN STD_LOGIC ;
    DIN : IN STD_LOGIC;
    B_state : out std_logic_vector (2 downto 0);
    L1_out : out std_logic_vector (15 downto 0);
    L2_out : out std_logic_vector (15 downto 0);
    R1_out : out std_logic_vector (15 downto 0);
    R2_out : out std_logic_vector (15 downto 0)
--		SDOUT : OUT std_logic
    );
END ENTITY I2S;

ARCHITECTURE ARCH_I2S OF I2S IS
  constant WORD_LENGHT : integer := 16;
  TYPE state_type IS (idle_state, left_channel_1_state, left_channel_2_state, idle_left_channel,
                      right_channel_1_state, right_channel_2_state, idle_right_channel);

  SIGNAL present_state_signal:state_type;
  SIGNAL next_state_signal:state_type;

-- Adding thoese variables to help us counting the bits that are printed out
  SIGNAL stored_data_1: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  SIGNAL stored_data_2: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  SIGNAL stored_data_3: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);
  SIGNAL stored_data_4: STD_LOGIC_VECTOR (WORD_LENGHT-1 DOWNTO 0);


  SIGNAL counter1: NATURAL range 0 to WORD_LENGHT := 0;
  SIGNAL counter2: NATURAL range 0 to WORD_LENGHT := 0;
  SIGNAL counter3: NATURAL range 0 to WORD_LENGHT := 0;
  SIGNAL counter4: NATURAL range 0 to WORD_LENGHT := 0;

  signal B_state_signal : std_logic_vector (2 downto 0);
  signal L1_out_signal: std_logic_vector (15 downto 0);
  signal L2_out_signal: std_logic_vector (15 downto 0);
  signal R1_out_signal: std_logic_vector (15 downto 0);
  signal R2_out_signal: std_logic_vector (15 downto 0);

  
  signal L1_out_signal_converter: std_logic_vector (15 downto 0);
  
BEGIN


-- state changing is determined by bclk 
  state_transition_proc:
  PROCESS(bclk, reset) --rstn
  BEGIN
    IF (reset = '0') THEN
      present_state_signal <= idle_state;
      
    ELSIF rising_edge(bclk) THEN --prev falling_edge
      IF (start = '1') THEN
        present_state_signal <= next_state_signal;
      else 
        present_state_signal <= idle_state;
      END IF;
    END IF;
  END PROCESS state_transition_proc;
  

-- flow of the state machine
  state_flow_proc:
  PROCESS(present_state_signal, start,reset, counter1, counter2, counter3, counter4, fsync)
  BEGIN 
    next_state_signal <= present_state_signal;
    case present_state_signal is
      when idle_state =>
        if (start = '1') and (reset /= '0') then
          if fsync='0' then
            next_state_signal <= left_channel_1_state;
          end if;
        end if;
      when left_channel_1_state => 
        if (counter1 = WORD_LENGHT-1) then
          next_state_signal <= left_channel_2_state;
        end if;

      when left_channel_2_state =>
        if (counter2 = WORD_LENGHT-1) then
          next_state_signal<= idle_left_channel;
        end if;
      when idle_left_channel =>
        if fsync='1' then
          next_state_signal <= right_channel_1_state;
        end if;
      when right_channel_1_state => 
        if (counter3 = WORD_LENGHT-1) then
          next_state_signal <= right_channel_2_state;
        end if;
      when right_channel_2_state =>
        if (counter4 = WORD_LENGHT-1) then
          next_state_signal <= idle_right_channel;
        end if;
        
      when idle_right_channel =>
        if fsync='0' then
          next_state_signal <= left_channel_1_state;
        end if;
    end case;
  end process state_flow_proc;
  
  
  -- Counter process that checks for falling edge of bclk to determine where the state machine is
  counter_proc:
  process (bclk,reset, present_state_signal)
  begin
    if rising_edge(bclk) then --prev falling_edge
      if reset = '0' or present_state_signal = idle_state then
        counter1 <= 0;
        counter2 <= 0;
        counter3 <= 0;
        counter4 <= 0;
        stored_data_1<= (others => '0');
        stored_data_2<= (others => '0');
        stored_data_3<= (others => '0');
        stored_data_4<= (others => '0');
        B_state_signal <= "111";
        
        
        
      elsif present_state_signal = left_channel_1_state then
        B_state_signal <= "001";
        if counter1 <= WORD_LENGHT-1 then 
          stored_data_1((WORD_LENGHT-1) - counter1) <=  DIN;
          counter1 <= counter1 + 1;
        else 
          counter1 <= 0;
        end if;
        
      elsif present_state_signal = left_channel_2_state then
        counter1 <= 0;
        B_state_signal <= "010";
        if counter2 <= WORD_LENGHT-1 then 
          stored_data_2((WORD_LENGHT-1) - counter2) <=  DIN;
          counter2 <= counter2 + 1;
        else 
          counter2 <= 0;
        end if;
        
      elsif present_state_signal = idle_left_channel then
        B_state_signal <= "011";
        counter2 <= 0;
        
      elsif present_state_signal = right_channel_1_state then
        B_state_signal <= "100";
        if counter3 <= WORD_LENGHT-1 then 
          stored_data_3((WORD_LENGHT-1) - counter3) <=  DIN;
          counter3 <= counter3 + 1;
        else 
          counter3 <= 0;
        end if;
        
      elsif present_state_signal = right_channel_2_state then
        B_state_signal <= "101";
        counter3 <= 0;
        if counter4 <= WORD_LENGHT-1 then 
          stored_data_4((WORD_LENGHT-1) - counter4) <=  DIN;
          counter4 <= counter4 + 1;
        else 
          counter4 <= 0;
        end if;
      elsif present_state_signal = idle_right_channel then
        B_state_signal <= "110";
        counter4 <= 0;
      end if;
    end if;
  end process;

  assignement_procc:
  process(fsync,reset)
  begin
    if reset = '0' then
      L1_out_signal <= (OTHERS => '0');
      L2_out_signal <= (OTHERS => '0');
      R1_out_signal <= (OTHERS => '0');
      R2_out_signal <= (OTHERS => '0');
    elsif falling_edge(fsync) then
      L1_out_signal <= stored_data_1;
      L2_out_signal <= stored_data_2;
      R1_out_signal <= stored_data_3;
      R2_out_signal <= stored_data_4;
    end if;
  end process;


  -- --L1_out <= std_logic_vector(resize(-signed(resize(unsigned(L1_out_signal)), 17)),16);
  L1_out <= std_logic_vector(unsigned(L1_out_signal)+to_unsigned(16#8000#,16));

  --L1_out <= L1_out_signal;
  L2_out <= L2_out_signal;
  R1_out <= R1_out_signal;
  R2_out <= R2_out_signal;
  B_state <= B_state_signal;

END ARCH_I2S;
