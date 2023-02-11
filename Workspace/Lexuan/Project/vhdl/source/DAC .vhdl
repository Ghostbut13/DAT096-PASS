----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/06/2023 09:13:36 AM
-- Design Name: 
-- Module Name: DAC - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DAC is
--  Port ( );
port(
    JD: OUT STD_LOGIC_VECTOR(8 DOWNTO 1);
    JA: OUT STD_LOGIC_VECTOR(8 DOWNTO 1);
    SW: IN STD_LOGIC;
    JC: OUT STD_LOGIC;
    CLK: IN STD_LOGIC);
end DAC;

architecture Behavioral of DAC is

SIGNAL dac_vec: STD_LOGIC_VECTOR(16 DOWNTO 1);
SIGNAL counter: STD_LOGIC_VECTOR(8 DOWNTO 1) := "00000000";
SIGNAL counter_2: STD_LOGIC_VECTOR(16 DOWNTO 1) := "0000000000000000";

begin

JD(8 DOWNTO 5) <= dac_vec(12 DOWNTO 9);
JD(4 DOWNTO 1) <= dac_vec(16 DOWNTO 13);
JA(8 DOWNTO 5) <= dac_vec(4 DOWNTO 1);
JA(4 DOWNTO 1) <= dac_vec(8 DOWNTO 5);

dac_pro:
PROCESS(CLK)

BEGIN

IF rising_edge(CLK) THEN
   counter <= STD_LOGIC_VECTOR(UNSIGNED(counter) + 1);
END IF;

IF rising_edge(counter(8)) THEN
   counter_2 <= STD_LOGIC_VECTOR(UNSIGNED(counter_2) + 1);
END IF;

 JC <= counter(8);
 
dac_vec(16 DOWNTO 1) <= counter_2 ;

END PROCESS dac_pro;

end Behavioral;
