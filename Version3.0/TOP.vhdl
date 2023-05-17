library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;

USE work.parameter.ALL;


---------------------------------------
entity TOP is
  --GENERIC(WORD_LENGHT: NATURAL RANGE 1 TO 128 := 16) ;
  port (
    ----------finish config---------------
    finish_config_input : in    std_logic;
    ----------CONfig THE MODE-------------
    I2S_mode            : in    std_logic;
    master_mode         : in    std_logic;
    GPIO_MCLK           : in    std_logic;
    FS_48k_256_BCLK     : in    std_logic;
    MCLK_root           : in    std_logic;
    ----MCLK(GPIO)-generated by PLL and SHDNZ-------
    SHDNZ               : out   std_logic;    
    MCLK                : out   std_logic;
    -----------clk and rstn--------------
    clk                 : in    std_logic;  
    rstn                : in    std_logic;
    -----------ready--------------------
    SW_vdd_ok           : in    std_logic;   
    SHDNZ_ready         : in    std_logic;
    ------------FSYNC and BCLK -------------
    FSYNC               : in    std_logic;
    BCLK                : in    std_logic;
    -------------i2c communication------------
    SDA                 : inout std_logic;
    SCL                 : out   std_logic;
    -------------i2s communication------------
    DIN                 : in    std_logic;
    start_I2S           : in    std_logic;
	---------------Ethernet communication------
	MDIO                : inout std_logic; --configurate register
    MDC                 : out   std_logic; --configurate clk
    rstn_ethernet       : in    std_logic; -- reset ethernet on switch
    
    resetN              : out   std_logic; -- reset the PHY ; last 100us at least
    CLKIN               : out   std_logic; -- 50MHz to PHY

	ENABLE_ETHERNET 	: in 	std_logic; -- switch on 
    INTN_REFCLK0        : inout std_logic; --interrupt      ; 50MHz
    CRSDV_MODE2         : inout std_logic; --valid signal from PHY ; CONFIG directly 
    RXD1_MODE1          : inout std_logic; --read data from PHY    ; CONFIG directly 
    RXD0_MODE0          : inout std_logic; --read data from PHY    ; CONfig directly
    RXERR_PHYAD0        : inout std_logic; --error signal from PHY ; addr config ('1')
    TXD0                : out   std_logic; --write data to PHY
    TXD1                : out   std_logic; --write data to PHY
    txen                : out   std_logic; --write data to PHY	
	-------------SimpleAlgorithm communication------------------
	ENABLE_SIMPLE_ALGORITHM : IN STD_LOGIC; -- use switch on FPGA
	--Target_Index : out std_logic_vector(3 downto 0);
	
	-----------------DAC communication--------------------------    
    JD                  : OUT STD_LOGIC_VECTOR(8 DOWNTO 1);
    JC                  : OUT STD_LOGIC_VECTOR(8 DOWNTO 1)
    );

end entity TOP;


