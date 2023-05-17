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
   TYPE i2c_state_type IS (
    idle_state,
    start_state,
    write_i2c_addr_state_0,
    write_i2c_addr_state_1,
    write_i2c_addr_state_2,
    write_i2c_addr_state_3,
    write_i2c_addr_state_4,
    write_i2c_addr_state_5,
    write_i2c_addr_state_6,
    write_i2c_addr_state_7,
    RECEIVE_ACK_state_0,

    write_reg_addr_state_0,
    write_reg_addr_state_1,
    write_reg_addr_state_2,
    write_reg_addr_state_3,
    write_reg_addr_state_4,
    write_reg_addr_state_5,
    write_reg_addr_state_6,
    write_reg_addr_state_7,
    RECEIVE_ACK_state_1,

    write_reg_data_state_0,
    write_reg_data_state_1,
    write_reg_data_state_2,
    write_reg_data_state_3,
    write_reg_data_state_4,
    write_reg_data_state_5,
    write_reg_data_state_6,
    write_reg_data_state_7,
    RECEIVE_ACK_state_2,

    setup_stop_state,
    stop_state,
    end_state   

);

END PACKAGE i2c_type_package;

