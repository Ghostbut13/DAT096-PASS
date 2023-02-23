-------------------------------------------------------------------------------
-- Title      : AES testbench
-- Project    : 
-------------------------------------------------------------------------------
-- File       : mlhdlc_aes_fixptD_tb.vhdl
-- Author     :   <ASUS@LAPTOP-M6B560H3>
-- Company    : 
-- Created    : 2022-11-15
-- Last update: 2022-12-17
-- Platform   : 
-- Standard   : VHDL'93/021
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2022 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2022-11-15  1.0      ASUS	Created
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE work.mlhdlc_aesd_fixpt_pkg.ALL;

ENTITY TEST_WRAPPER IS
    port (
      
      clk                               :   IN    std_logic;
      reset                             :   IN    std_logic;
      clk_enable                        :   IN    std_logic;

      uart_txd                          :   out   std_logic

      );
end entity TEST_WRAPPER;




architecture arch_TEST_WRAPPER of TEST_WRAPPER is
 COMPONENT ila_0

PORT (
	clk : IN STD_LOGIC;



	probe0 : IN STD_LOGIC; 
	probe1 : IN STD_LOGIC; 
	probe2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
	probe3 : IN STD_LOGIC
);
END COMPONENT  ;



  CONSTANT ciphertext  : vector_of_std_logic_vector8(0 TO 15) := ((x"1F"), (x"9D"), (x"05"), (x"17"), (x"7B"), (x"B0"), (x"5F"), (x"87"), (x"99"), (x"7A"), (x"AE"), (x"F3"), (x"9E"), (x"82"), (x"51"), (x"CC"));

  signal  RX_RF_tb : std_logic := '1';
  signal  TXD_tb : std_logic_vector(7 downto 0);
  signal  uart_txd_tb : std_logic;
  signal  cnt_for_rf : integer;

  component mlhdlc_aesd_fixpt is
    port (
      
      clk                               :   IN    std_logic;
      reset                             :   IN    std_logic;
      clk_enable                        :   IN    std_logic;
     

      TXD                               :   IN   std_logic_vector(7 downto 0);
      RX_RF                             :   IN   std_logic;
      
      uart_txd                          :   out   std_logic

      );
  end component mlhdlc_aesd_fixpt;
  
signal clk_100ns : std_logic;
  signal cnt : unsigned(3 downto 0);


  
begin 
  --
  --
  
your_instance_name : ila_0
PORT MAP (
	clk => clk,



	probe0 => clk_enable , 
	probe1 => RX_RF_tb, 
	probe2 => TXD_tb,
	probe3 => uart_txd_tb
);
  ASED_inst : mlhdlc_aesD_fixpt
    port map(
      clk => clk_100ns,
      reset => reset,                 
      clk_enable => clk_enable,


      
      TXD    => TXD_tb,
      RX_RF  => RX_RF_tb,

      
      uart_txd => uart_txd_tb

      );

uart_txd<=uart_txd_tb;

  
  txddd: process (clk_100ns, reset) is
  begin  -- process txddd
    if reset = '0' then                    -- asynchronous reset (active low)
      cnt_for_rf <= 0;
    elsif clk'event and clk = '1' then    -- rising clock edge
      if RX_RF_tb='1' and cnt_for_rf<16 then
        TXD_tb <= ciphertext(cnt_for_rf);
        cnt_for_rf <= cnt_for_rf+1;
      end if;
    end if;
  end process txddd;

    
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
  


end architecture arch_TEST_WRAPPER;   




