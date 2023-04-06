-----------------------
-- type_package.vhdl --
-- state type for    --
-- SPI_state         --
-- Sven Knutsson     --
-----------------------


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

PACKAGE config_state_package IS
   TYPE adc_config_state_type IS (
    idle_state,
    hardware_shutdown_state,
    SHDNZ_state,                        --waiting 1ms
    wakeup_state,
    woke_state,                         --waiting 1ms

    --start configurate the register
    config_and_programm_state,

    --when finish configuration
    powerdown_state,
    config_channel_1_state,
    config_channel_2_state,
    config_channel_3_state,
    config_channel_4_state,
    enable_input_state,
    enable_output_state,
    powerup_state,
    APPLY_BCLK_FSYNC_state,
    I2S_working_state,                  --waiting 10ms
    enable_diagnostics_state,
    disable_diagnostics_state,
    stop_state,
    waiting_state
);

END PACKAGE config_state_package;

