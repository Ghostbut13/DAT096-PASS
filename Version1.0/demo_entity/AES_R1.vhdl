
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.mlhdlc_aes_fixpt_pkg.ALL;

ENTITY AES_R1 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        clk_enable                        :   IN    std_logic;
        plaintext                         :   IN    vector_of_std_logic_vector8(0 TO 15);  -- ufix8 [16]
        cipherkey                         :   IN    vector_of_std_logic_vector8(0 TO 15);  -- ufix8 [16]
        ce_out                            :   OUT   std_logic;
        k_1                               :   OUT   vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
        s                                 :   OUT   vector_of_unsigned8(0 TO 15)  -- ufix8 [16]
        );
END AES_R1;


ARCHITECTURE rtl OF AES_R1 IS

  -- Signals
  SIGNAL enb                              : std_logic;
  -- SIGNAL tmp                              : vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
  SIGNAL plaintext_unsigned               : vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
  SIGNAL cipherkey_unsigned               : vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
  SIGNAL tmp_1                            : vector_of_signed32(0 TO 3);  -- int32 [4]
  SIGNAL p9tmp_iA                         : vector_of_unsigned9(0 TO 3);  -- uint8 [4]
  SIGNAL p9tmp_sub_cast                   : vector_of_signed16(0 TO 3);  -- int16 [4]
  SIGNAL tmp_2                            : vector_of_unsigned8(0 TO 3);  -- ufix8 [4]
  SIGNAL k_temp2                          : vector_of_unsigned8(0 TO 3);  -- ufix8 [4]
  SIGNAL k                                : vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
  -- SIGNAL sss                              : vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
