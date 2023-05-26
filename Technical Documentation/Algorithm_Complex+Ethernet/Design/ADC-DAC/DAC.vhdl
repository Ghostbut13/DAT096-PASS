

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
    JC: OUT STD_LOGIC_VECTOR(8 DOWNTO 1);
    --FSYNC_dac: OUT STD_LOGIC;
    FSYNC: IN STD_LOGIC;
    rstn : in STD_LOGIC;
    din_dac: in STD_LOGIC_VECTOR(16 downto 1)
    
    );
end DAC;

architecture Behavioral of DAC is

  SIGNAL dac_vec	   : STD_LOGIC_VECTOR(16 DOWNTO 1);

begin

  JC(4 DOWNTO 1) <= dac_vec(4 DOWNTO 1);
  JC(8 DOWNTO 5) <= dac_vec(8 DOWNTO 5);
  JD(4 DOWNTO 1) <= dac_vec(16 DOWNTO 13);
  JD(8 DOWNTO 5) <= dac_vec(12 DOWNTO 9);

  
  

  dac_pro:
  PROCESS(FSYNC,rstn)
  BEGIN
    if rstn='0' THEN
      dac_vec(16 DOWNTO 1) <= ( others=> '0');
    elsif falling_edge(FSYNC) THEN
      --dac_vec(16 DOWNTO 1) <= din_dac;
	    dac_vec <= std_logic_vector(unsigned(din_dac(16 DOWNTO 1))+to_unsigned(16#8000#,16));
    end if;
  END PROCESS dac_pro;

end Behavioral;