architecture arch_TOP_i2s_i2c_acfc_complex_filter_ethernet_dac of TOP is
  -- component
  constant WORD_LENGHT : integer := 16;
  
  component ADC_Configuration_Flow_Controller is
    -- generic(
    --   -- MODE reg addr
    --   constant const_addr_sleep_reg         : std_logic_vector(7 downto 0) := x"02";
    --   constant const_addr_interrupt_reg     : std_logic_vector(7 downto 0) := x"28";
    --   constant const_addr_c1_reg            : std_logic_vector(7 downto 0) := x"3c";
    --   constant const_addr_c2_reg            : std_logic_vector(7 downto 0) := x"41";
    --   constant const_addr_c3_reg            : std_logic_vector(7 downto 0) := x"46";
    --   constant const_addr_c4_reg            : std_logic_vector(7 downto 0) := x"4b";
    --   constant const_addr_input_channel_reg : std_logic_vector(7 downto 0) := x"73";
    --   constant const_addr_8_reg             : std_logic_vector(7 downto 0) := x"74";
    --   constant const_addr_powerup_reg       : std_logic_vector(7 downto 0) := x"75";
    --   constant const_addr_10_reg            : std_logic_vector(7 downto 0) := x"64"
    --   );
    port (
      finish_config_input       : in std_logic;
      I2S_mode                  : in  std_logic;
      master_mode               : in  std_logic;
      GPIO_MCLK                 : in  std_logic;
      FS_48k_256_BCLK           : in  std_logic;
      MCLK_root                 : in std_logic;
      
      rstn         : in  std_logic;
      clk          : in  std_logic;
      done         : in  std_logic;
      start        : out std_logic;
      config_value : out std_logic_vector(7 downto 0);
      config_addr  : out std_logic_vector(7 downto 0);
      SHDNZ        : out std_logic;
      SHDNZ_ready  : in  std_logic;
      SW_vdd_ok    : in  std_logic
      );
  end component ADC_Configuration_Flow_Controller;
  
  component I2C_Interface is
    port (
      clk               : in    std_logic;
      rstn              : in    std_logic;
      -- signals between i2c and ACFC
      start             : in    std_logic;
      done              : out   std_logic;
      config_addr       : in    std_logic_vector(7 downto 0);
      config_value      : in    std_logic_vector(7 downto 0);
      -- i2c communication
      SDA               : inout std_logic;
      SCL               : out   std_logic
      );
  end component I2C_Interface;
  
  component I2S IS
    --GENERIC(WORD_LENGHT: NATURAL RANGE 1 TO 128) ;
    PORT  (
      bclk      : IN    STD_LOGIC ;
      start     : IN    STD_LOGIC ;
      reset     : IN    STD_LOGIC ;
      fsync     : IN    STD_LOGIC ;
      DIN       : IN    STD_LOGIC;
	  L1_out : out std_logic_vector (15 downto 0);
	  L2_out : out std_logic_vector (15 downto 0);
	  R1_out : out std_logic_vector (15 downto 0);
	  R2_out : out std_logic_vector (15 downto 0)
      );
  END component I2S;
  
  
  component UDP_Ethernet is 
    port (
		--MDIO                : inout std_logic; --configurate register
		--MDC                 : out   std_logic; --configurate clk
		
		resetN              : out   std_logic; -- reset the PHY ; last 100us at least
		CLKIN               : out   std_logic; -- 50MHz to PHY

		INTN_REFCLK0        : inout std_logic; --interrupt      ; 50MHz
		CRSDV_MODE2         : inout std_logic; --valid signal from PHY ; CONFIG directly 
		RXD1_MODE1          : inout std_logic; --read data from PHY    ; CONFIG directly 
		RXD0_MODE0          : inout std_logic; --read data from PHY    ; CONfig directly
		RXERR_PHYAD0        : inout std_logic; --error signal from PHY ; addr config ('1')
		TXD0                : out   std_logic; --write data to PHY
		TXD1                : out   std_logic; --write data to PHY
		txen                : out   std_logic; --write data to PHY

		clk                 : in    std_logic; --100MHz
		rstn                : in    std_logic; 
		start               : in    std_logic; --switch : start ETHERNET
		fsync               : in    std_logic; --when I2S catch all data(fsync falling), start writing
		channel_1   : in    std_logic_vector(15 downto 0);
		channel_2   : in    std_logic_vector(15 downto 0);
		channel_3   : in    std_logic_vector(15 downto 0);
		channel_4   : in    std_logic_vector(15 downto 0)
		);
	end component;
  
  
  
  COMPONENT complex IS
  PORT(
  clk_sysclk : IN STD_LOGIC; --system clk 
  clk_fsync : IN STD_LOGIC; --fsync
  rst_n : IN STD_LOGIC;
  LC1 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  LC2 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  RC1 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  RC2 : IN STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0);
  dout_x : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
  dout_y : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
  dout : OUT STD_LOGIC_VECTOR(SIGNAL_WIDTH-1 DOWNTO 0)
  );
  END COMPONENT complex;

  component DAC IS
   port(
    JD: OUT STD_LOGIC_VECTOR(8 DOWNTO 1);
    JC: OUT STD_LOGIC_VECTOR(8 DOWNTO 1);
    --FSYNC_dac: OUT STD_LOGIC;
    FSYNC: IN STD_LOGIC;
    rstn : in STD_LOGIC;
    din_dac: in STD_LOGIC_VECTOR(15 downto 0)
    );

  END component DAC;

  

  -- signals between i2c and ACFC
  signal done           : std_logic;
  signal start          : std_logic;
  signal config_value   : std_logic_vector(7 downto 0);
  signal config_addr    : std_logic_vector(7 downto 0);
  -- i2s input to the algorithm
  signal L1_signal      : std_logic_vector (WORD_LENGHT-1 downto 0);
  signal L2_signal      : std_logic_vector (WORD_LENGHT-1 downto 0);
  signal R1_signal      : std_logic_vector (WORD_LENGHT-1 downto 0);
  signal R2_signal      : std_logic_vector (WORD_LENGHT-1 downto 0);
  signal clk_sysclk     : std_logic;
  -- algorithm signals
  signal sa_output_signal : std_logic_vector(16 downto 1);
  signal target_index_signal : std_logic_vector(2 downto 0);
  ------------------------------------
  component clk_wiz_0 is
    port (
      clk_out1  : out STD_LOGIC;
      resetn    : in STD_LOGIC;
      clk_in1   : in STD_LOGIC
      );
  end component clk_wiz_0;
  -------------------------------------


  
  
