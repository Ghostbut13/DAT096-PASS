library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


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
	-------------SimpleAlgorithm communication------------
	ENABLE_SIMPLE_ALGORITHM : IN STD_LOGIC; -- use switch on FPGA
	Target_Index : out std_logic_vector(2 downto 0);
	
	-----------------DAC communication------------    
    JD                  : OUT STD_LOGIC_VECTOR(8 DOWNTO 1);
    JC                  : OUT STD_LOGIC_VECTOR(8 DOWNTO 1)
    );

end entity TOP;


architecture arch_TOP_i2s_i2c_acfc of TOP is
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
  
  
  component SimpleAlgorithm is 
	 port( LC1_in 			: in std_logic_vector(16 downto 1);
		   LC2_in 			: in std_logic_vector(16 downto 1);
		   RC1_in			: in std_logic_vector(16 downto 1);
		   RC2_in 			: in std_logic_vector(16 downto 1);
		   clk 			: in std_logic;
		   start_SA 	: in std_logic; -- this work as a system reset. We can use it as a switch on the FPGA
		   OUTPUT 		: out std_logic_vector(16 downto 1); -- goes to DAC
		   INDEX_OUT	: out std_logic_vector(2 downto 0 ) -- goes to LEDs
		  );
end component SimpleAlgorithm;

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



  

  -- signal between i2c and ACFC
  signal done           : std_logic;
  signal start          : std_logic;
  signal config_value   : std_logic_vector(7 downto 0);
  signal config_addr    : std_logic_vector(7 downto 0);
  -- i2s input to the algorithm
  signal L1_signal      : std_logic_vector (WORD_LENGHT-1 downto 0);
  signal L2_signal      : std_logic_vector (WORD_LENGHT-1 downto 0);
  signal R1_signal      : std_logic_vector (WORD_LENGHT-1 downto 0);
  signal R2_signal      : std_logic_vector (WORD_LENGHT-1 downto 0);
  -- algorithm signals
  signal sa_output_signal : std_logic_vector(16 downto 1);
  signal target_index_signal : std_logic_vector(2 downto 0);
  ------------------------------------
  component PLL_12M is
    port (
      clk_out1  : out STD_LOGIC;
      resetn    : in STD_LOGIC;
      clk_in1   : in STD_LOGIC
      );
  end component PLL_12M;
  -------------------------------------


  
  
begin  -- architecture arch_Wrapper_ACFC_i2c


   Target_Index <= target_index_signal;
   
  
  --L1_out <= L1_signal;
  --L2_out <= L2_signal;
  --R1_out <= R1_signal;
  --R2_out <= R2_signal;
  ------------------------------------------------------------
  -- INSTANCE
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
	  
	  
	inst_SA: component SimpleAlgorithm
	 port map(LC1_in => L1_signal,
			  LC2_in => L2_signal,
			  RC1_in => R1_signal,
			  RC2_in => R2_signal,
			  clk => FSYNC,
			  start_SA => ENABLE_SIMPLE_ALGORITHM,
			  OUTPUT => sa_output_signal,
			  INDEX_OUT => target_index_signal

			 );
  
  inst_DAC: component DAC
    port map (
      JD => JD,
      JC => JC,

      FSYNC => FSYNC,
      rstn => rstn,
      din_dac => sa_output_signal
      );
  
  ------------------------------------------------------------
  ----GENERATE the FSYNC and BCLK by PLL
  clk_wiz_0: component PLL_12M
    port map (
      clk_in1           => clk,
      clk_out1          => MCLK,
      resetn            => rstn
      );
  ------------------------------------------------------------



  
end architecture arch_TOP_i2s_i2c_acfc;
