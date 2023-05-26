-------------------------------------------------------------------------------
-- Title      : Ethernet
-- Project    : 
-------------------------------------------------------------------------------
-- File       : UDP_Ethernet.vhdl
-- Author     : weihan gao
-- Company    : 
-- Created    : 2023-03-08
-- Last update: 2023-04-04
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: CONTROLLER
-- read data and pass them in TCP
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-03-08  1.0      ASUS	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UDP_Ethernet is
  
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

end entity UDP_Ethernet;


architecture arch_UDP_Ethernet of UDP_Ethernet is
  -- constant
  constant CONST_FSYNC          : integer := 48000;
  constant CONST_stream_time    : integer := 3; --time of playing music
  constant CONST_ROUND          : integer := CONST_stream_time * CONST_FSYNC;
  constant CONST_send           : integer := 72*8;--400 + CONST_Width_audio;
  constant CONST_cnt_32         : integer := CONST_send/2; --32
  constant CONST_Width_audio    : integer := 64;


  --------------------
  constant CONST_ETH_PREMABLE   : std_logic_vector(55 downto 0) := x"55555555555555";
  constant CONST_ETH_SFD        : std_logic_vector(7 downto 0)  := x"57";
  constant DST_MAC_ADDR         : std_logic_vector(47 downto 0) := x"18e1bf3ebc9d"; -- ammar : 28F10E24FB2C
  constant FPGA_MAC_ADDR        : std_logic_vector(47 downto 0) := x"bf5595811716"; --
  constant CONST_ETH_TYPE       : std_logic_vector(15 downto 0) := x"2000";
  -------------------- 
  constant CONST_IP_HEAD_LEN    : std_logic_vector(3 downto 0)  := "0101";
  constant CONST_IP_HEAD_VER    : std_logic_vector(3 downto 0)  := "0001";
  constant CONST_IP_HEAD_TOS    : std_logic_vector(7 downto 0)  := x"00";
  constant IP_LENGTH            : std_logic_vector(15 downto 0) := x"0018"; --
  constant CONST_IP_HEAD_ID     : std_logic_vector(15 downto 0) := x"bf40";
  constant CONST_IP_HEAD_FLAG   : std_logic_vector(2 downto 0)  := "000";
  constant CONST_IP_HEAD_OFFSET : std_logic_vector(12 downto 0) := "0000000000000";--120GOOD
  constant CONST_IP_HEAD_TTL    : std_logic_vector(7 downto 0)  := x"02";
  constant CONST_IP_HEAD_PROT   : std_logic_vector(7 downto 0)  := x"44";
  
  signal   IP_HEAD_CHECK_SUM    : std_logic_vector(15 downto 0)                 ; --
  
  constant IP_HEAD_9f3e_CHECK_SUM    : std_logic_vector(15 downto 0)  :=x"f64c"               ; --
  
  constant DST_IP_ADDR          : std_logic_vector(31 downto 0) := x"032a20f0"; --
  constant FPGA_IP_ADDR         : std_logic_vector(31 downto 0) := x"6abf4c0b"; --
  --------------------
  constant DST_UDP_PROT         : std_logic_vector(15 downto 0)  := x"8484";
  constant FPGA_UDP_PROT        : std_logic_vector(15 downto 0)  := x"dd00";
  constant UDP_LEN              : std_logic_vector(15 downto 0)  := x"0004";--
  constant UDP_HEAD_CHECK       : std_logic_vector(15 downto 0)  := x"0000";
  --------------------
  signal CRC_1 : std_logic_vector(7 downto 0);
  signal CRC_2 : std_logic_vector(7 downto 0);
  signal CRC_3 : std_logic_vector(7 downto 0);
  signal CRC_4 : std_logic_vector(7 downto 0);
  signal CRC : std_logic_vector(31 downto 0);
  signal CRC_new : std_logic_vector(31 downto 0);
  
