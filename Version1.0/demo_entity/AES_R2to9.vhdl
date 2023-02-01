
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.mlhdlc_aes_fixpt_pkg.ALL;

ENTITY AES_R2to9 IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        clk_enable                        :   IN    std_logic;
        k_1                               :   IN    vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
        s                                 :   IN    vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
        ce_out                            :   OUT   std_logic;
        kkkkkkk                           :   OUT   vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
        s_2                               :   out   vector_of_unsigned8(0 TO 15)  -- ufix8 [16]
        
        );
END AES_R2to9;


ARCHITECTURE rtl OF AES_R2to9 IS

  -- Signals
  signal enb: std_logic;
  SIGNAL tmp : vector_of_unsigned8(0 TO 15) := (OTHERS => to_unsigned(16#00#, 8));  -- ufix8 [16]

BEGIN

  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  -- First round
  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  enb <= clk_enable;
  
  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  -- Main round state containing four steps:
  -- 1. SubBytes
  -- 2. ShiftRows
  -- 3. MixColumns
  -- 4. Xor text with key 
  -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  -- p4_output : PROCESS (k_1, s_1, tmp)
  p4_output : PROCESS (k_1)
    VARIABLE k2 : vector_of_unsigned8(0 TO 15);
    VARIABLE s_out : vector_of_unsigned8(0 TO 15);
    VARIABLE iA : vector_of_unsigned9(0 TO 4);
    VARIABLE s1 : vector_of_unsigned8(0 TO 15);
    VARIABLE d : vector_of_unsigned8(0 TO 15);
    VARIABLE e : vector_of_unsigned8(0 TO 3);
    VARIABLE s_out_0 : vector_of_unsigned8(0 TO 15);
    VARIABLE s2 : vector_of_unsigned8(0 TO 15);
    VARIABLE k_0 : vector_of_unsigned8(0 TO 15);
    VARIABLE k_temp1 : vector_of_unsigned8(0 TO 3);
    VARIABLE k_temp21 : vector_of_unsigned8(0 TO 3);
    VARIABLE i_3 : unsigned(2 DOWNTO 0);
    VARIABLE j_0 : unsigned(2 DOWNTO 0);
    VARIABLE i_4 : unsigned(2 DOWNTO 0);
    VARIABLE i_5 : unsigned(2 DOWNTO 0);
    VARIABLE add_temp1 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_01 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_11 : vector_of_unsigned8(0 TO 3);
    VARIABLE sub_cast1 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_21 : vector_of_unsigned8(0 TO 3);
    VARIABLE sub_cast_01 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_31 : vector_of_unsigned8(0 TO 3);
    VARIABLE sub_cast_11 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_41 : vector_of_signed32(0 TO 3);
    VARIABLE sub_cast_21 : vector_of_signed32(0 TO 3);
    VARIABLE sub_cast_31 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_51 : vector_of_unsigned5(0 TO 3);
    VARIABLE sub_cast_41 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_6 : vector_of_unsigned6(0 TO 3);
    VARIABLE sub_cast_51 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_7 : vector_of_unsigned6(0 TO 3);
    VARIABLE sub_cast_61 : vector_of_signed32(0 TO 3);
    VARIABLE sub_cast_71 : vector_of_signed32(0 TO 3);
    VARIABLE sub_cast_81 : vector_of_signed32(0 TO 3);
    VARIABLE sub_cast_91 : vector_of_signed32(0 TO 3);
    VARIABLE sub_cast_101 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_8 : vector_of_unsigned5(0 TO 3);
    VARIABLE sub_cast_111 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_9 : vector_of_unsigned5(0 TO 3);
    VARIABLE sub_cast_12 : vector_of_signed32(0 TO 3);
    VARIABLE sub_cast_13 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_10 : vector_of_unsigned5(0 TO 3);
    VARIABLE sub_cast_14 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_111 : vector_of_unsigned5(0 TO 3);
    VARIABLE sub_cast_15 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_12 : vector_of_unsigned6(0 TO 3);
    VARIABLE sub_cast_16 : vector_of_signed32(0 TO 3);
    VARIABLE sub_cast_17 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_13 : vector_of_unsigned6(0 TO 3);
    VARIABLE sub_cast_18 : vector_of_signed32(0 TO 3);
    VARIABLE sub_cast_19 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_14 : vector_of_unsigned6(0 TO 3);
    VARIABLE sub_cast_20 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_15 : vector_of_unsigned6(0 TO 3);
    VARIABLE sub_cast_211 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_16 : vector_of_unsigned6(0 TO 3);
    VARIABLE sub_cast_22 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_17 : vector_of_unsigned6(0 TO 3);
    VARIABLE sub_cast_23 : vector_of_signed32(0 TO 3);
    VARIABLE sub_cast_24 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_18 : vector_of_unsigned6(0 TO 3);
    VARIABLE sub_cast_25 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_19 : vector_of_unsigned6(0 TO 3);
    VARIABLE sub_cast_26 : vector_of_signed32(0 TO 3);
    VARIABLE sub_cast_27 : vector_of_signed32(0 TO 3);
    VARIABLE add_temp_20 : vector_of_signed32(0 TO 2);
    VARIABLE sub_cast_28 : vector_of_signed32(0 TO 2);
    VARIABLE sub_cast_29 : vector_of_signed32(0 TO 2);
    VARIABLE sub_temp1 : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_30 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_211 : vector_of_unsigned5(0 TO 2);
    VARIABLE sub_cast_311 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_22 : vector_of_unsigned5(0 TO 2);
    VARIABLE sub_cast_32 : vector_of_signed32(0 TO 2);
    VARIABLE sub_temp_01 : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_33 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_23 : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_34 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_24 : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_35 : vector_of_signed32(0 TO 2);
    VARIABLE sub_temp_11 : vector_of_unsigned7(0 TO 2);
    VARIABLE sub_cast_36 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_25 : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_37 : vector_of_signed32(0 TO 2);
    VARIABLE add_temp_26 : vector_of_unsigned6(0 TO 2);
    VARIABLE sub_cast_38 : vector_of_signed32(0 TO 2);
    VARIABLE sub_temp_21 : vector_of_unsigned7(0 TO 2);
    VARIABLE sub_cast_39 : vector_of_signed32(0 TO 2);
    variable index_i1 : integer;


    variable index_i_01 : integer := 0;
    variable index_j : unsigned(7 downto 0);


    
  BEGIN
   
    i_3 := to_unsigned(16#0#, 3);
    j_0 := to_unsigned(16#0#, 3);
    i_4 := to_unsigned(16#0#, 3);
    i_5 := to_unsigned(16#0#, 3);
    k2 := k_1;
    -- s2 := s_1;
    s2 := s;

    -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    -- The SubBytes step
    -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    FOR i1 IN 0 TO 8 LOOP -- Second to tenth round
      
      s1 := (OTHERS => to_unsigned(16#00#, 8));

      FOR i_01 IN 0 TO 3 LOOP
        add_temp1(i_01) := to_signed(i_01 + 1, 32);
        i_3 := unsigned(add_temp1(i_01)(2 DOWNTO 0));
        FOR j IN 0 TO 3 LOOP
          add_temp_01(j) := to_signed(j + 1, 32);
          j_0 := unsigned(add_temp_01(j)(2 DOWNTO 0));
          add_temp_11(j) := resize((resize(i_3, 4) - to_unsigned(16#1#, 4)) * to_unsigned(16#4#, 3), 8) + resize(j_0, 8);
          sub_cast1(j)   := signed(resize(add_temp_11(j), 32));
          add_temp_21(j) := resize((resize(i_3, 4) - to_unsigned(16#1#, 4)) * to_unsigned(16#4#, 3), 8) + resize(j_0, 8);
          sub_cast_01(j) := signed(resize(add_temp_21(j), 32));
          add_temp_31(j) := s2(to_integer(sub_cast_01(j) - 1)) ;
          sub_cast_11(j) := signed(resize(add_temp_31(j), 32)+ to_unsigned(16#01#, 32));
          s1(to_integer(sub_cast1(j) - 1)) := Sbox(to_integer(sub_cast_11(j) - 1));
          --report integer'image(to_integer(sub_cast_11(j) - 1));
          index_i_01 := index_i_01+1;
        END LOOP;       
      END LOOP;
      
      -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      -- The ShiftRows step
      -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      s_out(0) := s1(0);
      s_out(1) := s1(1);
      s_out(2) := s1(2);
      s_out(3) := s1(3);
      s_out(4) := s1(5);
      s_out(5) := s1(6);
      s_out(6) := s1(7);
      s_out(7) := s1(4);
      s_out(8) := s1(10);
      s_out(9) := s1(11);
      s_out(10) := s1(8);
      s_out(11) := s1(9);
      s_out(12) := s1(15);
      s_out(13) := s1(12);
      s_out(14) := s1(13);
      s_out(15) := s1(14);

      -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      -- The MixColumns step
      -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      FOR m IN 0 TO 15 LOOP
        d(m) := s_out(m) sll 1;
        if s_out(m)(7)='1' then
          d(m) := d(m) xor x"1b";
        else
          d(m) := d(m);
        end if;          
      END LOOP;
      e := (OTHERS => to_unsigned(16#00#, 8));
      s_out_0 := (OTHERS => to_unsigned(16#00#, 8));
      FOR i_1 IN 0 TO 3 LOOP
        add_temp_41(i_1) := to_signed(i_1 + 1, 32);
        i_4 := unsigned(add_temp_41(i_1)(2 DOWNTO 0));
        sub_cast_21(i_1) := signed(resize(i_4, 32));
        sub_cast_31(i_1) := signed(resize(i_4, 32));
        add_temp_51(i_1) := resize(i_4, 5) + to_unsigned(16#04#, 5);
        sub_cast_41(i_1) := signed(resize(add_temp_51(i_1), 32));
        add_temp_6(i_1) := resize(i_4, 6) + to_unsigned(16#08#, 6);
        sub_cast_51(i_1) := signed(resize(add_temp_6(i_1), 32));
        add_temp_7(i_1) := resize(i_4, 6) + to_unsigned(16#0C#, 6);
        sub_cast_61(i_1) := signed(resize(add_temp_7(i_1), 32));
        e(to_integer(sub_cast_21(i_1) - 1)) := (s_out(to_integer(sub_cast_31(i_1) - 1)) XOR s_out(to_integer(sub_cast_41(i_1) - 1))) XOR (s_out(to_integer(sub_cast_51(i_1) - 1)) XOR s_out(to_integer(sub_cast_61(i_1) - 1)));
        sub_cast_71(i_1) := signed(resize(i_4, 32));
        sub_cast_81(i_1) := signed(resize(i_4, 32));
        sub_cast_91(i_1) := signed(resize(i_4, 32));
        sub_cast_101(i_1) := signed(resize(i_4, 32));
        add_temp_8(i_1) := resize(i_4, 5) + to_unsigned(16#04#, 5);
        sub_cast_111(i_1) := signed(resize(add_temp_8(i_1), 32));
        s_out_0(to_integer(sub_cast_71(i_1) - 1)) := (e(to_integer(sub_cast_81(i_1) - 1)) XOR s_out(to_integer(sub_cast_91(i_1) - 1))) XOR (d(to_integer(sub_cast_101(i_1) - 1)) XOR d(to_integer(sub_cast_111(i_1) - 1)));
        add_temp_9(i_1) := resize(i_4, 5) + to_unsigned(16#04#, 5);
        sub_cast_12(i_1) := signed(resize(add_temp_9(i_1), 32));
        sub_cast_13(i_1) := signed(resize(i_4, 32));
        add_temp_10(i_1) := resize(i_4, 5) + to_unsigned(16#04#, 5);
        sub_cast_14(i_1) := signed(resize(add_temp_10(i_1), 32));
        add_temp_111(i_1) := resize(i_4, 5) + to_unsigned(16#04#, 5);
        sub_cast_15(i_1) := signed(resize(add_temp_111(i_1), 32));
        add_temp_12(i_1) := resize(i_4, 6) + to_unsigned(16#08#, 6);
        sub_cast_16(i_1) := signed(resize(add_temp_12(i_1), 32));
        s_out_0(to_integer(sub_cast_12(i_1) - 1)) := (e(to_integer(sub_cast_13(i_1) - 1)) XOR s_out(to_integer(sub_cast_14(i_1) - 1))) XOR (d(to_integer(sub_cast_15(i_1) - 1)) XOR d(to_integer(sub_cast_16(i_1) - 1)));
        add_temp_13(i_1) := resize(i_4, 6) + to_unsigned(16#08#, 6);
        sub_cast_18(i_1) := signed(resize(add_temp_13(i_1), 32));
        sub_cast_19(i_1) := signed(resize(i_4, 32));
        add_temp_14(i_1) := resize(i_4, 6) + to_unsigned(16#08#, 6);
        sub_cast_20(i_1) := signed(resize(add_temp_14(i_1), 32));
        add_temp_15(i_1) := resize(i_4, 6) + to_unsigned(16#08#, 6);
        sub_cast_211(i_1) := signed(resize(add_temp_15(i_1), 32));
        add_temp_16(i_1) := resize(i_4, 6) + to_unsigned(16#0C#, 6);
        sub_cast_22(i_1) := signed(resize(add_temp_16(i_1), 32));
        s_out_0(to_integer(sub_cast_18(i_1) - 1)) := (e(to_integer(sub_cast_19(i_1) - 1)) XOR s_out(to_integer(sub_cast_20(i_1) - 1))) XOR (d(to_integer(sub_cast_211(i_1) - 1)) XOR d(to_integer(sub_cast_22(i_1) - 1)));
        add_temp_17(i_1) := resize(i_4, 6) + to_unsigned(16#0C#, 6);
        sub_cast_23(i_1) := signed(resize(add_temp_17(i_1), 32));
        sub_cast_24(i_1) := signed(resize(i_4, 32));
        add_temp_18(i_1) := resize(i_4, 6) + to_unsigned(16#0C#, 6);
        sub_cast_25(i_1) := signed(resize(add_temp_18(i_1), 32));
        add_temp_19(i_1) := resize(i_4, 6) + to_unsigned(16#0C#, 6);
        sub_cast_26(i_1) := signed(resize(add_temp_19(i_1), 32));
        sub_cast_27(i_1) := signed(resize(i_4, 32));
        s_out_0(to_integer(sub_cast_23(i_1) - 1)) := (e(to_integer(sub_cast_24(i_1) - 1)) XOR s_out(to_integer(sub_cast_25(i_1) - 1))) XOR (d(to_integer(sub_cast_26(i_1) - 1)) XOR d(to_integer(sub_cast_27(i_1) - 1)));
      END LOOP;
      
      FOR t_03 IN 0 TO 15 LOOP
        s2(t_03) := s_out_0(t_03) XOR k2(t_03);
        k_0(t_03) := tmp(t_03);
      END LOOP;

      -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      -- ExtendKeys
      -- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      
      iA(0) := resize(k2(7),9) + to_unsigned(16#01#, 9);
      iA(1) := resize(k2(11),9) + to_unsigned(16#01#, 9);
      iA(2) := resize(k2(15),9) + to_unsigned(16#01#, 9);
      iA(3) := resize(k2(3),9) + to_unsigned(16#01#, 9);
      FOR t_1 IN 0 TO 3 LOOP
        sub_cast_17(t_1) := signed(resize(iA(t_1), 32));
        k_temp1(t_1) := Sbox(to_integer(sub_cast_17(t_1) - 1));
      END LOOP;
      k_temp21(0) := k_temp1(0) XOR Rcon((((i1 + 1) + 1) + 1) - 1);
      k_temp21(1 TO 3) := k_temp1(1 TO 3);
      k_0(0) := k2(0) XOR k_temp21(0);
      k_0(4) := k_temp21(1) XOR k2(4);
      k_0(8) := k_temp21(2) XOR k2(8);
      k_0(12) := k_temp21(3) XOR k2(12);
      FOR i_2 IN 0 TO 2 LOOP
        add_temp_20(i_2) := to_signed(i_2 + 2, 32);
        i_5 := unsigned(add_temp_20(i_2)(2 DOWNTO 0));
        sub_cast_28(i_2) := signed(resize(i_5, 32));
        sub_cast_29(i_2) := signed(resize(i_5, 32));
        sub_temp1(i_2) := resize(i_5, 6) - to_unsigned(16#01#, 6);
        sub_cast_30(i_2) := signed(resize(sub_temp1(i_2), 32));
        k_0(to_integer(sub_cast_28(i_2) - 1)) := k2(to_integer(sub_cast_29(i_2) - 1)) XOR k_0(to_integer(sub_cast_30(i_2) - 1));
        add_temp_211(i_2) := resize(i_5, 5) + to_unsigned(16#04#, 5);
        sub_cast_311(i_2) := signed(resize(add_temp_211(i_2), 32));
        add_temp_22(i_2) := resize(i_5, 5) + to_unsigned(16#04#, 5);
        sub_cast_32(i_2) := signed(resize(add_temp_22(i_2), 32));
        sub_temp_01(i_2) := resize(resize(i_5, 5) + to_unsigned(16#04#, 5), 6) - to_unsigned(16#01#, 6);
        sub_cast_33(i_2) := signed(resize(sub_temp_01(i_2), 32));
        k_0(to_integer(sub_cast_311(i_2) - 1)) := k2(to_integer(sub_cast_32(i_2) - 1)) XOR k_0(to_integer(sub_cast_33(i_2) - 1));
        add_temp_23(i_2) := resize(i_5, 6) + to_unsigned(16#08#, 6);
        sub_cast_34(i_2) := signed(resize(add_temp_23(i_2), 32));
        add_temp_24(i_2) := resize(i_5, 6) + to_unsigned(16#08#, 6);
        sub_cast_35(i_2) := signed(resize(add_temp_24(i_2), 32));
        sub_temp_11(i_2) := resize(resize(i_5, 6) + to_unsigned(16#08#, 6), 7) - to_unsigned(16#01#, 7);
        sub_cast_36(i_2) := signed(resize(sub_temp_11(i_2), 32));
        k_0(to_integer(sub_cast_34(i_2) - 1)) := k2(to_integer(sub_cast_35(i_2) - 1)) XOR k_0(to_integer(sub_cast_36(i_2) - 1));
        add_temp_25(i_2) := resize(i_5, 6) + to_unsigned(16#0C#, 6);
        sub_cast_37(i_2) := signed(resize(add_temp_25(i_2), 32));
        add_temp_26(i_2) := resize(i_5, 6) + to_unsigned(16#0C#, 6);
        sub_cast_38(i_2) := signed(resize(add_temp_26(i_2), 32));
        sub_temp_21(i_2) := resize(resize(i_5, 6) + to_unsigned(16#0C#, 6), 7) - to_unsigned(16#01#, 7);
        sub_cast_39(i_2) := signed(resize(sub_temp_21(i_2), 32));
        k_0(to_integer(sub_cast_37(i_2) - 1)) := k2(to_integer(sub_cast_38(i_2) - 1)) XOR k_0(to_integer(sub_cast_39(i_2) - 1));
      END LOOP;
      k2 := k_0;
    END LOOP;
    s_2 <= s2;
    kkkkkkk <= k2;
  END PROCESS p4_output;



  ce_out <= clk_enable;
END rtl;

