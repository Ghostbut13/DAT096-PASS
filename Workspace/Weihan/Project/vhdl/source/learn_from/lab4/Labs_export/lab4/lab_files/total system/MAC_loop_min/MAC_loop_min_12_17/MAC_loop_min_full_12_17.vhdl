----------------------------------
-- MAC_loop_min_full_12_17.vhdl --
-- multiplier/accumulator (MAC) --
-- direct implementation        --
-- using LOOP...LOOP with       --
-- 12 bit signal                --
-- 12 bit coefficients          --
-- 17 taps                      --
-- using an ADC for input       --
-- and a DAC for output         --
-- mini version                 --
-- Sven Knutsson                --
----------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE WORK.MAC_loop_min_12_17_package.ALL;
USE WORK.system_frequencies_package.ALL;

ENTITY MAC_loop_min_full_12_17 IS
--   GENERIC (SIGNAL_WIDTH:INTEGER := 12;
--            COEFF_WIDTH:INTEGER := 12;
--            TAPS:INTEGER :=1 7);
   PORT(resetn:IN STD_LOGIC;
        clk:IN STD_LOGIC;
        AD_channel:IN STD_LOGIC;
        CS_AD:OUT STD_LOGIC;
        SCLK_AD:OUT STD_LOGIC;
        SDI_to_AD:OUT STD_LOGIC;
        SDI_from_AD:IN STD_LOGIC;
        DA_channel:IN STD_LOGIC;
        DA_gain:IN STD_LOGIC;
        CS_DA:OUT STD_LOGIC; 
        SCLK_DA:OUT STD_LOGIC;       
        SDI_to_DA:OUT STD_LOGIC;
	    LDAC_DA:OUT STD_LOGIC);
---        filter_out:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
END MAC_loop_min_full_12_17;

ARCHITECTURE arch_MAC_loop_min_full_12_17 OF
                                 MAC_loop_min_full_12_17 IS
-- For simulation

   COMPONENT MAC_loop_min_12_17 IS
      GENERIC (SIGNAL_WIDTH:INTEGER := SIGNAL_WIDTH;
               COEFF_WIDTH:INTEGER := COEFF_WIDTH;
               TAPS:INTEGER := TAPS);
      PORT(resetn:STD_LOGIC;
           start:STD_LOGIC;
           clk:STD_LOGIC;
           x:IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
--           y:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH+COEFF_WIDTH-1 DOWNTO 0));
           y:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
   END COMPONENT MAC_loop_min_12_17;

   COMPONENT convert_data_format is
      GENERIC(SIGNAL_WIDTH:INTEGER := 12);
      PORT(in_value:IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
           convert:IN STD_LOGIC;
           out_value:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
   END COMPONENT convert_data_format;

   COMPONENT sample_clock is
       GENERIC(system_clk:POSITIVE := 100000;
               sample_clk:POSITIVE := 40);    
       PORT(resetn:IN STD_LOGIC;
            clk:IN STD_LOGIC;
            sample_en:OUT STD_LOGIC);
   END COMPONENT sample_clock;

   COMPONENT SPI_clock is
       GENERIC(system_clk:POSITIVE := 100000;
               spi_clk:POSITIVE := 2000);
       PORT(resetn:IN STD_LOGIC;
	        clk:IN STD_LOGIC;
            SCLK:OUT STD_LOGIC;
            SCLK_enable:OUT STD_LOGIC);
   END COMPONENT SPI_clock;

   COMPONENT SPI_AD is
      GENERIC (SIGNAL_WIDTH:INTEGER := 12);
      PORT(resetn:IN STD_LOGIC;
           clk:IN STD_LOGIC;
           SCLK_enable:IN STD_LOGIC;
           ODD_SIGN:IN STD_LOGIC;
           receive:IN STD_LOGIC;
           CS_AD:OUT STD_LOGIC;
           DIN_AD:OUT STD_LOGIC;
           DOUT_AD:IN STD_LOGIC;
           DATA_valid_AD:OUT STD_LOGIC;
           AD_data:OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0));
   END COMPONENT SPI_AD;

   COMPONENT SPI_DA is
      GENERIC (SIGNAL_WIDTH:INTEGER := 12);
      PORT(resetn:IN STD_LOGIC;
           clk:IN STD_LOGIC;
           SCLK_enable:IN STD_LOGIC;
--           LDAC_in:IN STD_LOGIC;
           send:IN STD_LOGIC;
           DA_channel:IN STD_LOGIC;
           DA_gain:IN STD_LOGIC;
           DA_data:IN STD_LOGIC_VECTOR(11 DOWNTO 0);
           CS_DA:OUT STD_LOGIC;
           SDI_DA:OUT STD_LOGIC;
           LDAC_out:OUT STD_LOGIC;
           DATA_valid_DA:OUT STD_LOGIC);
   END COMPONENT SPI_DA;

   SIGNAL sample_enable_signal:STD_LOGIC;
   SIGNAL SCLK_enable_signal:STD_LOGIC;
   SIGNAL SCLK_signal:STD_LOGIC;
   SIGNAL AD_data_signal:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
   SIGNAL signed_data_signal:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
   SIGNAL filtered_data_signal:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
   SIGNAL DA_data_signal:STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
   SIGNAL clk_tb_signal:STD_LOGIC:='0';
   SIGNAL resetn_tb_signal:STD_LOGIC;
   SIGNAL start_tb_signal:STD_LOGIC;