--   constant  preamble : std_logic_vector() := xC0A8010F 
--   constant  SFD : std_logic_vector() := 
--   constant  MAC_Ethernet : std_logic_vector() := 
--   constant  MAC_board : std_logic_vector() := 
--   constant  len : std_logic_vector() := 
--   constant  CRC : std_logic_vector() := 
  
  
  
  -- fsm
  type Ethernet_state is (
    IDLE,
    RESET_STATE,
    MODE_STATE,
    WRITE_STATE,
    BACK_STATE,
    END_STATE
    );
  signal state          : Ethernet_state;
  signal next_state     : Ethernet_state;
  
  -- output signal
  signal clk_50MHz      : std_logic := '0';
  signal MODE0          : std_logic;
  signal MODE1          : std_logic;
  signal MODE2          : std_logic;
  signal PHYAD0         : std_logic;
  signal INTSEL         : std_logic;
  signal o_resetn       : std_logic;
  signal o_TXD_0        : std_logic;
  signal o_TXD_1        : std_logic;
  signal o_txen         : std_logic;
  
  signal OUT_en_mode0   : std_logic := '1';
  signal OUT_en_mode1   : std_logic := '1';
  signal OUT_en_mode2   : std_logic := '1';
  signal OUT_en_phyad0   : std_logic := '1';
  signal OUT_en_REFCLK0  : std_logic := '1';

  -- cnt & flag_cnt
  signal cnt_100us : integer range 0 to 16383;
  signal cnt_32 : integer range 0 to CONST_cnt_32;
  signal flag_100us : std_logic;
  signal write_round : natural range 0 to CONST_ROUND;

  --delay & flag_edge
  signal fsync_d1 : std_logic;
  signal fsync_d2 : std_logic;
  --signal fsync_d3 : std_logic;
  signal falling_edge_fsync : std_logic;
  signal rising_edge_fsync : std_logic;

  --reg
  signal channel_all_wire : std_logic_vector(CONST_send-1 downto 0);
  --signal channel_all : std_logic_vector(CONST_send-1 downto 0);
  signal channel_feet_1 : std_logic;
  signal channel_feet_2 : std_logic;    --Ethernet transmitts two bits data
                                        --every clk_50MHz

  -- others
  signal channel_test : std_logic_vector(63 downto 0) := x"5700fc011101fc11";
  signal channel_test_send : std_logic_vector(63 downto 0) := x"d5003f4044403f44";
  signal channel_test_000 : std_logic_vector(79 downto 0) := x"00000000000000000000";
  signal channel_test_144 : std_logic_vector(143 downto 0) ;
  signal channel_test_check_144 : std_logic_vector(143 downto 0) ;
 -- signal crc_start : std_logic := '0';

  
  -- declaration
  -- component IP_HEAD_CHECK_SUM_CAL_MDL is
  --   port (
  --     -- Input Ports
  --     I_OPR_CLK      : in std_logic;
  --     I_OPR_RSTN     : in std_logic;
  --     I_CAL_EN       : in std_logic;
  --     I_IP_HEAD_VER  : in std_logic_vector(3 downto 0);
  --     I_IP_HEAD_LEN  : in std_logic_vector(3 downto 0);
  --     I_IP_HEAD_TOS  : in std_logic_vector(7 downto 0);
  --     I_IP_HEAD_TOTLEN : in std_logic_vector(15 downto 0);
  --     I_IP_HEAD_ID   : in std_logic_vector(15 downto 0);
  --     I_IP_HEAD_FLAG : in std_logic_vector(2 downto 0);
  --     I_IP_HEAD_OFFSET : in std_logic_vector(12 downto 0);
  --     I_IP_HEAD_TTL  : in std_logic_vector(7 downto 0);
  --     I_IP_HEAD_PROT : in std_logic_vector(7 downto 0);
  --     I_IP_HEAD_SRC_ADDR : in std_logic_vector(31 downto 0);
  --     I_IP_HEAD_DST_ADDR : in std_logic_vector(31 downto 0);
  --     -- Output Ports
  --     O_IP_HEAD_CHECK_SUM : out std_logic_vector(15 downto 0)
  --     );
  -- end component IP_HEAD_CHECK_SUM_CAL_MDL;



  component CRC32_D8 is
    port (
      -- input/output ports
      I_OPR_CLK  : in  std_logic;
      I_OPR_RSTN : in  std_logic;
      I_CRC_INIT : in  std_logic;
      I_CRC_EN   : in  std_logic;
      I_DATA     : in  std_logic_vector(143 downto 0);
      O_CRC_RES  : out std_logic_vector(31 downto 0)
      );
  end component CRC32_D8;


  
begin  -- architecture arch_TCP_Ethernet

  resetN        <= o_resetn;
  TXD1          <= o_TXD_1;
  TXD0          <= o_TXD_0;
  txen          <= o_txen;
  -- CRSDV_MODE2   <= mode2;
  -- RXD1_MODE1    <= mode1;
  -- RXD0_MODE0    <= mode0;
  -- RXERR_PHYAD0  <= PHYAD0;
  CRC_1<= CRC(7 downto 0) ;
  CRC_2 <= CRC(15 downto 8) ;
  CRC_3 <= CRC(23 downto 16) ;
  CRC_4<= CRC(31 downto 24);
  
