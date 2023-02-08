-----------------------
-- type_package.vhdl --
-- state type for    --
-- SPI_state         --
-- Sven Knutsson     --
-----------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE type_package_fsm2 IS
   TYPE state_type_fsm2 IS   (idle_state,
                        start_state,A_B_state,
                        zero_state,GA_state,SHDN_state,
                        
                        
                        fsm2_data_state,
                        
                        
                        end_state);
END PACKAGE type_package_fsm2;