BEGIN
   MAC_loop_min_12_17_inst:
   COMPONENT MAC_loop_min_12_17
         GENERIC MAP(SIGNAL_WIDTH => SIGNAL_WIDTH,
                     COEFF_WIDTH => COEFF_WIDTH,
                     TAPS => TAPS)
         PORT MAP(clk => clk,
                  resetn => resetn,
                  start => sample_enable_signal,
                  x => signed_data_signal,
                  y => filtered_data_signal);
   
   convert_data_format_AD_inst:
   COMPONENT convert_data_format 
      GENERIC MAP(SIGNAL_WIDTH => SIGNAL_WIDTH)
      PORT MAP(in_value => AD_data_signal,
               convert => '1',
              out_value => signed_data_signal);

   convert_data_format_DA_inst:
   COMPONENT convert_data_format 
      GENERIC MAP(SIGNAL_WIDTH => SIGNAL_WIDTH)
      PORT MAP(in_value => filtered_data_signal,
               convert => '1',
              out_value => DA_data_signal);

   sample_clock_inst:
   COMPONENT sample_clock
       GENERIC MAP(system_clk => SYSTEM_FREQ,
                   sample_clk => SAMPLE_FREQ)
       PORT MAP(resetn => resetn,
                clk => clk,
                sample_en => sample_enable_signal);
 
    SPI_clock_inst:
    COMPONENT SPI_clock
       GENERIC MAP(system_clk => SYSTEM_FREQ,
                   spi_clk => SPI_FREQ)
       PORT MAP(resetn => resetn,
             clk => clk,
                SCLK => SCLK_signal,
                SCLK_enable => SCLK_enable_signal);

   SPI_AD_inst:
   COMPONENT SPI_AD
      GENERIC MAP (SIGNAL_WIDTH => SIGNAL_WIDTH)
      PORT MAP(resetn => resetn,
               clk => clk,
               SCLK_enable => SCLK_enable_signal,
               ODD_SIGN => AD_channel,
               receive => sample_enable_signal,
               CS_AD => CS_AD,
               DIN_AD => SDI_to_AD,
               DOUT_AD => SDI_from_AD,
               AD_data => AD_data_signal);

   SPI_DA_inst:
   COMPONENT SPI_DA
      GENERIC MAP(SIGNAL_WIDTH => SIGNAL_WIDTH)
      PORT MAP(resetn => resetn,
           clk => clk,
           SCLK_enable => SCLK_enable_signal,
--           LDAC_in => '0',
           send => sample_enable_signal,
           DA_channel => DA_channel,
           DA_gain => DA_gain,
           DA_data => DA_data_signal,
           CS_DA => CS_DA,
           SDI_DA => SDI_to_DA,
     LDAC_out => LDAC_DA);

--   filter_out <= filtered_data_signal;
   SCLK_AD <= SCLK_signal;
   SCLK_DA <= SCLK_signal;
   
END arch_MAC_loop_min_full_12_17;
