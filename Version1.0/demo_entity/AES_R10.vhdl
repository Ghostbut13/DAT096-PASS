
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.mlhdlc_aes_fixpt_pkg.ALL;

ENTITY AES_R10 IS
  PORT( clk                             :   IN    std_logic;
        reset                           :   IN    std_logic;
        clk_enable                      :   IN    std_logic;
        s_2                             :   IN    vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
        kkkkkkk                         :   IN    vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
        ce_out                          :   OUT   std_logic;
        
        ciphertext                      :   OUT   vector_of_std_logic_vector8(0 TO 15);  -- ufix8 [16]
        data_out64_1                    :   out   std_logic_vector(63 downto 0);
        data_out64_2                    :   out   std_logic_vector(63 downto 0)
        );
END AES_R10;


ARCHITECTURE rtl OF AES_R10 IS

  -- Signals
  SIGNAL enb                            : std_logic;
  SIGNAL s1_1                           : vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
  SIGNAL ciphertext_tmp                 : vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
  SIGNAL p1ciphertext_s_out             : vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
  signal buffer_reg64_1                 : std_logic_vector(63 downto 0);
  signal buffer_reg64_2                 : std_logic_vector(63 downto 0);
  signal cnt_read_cip                   : integer;
  
BEGIN

  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  -- First round
  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  enb <= clk_enable;

  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  -- Final round
  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  -- --p2_output : PROCESS (s_2)
  p2_output : PROCESS (s_2)
    VARIABLE s11 : vector_of_unsigned8(0 TO 15);
    VARIABLE i_02 : unsigned(2 DOWNTO 0);
    VARIABLE j_01 : unsigned(2 DOWNTO 0);
    VARIABLE add_temp2 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_02 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_110 : vector_of_unsigned8(0 TO 3);
    VARIABLE sub_cast2 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_27 : vector_of_unsigned8(0 TO 3);
    VARIABLE sub_cast_02 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_32 : vector_of_unsigned8(0 TO 3);
    VARIABLE sub_cast_110 : vector_of_signed32(0 TO 3);
  BEGIN
      i_02 := to_unsigned(16#0#, 3);
      j_01 := to_unsigned(16#0#, 3);
      s11 := (OTHERS => to_unsigned(16#00#, 8));

      FOR i2 IN 0 TO 3 LOOP
        add_temp2(i2) := to_signed(i2 + 1, 32);
        i_02 := unsigned(add_temp2(i2)(2 DOWNTO 0));

        FOR j1 IN 0 TO 3 LOOP
          add_temp_02(j1) := to_signed(j1 + 1, 32);
          j_01 := unsigned(add_temp_02(j1)(2 DOWNTO 0));
          add_temp_110(j1) := resize((resize(i_02, 4) - to_unsigned(16#1#, 4)) * to_unsigned(16#4#, 3), 8) + resize(j_01, 8);
          sub_cast2(j1) := signed(resize(add_temp_110(j1), 32));
          add_temp_27(j1) := resize((resize(i_02, 4) - to_unsigned(16#1#, 4)) * to_unsigned(16#4#, 3), 8) + resize(j_01, 8);
          sub_cast_02(j1) := signed(resize(add_temp_27(j1), 32));
          -- add_temp_32(j1) := s_2(to_integer(sub_cast_02(j1) - 1)) + to_unsigned(16#01#, 8);
          -- sub_cast_110(j1) := signed(resize(add_temp_32(j1), 32));
          add_temp_32(j1) := s_2(to_integer(sub_cast_02(j1) - 1));
          sub_cast_110(j1) := signed(resize(add_temp_32(j1), 32)+  to_unsigned(16#01#, 32));
          s11(to_integer(sub_cast2(j1) - 1)) := Sbox(to_integer(sub_cast_110(j1) - 1));
        END LOOP;
      END LOOP;
    s1_1 <= s11;
  END PROCESS p2_output;

  p1ciphertext_s_out(0) <= s1_1(0);
  p1ciphertext_s_out(1) <= s1_1(1);
  p1ciphertext_s_out(2) <= s1_1(2);
  p1ciphertext_s_out(3) <= s1_1(3);
  p1ciphertext_s_out(4) <= s1_1(5);
  p1ciphertext_s_out(5) <= s1_1(6);
  p1ciphertext_s_out(6) <= s1_1(7);
  p1ciphertext_s_out(7) <= s1_1(4);
  p1ciphertext_s_out(8) <= s1_1(10);
  p1ciphertext_s_out(9) <= s1_1(11);
  p1ciphertext_s_out(10) <= s1_1(8);
  p1ciphertext_s_out(11) <= s1_1(9);
  p1ciphertext_s_out(12) <= s1_1(15);
  p1ciphertext_s_out(13) <= s1_1(12);
  p1ciphertext_s_out(14) <= s1_1(13);
  p1ciphertext_s_out(15) <= s1_1(14);

  out_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '0' THEN
    -- ciphertext_tmp                     <= (OTHERS => to_unsigned(16#00#, 8));
    -- p1ciphertext_s_out                 <= (OTHERS => to_unsigned(16#00#, 8));
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        FOR t_0 IN 0 TO 15 loop
          ciphertext_tmp(t_0) <= p1ciphertext_s_out(t_0) XOR kkkkkkk(t_0);
          ciphertext(t_0) <= std_logic_vector(ciphertext_tmp(t_0));
        end loop;
      END IF;
    END IF;
  END PROCESS out_process;



   
  buffer_out: process (clk, reset) is
  begin  -- process buffer_out
    if reset = '0' then                 -- asynchronous reset (active low)
      buffer_reg64_1 <= x"0000000000000000" ;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if(clk_enable='1' and cnt_read_cip=2) then
        buffer_reg64_1(7 downto 0)      <= std_logic_vector(ciphertext_tmp(0));
        buffer_reg64_1(15 downto 8)     <= std_logic_vector(ciphertext_tmp(1));
        buffer_reg64_1(23 downto 16)    <= std_logic_vector(ciphertext_tmp(2));
        buffer_reg64_1(31 downto 24)    <= std_logic_vector(ciphertext_tmp(3));
        buffer_reg64_1(39 downto 32)    <= std_logic_vector(ciphertext_tmp(4));
        buffer_reg64_1(47 downto 40)    <= std_logic_vector(ciphertext_tmp(5));
        buffer_reg64_1(55 downto 48)    <= std_logic_vector(ciphertext_tmp(6));
        buffer_reg64_1(63 downto 56)    <= std_logic_vector(ciphertext_tmp(7));
        buffer_reg64_2(7 downto 0)      <= std_logic_vector(ciphertext_tmp(8));
        buffer_reg64_2(15 downto 8)     <= std_logic_vector(ciphertext_tmp(9));
        buffer_reg64_2(23 downto 16)    <= std_logic_vector(ciphertext_tmp(10));
        buffer_reg64_2(31 downto 24)    <= std_logic_vector(ciphertext_tmp(11));
        buffer_reg64_2(39 downto 32)    <= std_logic_vector(ciphertext_tmp(12));
        buffer_reg64_2(47 downto 40)    <= std_logic_vector(ciphertext_tmp(13));
        buffer_reg64_2(55 downto 48)    <= std_logic_vector(ciphertext_tmp(14));
        buffer_reg64_2(63 downto 56)    <= std_logic_vector(ciphertext_tmp(15));
      else
      -- buffer_reg64_1 <= x"0000000000000000" ;
      end if;
    end if;
  end process buffer_out;

  push_data_out: process (clk, reset) is
  begin  -- process push_data_out
    if reset = '0' then                 -- asynchronous reset (active low)
      cnt_read_cip <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if clk_enable='1' then
        cnt_read_cip <= cnt_read_cip+1;
      else
        cnt_read_cip <= 0;
      end if;
    end if;
  end process push_data_out;

  data_out64_1 <= buffer_reg64_1;
  data_out64_2 <= buffer_reg64_2;


  ce_out <= clk_enable;

END rtl;