BEGIN

  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  -- First round
  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  enb <= clk_enable;
  
  
  delayMatch_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '0' THEN
      plaintext_unsigned    <= (OTHERS => to_unsigned(16#00#, 8));
      cipherkey_unsigned    <= (OTHERS => to_unsigned(16#00#, 8));
      -- cipherkey_1           <= (OTHERS => to_unsigned(16#00#, 8));
      -- sss       <= (OTHERS => to_unsigned(16#00#, 8));
      -- tmp     <= (OTHERS => to_unsigned(16#00#, 8));
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        FOR t_0 IN 0 TO 15 loop
          plaintext_unsigned(t_0) <= unsigned(plaintext(t_0));
          cipherkey_unsigned(t_0) <= unsigned(cipherkey(t_0));
          -- cipherkey_1(t_0) <= cipherkey_unsigned(t_0);
          s(t_0) <= unsigned(plaintext(t_0) XOR cipherkey(t_0));
        end loop;
      END IF;
    END IF;
  END PROCESS delayMatch_process;
  
  -- Substitute RotWord with SBox
  -- Pick the last column and rotate down by 1 (i.e. RotWord)
  p9tmp_iA(0) <= resize(cipherkey_unsigned(7),9) + to_unsigned(16#01#, 9);
  p9tmp_iA(1) <= resize(cipherkey_unsigned(11),9) + to_unsigned(16#01#, 9);
  p9tmp_iA(2) <= resize(cipherkey_unsigned(15),9) + to_unsigned(16#01#, 9);
  p9tmp_iA(3) <= resize(cipherkey_unsigned(3),9) + to_unsigned(16#01#, 9);
  tmp_1(0) <= resize(signed(resize(p9tmp_iA(0), 16))-1,32);
  tmp_1(1) <= resize(signed(resize(p9tmp_iA(1), 16))-1,32);
  tmp_1(2) <= resize(signed(resize(p9tmp_iA(2), 16))-1,32);
  tmp_1(3) <= resize(signed(resize(p9tmp_iA(3), 16))-1,32);
  tmp_2(0) <= Sbox(to_integer(tmp_1(0)));
  tmp_2(1) <= Sbox(to_integer(tmp_1(1)));
  tmp_2(2) <= Sbox(to_integer(tmp_1(2)));
  tmp_2(3) <= Sbox(to_integer(tmp_1(3)));

  k_temp2(0) <= tmp_2(0) XOR to_unsigned(16#01#, 8);
  k_temp2(1 TO 3) <= tmp_2(1 TO 3);
  k(0) <= k_temp2(0) XOR cipherkey_unsigned(0);
  k(4) <= k_temp2(1) XOR cipherkey_unsigned(4);
  k(8) <= k_temp2(2) XOR cipherkey_unsigned(8);
  k(12) <= k_temp2(3) XOR cipherkey_unsigned(12);

  -- s <= sss;
 
  -- Calculated the rest columns of the new round key
  -- p6_output : PROCESS (cipherkey_1, k)
  p6_output : PROCESS (k)
    VARIABLE k1 : vector_of_unsigned8(0 TO 15);
    VARIABLE i_0 : unsigned(2 DOWNTO 0);
    VARIABLE add_temp : vector_of_signed32(0 TO 2);
    VARIABLE sub_cast : vector_of_signed32(0 TO 2);
    VARIABLE sub_cast_0 : vector_of_signed32(0 TO 2);
    VARIABLE sub_temp : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_1 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_0 : vector_of_unsigned5(0 TO 2);
    VARIABLE sub_cast_2 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_1 : vector_of_unsigned5(0 TO 2);
    VARIABLE sub_cast_3 : vector_of_signed32(0 TO 2);
    VARIABLE sub_temp_0 : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_4 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_2 : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_5 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_3 : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_6 : vector_of_signed32(0 TO 2);
    VARIABLE sub_temp_1 : vector_of_unsigned7(0 TO 2);
    VARIABLE sub_cast_7 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_4 : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_8 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_5 : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_9 : vector_of_signed32(0 TO 2);
    VARIABLE sub_temp_2 : vector_of_unsigned7(0 TO 2);
    VARIABLE sub_cast_10 : vector_of_signed32(0 TO 2);
  BEGIN
    if enb='1' then
      i_0 := to_unsigned(16#0#, 3);
      k1 := k;

      FOR i IN 0 TO 2 LOOP
        add_temp(i) := to_signed(i + 2, 32);
        i_0 := unsigned(add_temp(i)(2 DOWNTO 0));
        sub_cast(i) := signed(resize(i_0, 32));
        sub_cast_0(i) := signed(resize(i_0, 32));
        sub_temp(i) := resize(i_0, 6) - to_unsigned(16#01#, 6);
        sub_cast_1(i) := signed(resize(sub_temp(i), 32));
        k1(to_integer(sub_cast(i) - 1)) := cipherkey_unsigned(to_integer(sub_cast_0(i) - 1)) XOR k1(to_integer(sub_cast_1(i) - 1));
        add_temp_0(i) := resize(i_0, 5) + to_unsigned(16#04#, 5);
        sub_cast_2(i) := signed(resize(add_temp_0(i), 32));
        add_temp_1(i) := resize(i_0, 5) + to_unsigned(16#04#, 5);
        sub_cast_3(i) := signed(resize(add_temp_1(i), 32));
        sub_temp_0(i) := resize(resize(i_0, 5) + to_unsigned(16#04#, 5), 6) - to_unsigned(16#01#, 6);
        sub_cast_4(i) := signed(resize(sub_temp_0(i), 32));
        k1(to_integer(sub_cast_2(i) - 1)) := cipherkey_unsigned(to_integer(sub_cast_3(i) - 1)) XOR k1(to_integer(sub_cast_4(i) - 1));
        add_temp_2(i) := resize(i_0, 6) + to_unsigned(16#08#, 6);
        sub_cast_5(i) := signed(resize(add_temp_2(i), 32));
        add_temp_3(i) := resize(i_0, 6) + to_unsigned(16#08#, 6);
        sub_cast_6(i) := signed(resize(add_temp_3(i), 32));
        sub_temp_1(i) := resize(resize(i_0, 6) + to_unsigned(16#08#, 6), 7) - to_unsigned(16#01#, 7);
        sub_cast_7(i) := signed(resize(sub_temp_1(i), 32));
        k1(to_integer(sub_cast_5(i) - 1)) := cipherkey_unsigned(to_integer(sub_cast_6(i) - 1)) XOR k1(to_integer(sub_cast_7(i) - 1));
        add_temp_4(i) := resize(i_0, 6) + to_unsigned(16#0C#, 6);
        sub_cast_8(i) := signed(resize(add_temp_4(i), 32));
        add_temp_5(i) := resize(i_0, 6) + to_unsigned(16#0C#, 6);
        sub_cast_9(i) := signed(resize(add_temp_5(i), 32));
        sub_temp_2(i) := resize(resize(i_0, 6) + to_unsigned(16#0C#, 6), 7) - to_unsigned(16#01#, 7);
        sub_cast_10(i) := signed(resize(sub_temp_2(i), 32));
        k1(to_integer(sub_cast_8(i) - 1)) := cipherkey_unsigned(to_integer(sub_cast_9(i) - 1)) XOR k1(to_integer(sub_cast_10(i) - 1));
      END LOOP;
      k_1 <= k1;
      
    end if;
  END PROCESS p6_output;



  
  ce_out <= clk_enable;

END rtl;

