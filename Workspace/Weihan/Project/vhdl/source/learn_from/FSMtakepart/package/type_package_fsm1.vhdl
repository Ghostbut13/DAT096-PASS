-----------------------
-- type_package.vhdl --
-- state type for    --
-- SPI_state         --
-- Sven Knutsson     --
-----------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE type_package_fsm1 IS
   TYPE state_type_fsm1 IS (idle_state,
     
                       fsm1_eat_state,
                       
                       end_state);
END PACKAGE type_package_fsm1;