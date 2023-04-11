LIBRARY ieee;
library work;
USE ieee.std_logic_1164.ALL;
USE work.parameter.ALL;


ENTITY bitregister IS
  PORT (clk: IN STD_LOGIC;
        din: IN STD_LOGIC;
        dout: OUT STD_LOGIC :='0');
END bitregister;

ARCHITECTURE arch_bitregister OF bitregister IS

BEGIN

assign_process:
PROCESS(clk)
BEGIN
  IF FALLING_EDGE(clk) THEN
    dout <= din;
  END IF;
END PROCESS assign_process;

END arch_bitregister;
