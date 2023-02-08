
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.mlhdlc_aes_fixpt_pkg.ALL;

ENTITY Wrapper_AES IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        clk_enable                        :   IN    std_logic;
        plaintext                         :   IN    vector_of_std_logic_vector8(0 TO 15);  -- ufix8 [16]
        cipherkey                         :   IN    vector_of_std_logic_vector8(0 TO 15);  -- ufix8 [16]
        ce_out                            :   OUT   std_logic;
        ciphertext                        :   OUT   vector_of_std_logic_vector8(0 TO 15);  -- ufix8 [16]
        data_out64_1                      :   out   std_logic_vector(63 downto 0);
        data_out64_2                      :   out   std_logic_vector(63 downto 0)
        );
END Wrapper_AES;



ARCHITECTURE rtl OF Wrapper_AES IS

  component AES_R1 IS
    PORT( clk                               :   IN    std_logic;
          reset                             :   IN    std_logic;
          clk_enable                        :   IN    std_logic;
          plaintext                         :   IN    vector_of_std_logic_vector8(0 TO 15);  -- ufix8 [16]
          cipherkey                         :   IN    vector_of_std_logic_vector8(0 TO 15);  -- ufix8 [16]
          ce_out                            :   OUT   std_logic;
          k_1                               :   OUT   vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
          s                                 :   OUT   vector_of_unsigned8(0 TO 15)  -- ufix8 [16]
          );
  END component AES_R1;

  signal k_1_tb : vector_of_unsigned8(0 to 15);
  signal s_tb : vector_of_unsigned8(0 to 15);
  
  component AES_R2to9 IS
    PORT( clk                               :   IN    std_logic;
          reset                             :   IN    std_logic;
          clk_enable                        :   IN    std_logic;
          k_1                               :   IN    vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
          s                                 :   IN    vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
          ce_out                            :   OUT   std_logic;
          kkkkkkk                           :   OUT   vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
          s_2                               :   out   vector_of_unsigned8(0 TO 15)  -- ufix8 [16]
          );
  END component AES_R2to9;

  signal s_2_tb : vector_of_unsigned8(0 to 15);
  signal kkkk_tb : vector_of_unsigned8(0 to 15);
  
  component AES_R10 IS
    PORT( clk                               :   IN    std_logic;
          reset                             :   IN    std_logic;
          clk_enable                        :   IN    std_logic;
          s_2                               :   IN    vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
          kkkkkkk                           :   IN    vector_of_unsigned8(0 TO 15);  -- ufix8 [16]
          ce_out                            :   OUT   std_logic;
          ciphertext                        :   OUT   vector_of_std_logic_vector8(0 TO 15);  -- ufix8 [16]
          data_out64_1                      :   out   std_logic_vector(63 downto 0);
          data_out64_2                      :   out   std_logic_vector(63 downto 0)
          );
  END component AES_R10;


  signal clk_100ns : std_logic;
  signal cnt : unsigned(3 downto 0);


begin
  inst_AES_R1: AES_R1
    PORT map(
      clk                               =>   clk_100ns,
      reset                             =>   reset,
      clk_enable                        =>   clk_enable,
      plaintext                         =>   plaintext,
      cipherkey                         =>   cipherkey,
      k_1                               =>   k_1_tb,
      s                                 =>   s_tb);
  
  inst_AES_R2to9: AES_R2to9
    PORT map( 
      clk                               =>   clk_100ns,
      reset                             =>   reset,
      clk_enable                        =>   clk_enable,
      k_1                               =>   k_1_tb,
      s                                 =>   s_tb,
      kkkkkkk                           =>   kkkk_tb,
      s_2                               =>   s_2_tb
      );
  inst_AES_R10: AES_R10
    PORT map(
      clk                               =>   clk,
      reset                             =>   reset,
      clk_enable                        =>   clk_enable,
      s_2                               =>   s_2_tb,
      kkkkkkk                           =>   kkkk_tb,
      ce_out                            =>   ce_out,
      ciphertext                        =>   ciphertext,
      data_out64_1                      =>   data_out64_1, 
      data_out64_2                      =>   data_out64_2
      );
 
  
  process(clk,reset)
  begin
    if reset = '0' then
      clk_100ns <= '0';
    elsif rising_edge(clk) then
      if(cnt=x"9") then
        clk_100ns <= not(clk_100ns);
      end if;
    end if;
  end process;

  process(clk,reset)
  begin
    if reset = '0' then
      cnt <= x"0";
    elsif rising_edge(clk) then
      if(cnt=x"9") then
        cnt <= x"0";
      else
        cnt <= cnt+to_unsigned(16#1#,4);
      end if;
    end if;
  end process;
  
  
END rtl;

