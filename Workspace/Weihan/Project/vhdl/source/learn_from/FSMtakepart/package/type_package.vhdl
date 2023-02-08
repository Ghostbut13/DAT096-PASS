-----------------------
-- type_package.vhdl --
-- state type for    --
-- SPI_state         --
-- Sven Knutsson     --
-----------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE type_package IS
   TYPE state_type IS (idle_state,start_state,A_B_state,
                       zero_state,GA_state,SHDN_state,
                       data_state_0,data_state_1,data_state_2,
                       data_state_3,data_state_4,data_state_5,
                       data_state_6,data_state_7,data_state_8,
                       data_state_9,data_state_10,data_state_11,
                       end_state);
END PACKAGE type_package;