--  CRC_new  <= CRC_1 & CRC_2 & CRC_3 & CRC_4;
  CRC_new  <= x"B972FCE8";
  
  channel_test_144 <= channel_test_send & channel_test_000 ;
  
  channel_test_check_144 <= channel_test & channel_test_000 ;
  
  
  channel_all_wire <= CONST_ETH_PREMABLE   
                      & CONST_ETH_SFD        
                      & DST_MAC_ADDR          --
                      & FPGA_MAC_ADDR         --
                      & CONST_ETH_TYPE       
                      -------------------- 
                      & CONST_IP_HEAD_LEN 
                      & CONST_IP_HEAD_VER    
                      
                      & CONST_IP_HEAD_TOS    
                      & IP_LENGTH             --
                      & CONST_IP_HEAD_ID     
                      & CONST_IP_HEAD_FLAG   
                      & CONST_IP_HEAD_OFFSET 
                      & CONST_IP_HEAD_TTL    
                      & CONST_IP_HEAD_PROT   
                      
--                      & IP_HEAD_CHECK_SUM     --
                      & IP_HEAD_9f3e_CHECK_SUM
                      
                      & DST_IP_ADDR           --
                      & FPGA_IP_ADDR          --
                      --------------------
                      & DST_UDP_PROT  
                      & FPGA_UDP_PROT        
                      
                      & UDP_LEN              
                      & UDP_HEAD_CHECK
                      & channel_1(9 downto 8) & channel_1(11 downto 10) & channel_1(13 downto 12) & channel_1(15 downto 14)
                      & channel_1(1 downto 0) & channel_1(3 downto 2)   & channel_1(5 downto 4)   & channel_1(7 downto 6) 
                      
                      & channel_2(9 downto 8) & channel_2(11 downto 10) & channel_2(13 downto 12) & channel_2(15 downto 14)
                      & channel_2(1 downto 0) & channel_2(3 downto 2)   & channel_2(5 downto 4)   & channel_2(7 downto 6) 
                      
                      & channel_3(9 downto 8) & channel_3(11 downto 10) & channel_3(13 downto 12) & channel_3(15 downto 14)
                      & channel_3(1 downto 0) & channel_3(3 downto 2)   & channel_3(5 downto 4)   & channel_3(7 downto 6) 
                      
                      & channel_4(9 downto 8) & channel_4(11 downto 10) & channel_4(13 downto 12) & channel_4(15 downto 14)
                      & channel_4(1 downto 0) & channel_4(3 downto 2)   & channel_4(5 downto 4)   & channel_4(7 downto 6) 

                      --& channel_1 & channel_2 & channel_3 & channel_4 
                      & channel_test_000
                      --& channel_test_144
                      & CRC_new;
  
  ----------------------------------------  
  CLKIN         <= clk_50MHz;
  --REFCLK0       <= clk_50MHz;
  RXD0_MODE0    <= MODE0 when OUT_en_mode0='1' else
                   'Z';
  RXD1_MODE1    <= MODE1 when OUT_en_mode1='1' else
                   'Z';
  CRSDV_MODE2   <= MODE2 when OUT_en_mode2='1' else
                   'Z';
  RXERR_PHYAD0  <= PHYAD0 when OUT_en_phyad0='1' else
                   'Z';
  INTN_REFCLK0  <= INTSEL when OUT_en_REFCLK0='1' else
                   'Z';
