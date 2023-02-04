-----------------------
-- type_package.vhdl --
-- state type for    --
-- SPI_state         --
-- Sven Knutsson     --
-----------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE i2c_type_package IS
   TYPE i2c_state_type IS (idle_state,start_state,
                       write_addr_state_0,
                       write_addr_state_1,
                       write_addr_state_2,
                       write_addr_state_3,
                       write_addr_state_4,
                       write_addr_state_5,
                       write_addr_state_6,
                       send_RW_state,
                       REC_ACK_state,
                       data_state_0,
                       data_state_1,
                       data_state_2,
                       data_state_3,
                       data_state_4,
                       data_state_5,
                       data_state_6,
                       data_state_7,
                       SEND_ACK_state,
                       data_state_8,
                       data_state_9,
                       data_state_10,
                       data_state_11,
                       data_state_12,
                       data_state_13,
                       data_state_14,
                       data_state_15,
                       end_state);
   --   2004
--   2013
--   2033
--   2053
--   2073
--   2093
--   2113
--   2153
--   2164
--   2189
--   2209
--   2229
--   2249
--   2269
--   2289
--   2309
--   2329
--   2349
--   2369
--   2389
--   2409
-- 2429
--   2449
--   2469
--   2489
--    2509
-- 2529
--   2559
END PACKAGE i2c_type_package;

