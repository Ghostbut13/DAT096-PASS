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
    SHDNZ_state,
    wakeup_state,
    powerdown_state,
    config_channel_state,
    enable_input_state,
    enable_output_state,
    powerup_state,
    APPLY_BCLK_FSYNC_state,
    enable_diagnostics_state,
    disable_diagnostics_state,
    stop_state,
    end_state
);

END PACKAGE config_state_package;