----------------------------------------
  proc_100us_count: process (clk, rstn) is
  begin  -- process proc_100us_count
    if rstn = '0' then                  -- asynchronous reset (active low)
      cnt_100us <= 1;
      flag_100us <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      
      if cnt_100us = 16383 then
        flag_100us <= '1';
        cnt_100us <= 0;
      else
        flag_100us <= '0';
        cnt_100us <= cnt_100us + 1;
      end if;
    end if;
  end process proc_100us_count;

  proc_32_count: process (clk, rstn) is
  begin  -- process proc_32_count
    if rstn = '0' then                  -- asynchronous reset (active low)
      cnt_32 <= 0;
    elsif clk'event and clk = '1' then  -- rising clock edge
      if o_txen = '1' and clk_50MHz='0'then
        if cnt_32 < CONST_cnt_32  then
          cnt_32 <= cnt_32+1;
        else 
          cnt_32 <= 0;
        end if;
	
      elsif o_txen = '0' then
        cnt_32 <= 0;
      end if;
    end if;
  end process proc_32_count;

  ----------------------------------------
  proc_delay2: process (clk, rstn) is
  begin  -- process proc_delay2
    if rstn = '0' then                  -- asynchronous reset (active low)
      fsync_d1 <= '0';
      fsync_d2 <= '0';
      --fsync_d3 <= '0';
      --channel_all <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      fsync_d1 <= fsync;
      fsync_d2 <= fsync_d1;
      --fsync_d3 <= fsync_d2;

      if falling_edge_fsync='1' then
        --channel_all <= channel_all_wire;
      end if;
    end if;
  end process proc_delay2;

  falling_edge_fsync <= not(fsync_d1) and fsync_d2;
  rising_edge_fsync <=  fsync_d1 and not(fsync_d2);
  --crc_start <= not(fsync_d2) and fsync_d3;

  ----------------------------------------
  proc_state_transimit: process(clk,rstn) is
  begin
    if rstn = '0' then
      state <= IDLE;
      
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process proc_state_transimit;
  
  proc_state_flow: process (state,start,flag_100us, rising_edge_fsync,falling_edge_fsync,cnt_32,write_round) is
  begin  -- process proc_state_flow
    next_state <= IDLE;
    case state is
      when IDLE => 
        if start = '1' then
          next_state <= RESET_STATE;
        end if;
      when RESET_STATE  => 
        if flag_100us = '1' then
          next_state <= MODE_STATE;
        else
          next_state <= RESET_STATE;
        end if;

      when MODE_STATE  =>
        if falling_edge_fsync = '1' then
          next_state <= WRITE_STATE;
        else
          next_state <= MODE_STATE;
        end if;
        
      when  WRITE_STATE =>
        if cnt_32 = CONST_cnt_32  then
          next_state <= BACK_STATE;
        else
          next_state <= WRITE_STATE;
        end if;
      when BACK_STATE =>
        if write_round < CONST_ROUND-1 then
          if falling_edge_fsync = '1' then
            next_state <= WRITE_STATE;
          else
            next_state <= BACK_STATE;
          end if;
        else
          next_state <= END_STATE;
        end if;
        
      when END_STATE => 
        next_state <= END_STATE;
      when others => null;
    end case;
  end process proc_state_flow;

  proc_assingment: process (state,channel_feet_1,channel_feet_2) is
  begin  -- process proc_state_flow
    o_resetn <= '0';--
    mode2 <= '1';
    mode1 <= '1';
    mode0 <= '1';
    o_TXD_1 <= '0';
    o_TXD_0 <= '0';
    o_txen <= '0';
    PHYAD0  <= '0';--
    INTSEL   <= '1';--
    OUT_en_mode0  <= '1';
    OUT_en_mode1   <= '1';
    OUT_en_mode2  <= '1';
    OUT_en_phyad0   <= '1';
    OUT_en_REFCLK0  <= '1';
    --write_round <= 0;
    case state is
      when IDLE => 
        
        o_resetn <= '0';--
        mode2 <= '1';
        mode1 <= '1';
        mode0 <= '1';
        o_TXD_1 <= '0';
        o_TXD_0 <= '0';
        o_txen <= '0';
        PHYAD0  <= '0';--
        INTSEL   <= '1';--
        OUT_en_mode0  <= '1';
        OUT_en_mode1   <= '1';
        OUT_en_mode2  <= '1';
        OUT_en_phyad0   <= '1';
        OUT_en_REFCLK0  <= '1';
        
       -- write_round <= 0;

        
      when RESET_STATE  => 
        o_resetn <= '0';
        mode2 <= '1';
        mode1 <= '1';
        mode0 <= '1';
        o_TXD_1 <= '0';
        o_TXD_0 <= '0';
        o_txen <= '0';
        PHYAD0  <= '0';--
        INTSEL   <= '1';--
        --write_round <= 0;

        OUT_en_mode0  <= '1';
        OUT_en_mode1   <= '1';
        OUT_en_mode2  <= '1';
        OUT_en_phyad0   <= '1';
        OUT_en_REFCLK0  <= '1';

        
      when MODE_STATE  =>
        o_resetn <= '1';
        mode2 <= '1';
        mode1 <= '1';
        mode0 <= '1';
        o_TXD_1 <= '0';
        o_TXD_0 <= '0';
        o_txen <= '0';
        --write_round <= 0;