begin  -- architecture 

  clk_sysclk <= clk;
  
  inst_ACFC: component ADC_Configuration_Flow_Controller
    port map (
      finish_config_input       => finish_config_input,
      I2S_mode                  => I2S_mode,
      master_mode               => master_mode,
      GPIO_MCLK                 => GPIO_MCLK  ,
      FS_48k_256_BCLK           => FS_48k_256_BCLK,
      MCLK_root                 => MCLK_root,

      rstn         => rstn,
      clk          => clk,
      done         => done,
      start        => start,
      config_value => config_value,
      config_addr  => config_addr,
      SHDNZ        => SHDNZ,
      SHDNZ_ready  => SHDNZ_ready,
      SW_vdd_ok    => SW_vdd_ok
      );
  
  inst_i2c: component I2C_Interface
    port map (
      clk               => clk,
      rstn              => rstn,
      config_addr       => config_addr,
      config_value      => config_value,
      start             => start,
      done              => done,
      SDA               => SDA,
      SCL               => SCL
      );
  
  inst_i2S: component I2S
    -- generic map (WORD_LENGHT=>WORD_LENGHT)
    port map (
      bclk              =>BCLK,
      start             =>start_I2S,
      reset             =>rstn,
      fsync             =>FSYNC,
      DIN               =>DIN,
      L1_out            =>  L1_signal,
      L2_out 			=>  L2_signal,
      R1_out 			=>  R1_signal,
      R2_out 			=>  R2_signal
      );
	  
  inst_Ethernet: component UDP_Ethernet
	 port map(
			  --MDIO => MDIO,
			  --MDC => MDC,
			  
			  resetN => resetN,
			  CLKIN => CLKIN,
			  
			  INTN_REFCLK0 => INTN_REFCLK0,
			  CRSDV_MODE2 => CRSDV_MODE2,
			  RXD1_MODE1 => RXD1_MODE1,
			  RXD0_MODE0 => RXD0_MODE0,
			  RXERR_PHYAD0 => RXERR_PHYAD0,
			  TXD0 => TXD0,
			  TXD1 => TXD1,
			  txen => txen,
			
			  clk => clk,
			  rstn => rstn_ethernet,
			  start => ENABLE_ETHERNET,
			  fsync => FSYNC,
			  channel_1 => L1_signal,
			  channel_2 => L2_signal,
			  channel_3 => R1_signal,
			  channel_4 => R2_signal
	);
	  
	  
   inst_CA: 
    COMPONENT complex
	  PORT MAP(
	  clk_sysclk => clk,
	  clk_fsync => FSYNC,
	  rst_n => ENABLE_SIMPLE_ALGORITHM,
	  LC1 => L1_signal,
	  LC2 => L2_signal,
	  RC1 => R1_signal,
	  RC2 => R2_signal,
	  dout_x => open,
	  dout_y => open,
	  dout => sa_output_signal
    );
  
  inst_DAC: component DAC
    port map (
      JD => JD,
      JC => JC,

      FSYNC => FSYNC,
      rstn => rstn,
      din_dac => sa_output_signal
      --din_dac => L1_signal
      );
  
  ------------------------------------------------------------
  ----GENERATE the FSYNC and BCLK by PLL
  PLL_12M: component clk_wiz_0 
    port map (
      clk_in1           => clk_sysclk,
      clk_out1          => MCLK,
      resetn              => rstn
      );
  ------------------------------------------------------------
  
end architecture arch_TOP_i2s_i2c_acfc_complex_filter_ethernet_dac;