--        OUT_en_mode0  <= '0';
--        OUT_en_mode1   <= '0';
--        OUT_en_mode2  <= '0';
--        OUT_en_phyad0   <= '0';
--        OUT_en_REFCLK0  <= '0';
        PHYAD0  <= '1';--
        OUT_en_mode0  <= '1';
        OUT_en_mode1   <= '1';
        OUT_en_mode2  <= '1';
        OUT_en_phyad0   <= '1';
        OUT_en_REFCLK0  <= '1';
        INTSEL   <= '0';

        
      when WRITE_STATE =>
        o_resetn <= '1';
        mode2 <= '1';
        mode1 <= '1';
        mode0 <= '1';
        o_TXD_1 <= channel_feet_2;
        o_TXD_0 <= channel_feet_1;
        o_txen <= '1';
        --write_round <= write_round;
      when BACK_STATE =>
        o_resetn <= '1';
        mode2 <= '1';
        mode1 <= '1';
        mode0 <= '1';
        o_TXD_1 <= '0';
        o_TXD_0 <= '0';
        o_txen <= '0';
        --write_round <= write_round+1;
      when END_STATE  => 
        o_resetn <= '1';
        mode2 <= '1';
        mode1 <= '1';
        mode0 <= '1';
        o_TXD_1 <= '0';
        o_TXD_0 <= '0';
        o_txen <= '0';
        --write_round <= 0;
      when others => null;
    end case;
  end process proc_assingment;

----------------------------------------
  proc_clk50MHz: process (clk, rstn) is
  begin  -- process proc_clk50MHz
    if rstn = '0' then                  -- asynchronous reset (active low)
      clk_50MHz <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      clk_50MHz <= not(clk_50MHz);
    end if;
  end process proc_clk50MHz;
----------------------------------------
  proc_feet: process (clk, rstn) is
  begin  -- process proc_sync_round_count
    if rstn = '0' then                  -- asynchronous reset (active low)
      channel_feet_1 <= '0';
      channel_feet_2 <= '0';
    elsif clk'event and clk = '0' then  -- falling clock edge
      if clk_50MHz='0' and state = write_state then
        -- channel_feet_1 <= channel_all(CONST_send-1-cnt_32*2);
        -- channel_feet_2 <= channel_all(CONST_send-1-(cnt_32*2+1));
        channel_feet_1 <= channel_all_wire(CONST_send-1-(cnt_32*2+1));
        channel_feet_2 <= channel_all_wire(CONST_send-1-(cnt_32*2));
      end if;
    end if;
  end process proc_feet;
  
  proc_cnt_round:process (clk, rstn) is
  begin
    if rstn = '0' then
        write_round <= 0;
    elsif rising_edge(clk) then
        if next_state = BACK_STATE and o_txen='1' then
            write_round <= write_round +1;
        end if;
    end if;
    end process proc_cnt_round;
  
  
  --------------------------------------------------------------------------------
  --------------------------------------------------------------------------------
  inst_CRC : CRC32_D8
    port map (
      I_OPR_CLK  => clk,
      I_OPR_RSTN => rstn,
      I_CRC_INIT => fsync,
      I_CRC_EN   => falling_edge_fsync,
      I_DATA     => channel_test_check_144,
      O_CRC_RES  => CRC
      );

  -- inst_IP_CHECK : IP_HEAD_CHECK_SUM_CAL_MDL
  --   port map (
  --     I_OPR_CLK           => clk,
  --     I_OPR_RSTN          => rstn,
  --     I_CAL_EN            => o_txen,
  --     I_IP_HEAD_VER       => CONST_IP_HEAD_VER,
  --     I_IP_HEAD_LEN       => CONST_IP_HEAD_LEN,
  --     I_IP_HEAD_TOS       => CONST_IP_HEAD_TOS,
  --     I_IP_HEAD_TOTLEN    => IP_LENGTH,
  --     I_IP_HEAD_ID        => CONST_IP_HEAD_ID,
  --     I_IP_HEAD_FLAG      => CONST_IP_HEAD_FLAG,
  --     I_IP_HEAD_OFFSET    => CONST_IP_HEAD_OFFSET,
  --     I_IP_HEAD_TTL       => CONST_IP_HEAD_TTL,
  --     I_IP_HEAD_PROT      => CONST_IP_HEAD_PROT,
  --     I_IP_HEAD_SRC_ADDR  => FPGA_IP_ADDR,
  --     I_IP_HEAD_DST_ADDR  => DST_IP_ADDR,
  --     O_IP_HEAD_CHECK_SUM => IP_HEAD_CHECK_SUM
  --     );

end architecture arch_UDP_Ethernet;


