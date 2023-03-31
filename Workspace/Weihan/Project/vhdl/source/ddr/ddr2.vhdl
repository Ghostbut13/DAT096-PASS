-------------------------------------------------------------------------------
-- Title      : ddr control
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ddr2.vhdl
-- Author     :   <ASUS@LAPTOP-M6B560H3>
-- Company    : 
-- Created    : 2023-03-06
-- Last update: 2023-03-06
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-- DDR for store the audio stream datas when write_start
-- when reach to the desired depth(depends on audio time)
-- we stop write the data. and wating for read_start,
-- we read data from ddr and transmit them to ethernet
-------------------------------------------------------------------------------
-- copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-03-06  1.0      ASUS	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ddr2 is
  
  port (
    clk        : in    std_logic;
    rst        : in    std_logic;
    
    ddr2_addr  : out   std_logic_vector(12 downto 0);
    ddr2_ba    : out   std_logic_vector(2 downto 0);
    ddr2_cas_n : out   std_logic;
    ddr2_ck_n  : out   std_logic_vector( 0 to 0 );
    ddr2_ck_p  : out   std_logic_vector( 0 to 0 );
    ddr2_cke   : out   std_logic_vector( 0 to 0 );
    ddr2_ras_n : out   std_logic;
    ddr2_we_n  : out   std_logic;
    
    ddr2_dq    : inout std_logic_vector(15 downto 0);
    ddr2_dqs_n : inout std_logic_vector(1 downto 0);
    ddr2_dqs_p : inout std_logic_vector(1 downto 0);

    
    init_calib_complete : out std_logic;
    ddr2_cs_n   : out std_logic_vector( 0 to 0 );
    ddr2_dm     : out std_logic_vector(1 downto 0);
    ddr2_odt   : out std_logic_vector( 0 to 0 )

    );

end entity ddr2;


architecture arch_ddr2 of ddr2 is
  -- constant
  constant WRITE        : std_logic_vector(2 downto 0) := "000";
  constant READ         : std_logic_vector(2 downto 0) := "000";

  -- fsm type
  type ddr_state is (IDLE,CMD, WR_DATA,WR_END,RD_WAIT,RD_DATA,ENDING);
  signal state          : ddr_state;
  signal next_state     : ddr_state;

  -- interface
  signal clk_ref_i      : std_logic;
  signal app_addr       : std_logic_vector(26 downto 0); --data addr: bank-4bit+line-3bit+col-10bit
  signal app_cmd        : std_logic_vector(2 downto 0) ; --instrument
  signal app_en         : std_logic;                     --'1' to send instrument
  signal app_wdf_data   : std_logic_vector(127 downto 0); --data
  signal app_wdf_mask   : std_logic_vector(15 downto 0);
  signal app_wdf_end    : std_logic;    --when the input data is end, it is '1'
  signal app_wdf_wren   : std_logic;    --wr_en: when data ready , '1'
  signal app_wdf_rdy    : std_logic;    --'1' when ddr is ready
  
  signal app_rd_data    : std_logic_vector(127 downto 0);
  signal app_rd_data_end : std_logic;
  signal app_rd_data_valid : std_logic; --ready to read data from ddr
  signal app_rdy        : std_logic;    -- flag '1' show the instrument sended
                                        -- and finish initial ddr
                                        -- no full
                                        -- no other else read
  
  signal app_sr_req     : std_logic;    -- always '0'
  signal app_ref_req    : std_logic;    --
  signal app_zq_req     : std_logic;
  signal app_sr_active  : std_logic;
  signal app_ref_ack    : std_logic;
  signal app_zq_ack     : std_logic;
  signal ui_clk         : std_logic;    -- ip output
  signal ui_clk_sync_rst : std_logic;   -- ip output

  -- control signal
  signal addr_start       : std_logic_vector(26 downto 0) ;
  signal wrh_rdl          : std_logic;  --'1': write
                                        --'0': read
  signal command          : std_logic_vector(2 downto 0);
  signal command_d        : std_logic_vector(2 downto 0);
  signal data_start       : std_logic_vector(15 downto 0);
  signal write_length     : unsigned(7 downto 0);
  signal write_count      : unsigned(7 downto 0);
  signal read_length      : unsigned(7 downto 0) ;
  signal read_count       : unsigned(7 downto 0);
  signal data_from_RAM    : std_logic_vector(127 downto 0);
  -- output reg	
  signal init_calib_complete_signal : std_logic;
  signal sys_clk_i : std_logic;
  signal locked: std_logic;
  -- component declare
  component clk_wiz_0 is
    port(
      clk_out1 : out std_logic;
      clk_out2 : out std_logic;
      reset : in std_logic;
      locked : out std_logic;
      clk_in1 : in std_logic
      );
  end component clk_wiz_0;

  component mig_7series_0 is
    port(
      ddr2_dq : inout STD_LOGIC_VECTOR ( 15 downto 0 );
      ddr2_dqs_p : inout STD_LOGIC_VECTOR ( 1 downto 0 );
      ddr2_dqs_n : inout STD_LOGIC_VECTOR ( 1 downto 0 );
      ddr2_addr : out STD_LOGIC_VECTOR ( 12 downto 0 );
      ddr2_ba : out STD_LOGIC_VECTOR ( 2 downto 0 );
      ddr2_ras_n : out STD_LOGIC;
      ddr2_cas_n : out STD_LOGIC;
      ddr2_we_n : out STD_LOGIC;
      ddr2_ck_p : out STD_LOGIC_VECTOR ( 0 to 0 );
      ddr2_ck_n : out STD_LOGIC_VECTOR ( 0 to 0 );
      ddr2_cke : out STD_LOGIC_VECTOR ( 0 to 0 );
      ddr2_cs_n : out STD_LOGIC_VECTOR ( 0 to 0 );
      ddr2_dm : out STD_LOGIC_VECTOR ( 1 downto 0 );
      ddr2_odt : out STD_LOGIC_VECTOR ( 0 to 0 );
      app_addr : in STD_LOGIC_VECTOR ( 26 downto 0 );
      app_cmd : in STD_LOGIC_VECTOR ( 2 downto 0 );
      app_en : in STD_LOGIC;
      app_wdf_data : in STD_LOGIC_VECTOR ( 127 downto 0 );
      app_wdf_end : in STD_LOGIC;
      app_wdf_mask : in STD_LOGIC_VECTOR ( 15 downto 0 );
      app_wdf_wren : in STD_LOGIC;
      app_rd_data : out STD_LOGIC_VECTOR ( 127 downto 0 );
      app_rd_data_end : out STD_LOGIC;
      app_rd_data_valid : out STD_LOGIC;
      app_rdy : out STD_LOGIC;
      app_wdf_rdy : out STD_LOGIC;
      app_sr_req : in STD_LOGIC;
      app_ref_req : in STD_LOGIC;
      app_zq_req : in STD_LOGIC;
      app_sr_active : out STD_LOGIC;
      app_ref_ack : out STD_LOGIC;
      app_zq_ack : out STD_LOGIC;
      ui_clk : out STD_LOGIC;
      ui_clk_sync_rst : out STD_LOGIC;
      init_calib_complete : out STD_LOGIC;
      sys_clk_i : in STD_LOGIC;
      clk_ref_i : in STD_LOGIC;
      sys_rst : in STD_LOGIC
      );
  end component mig_7series_0;


begin  -- architecture arch_ddr2

  init_calib_complete <= init_calib_complete_signal;

  ------------------------------------------

  inst_clk_gen : clk_wiz_0 
    port map (
      clk_out1 => sys_clk_i,
      clk_out2 => clk_ref_i,
      locked  => locked,
      reset    => rst,
      clk_in1  => clk
      );

  inst_ddr2 : mig_7series_0
    port map (
      ddr2_addr                      =>   ddr2_addr,            
      ddr2_ba                        =>   ddr2_ba,              
      ddr2_cas_n                     =>   ddr2_cas_n,           
      ddr2_ck_n                      =>   ddr2_ck_n,            
      ddr2_ck_p                      =>   ddr2_ck_p,            
      ddr2_cke                       =>   ddr2_cke,             
      ddr2_ras_n                     =>   ddr2_ras_n,           
      ddr2_we_n                      =>   ddr2_we_n,            
      ddr2_dq                        =>   ddr2_dq,              
      ddr2_dqs_n                     =>   ddr2_dqs_n,           
      ddr2_dqs_p                     =>   ddr2_dqs_p,           
      init_calib_complete            =>   init_calib_complete_signal,  
      ddr2_cs_n                      =>   ddr2_cs_n,            
      ddr2_dm                        =>   ddr2_dm,              
      ddr2_odt                       =>   ddr2_odt,             

      app_addr                       =>   app_addr,             
      app_cmd                        =>   app_cmd,              
      app_en                         =>   app_en,               
      app_wdf_data                   =>   app_wdf_data,         
      app_wdf_end                    =>   app_wdf_end,          
      app_wdf_wren                   =>   app_wdf_wren,         
      app_rd_data                    =>   app_rd_data,          
      app_rd_data_end                =>   app_rd_data_end,      
      app_rd_data_valid              =>   app_rd_data_valid,    
      app_rdy                        =>   app_rdy,              
      app_wdf_rdy                    =>   app_wdf_rdy,          
      app_sr_req                     =>   app_sr_req,           
      app_ref_req                    =>   app_ref_req,          
      app_zq_req                     =>   app_zq_req,           
      app_sr_active                  =>   app_sr_active,        
      app_ref_ack                    =>   app_ref_ack,          
      app_zq_ack                     =>   app_zq_ack,           
      ui_clk                         =>   ui_clk,               
      ui_clk_sync_rst                =>   ui_clk_sync_rst,      
      app_wdf_mask                   =>   app_wdf_mask,         

      sys_clk_i                      =>   sys_clk_i,

      clk_ref_i                      =>   clk_ref_i,  
      sys_rst                        =>   rst   
      );
  
  ----------------------------------------

  proc_config_optional_signal: process (ui_clk, ui_clk_sync_rst) is
  begin  -- process proc_config_optional_signal
    if ui_clk_sync_rst = '1' then               -- asynchronous reset (active low)
      app_wdf_mask <= x"0000";
      app_sr_req <= '0';
      app_ref_req <= '0';
      app_zq_req <= '0';
    elsif ui_clk'event and ui_clk = '1' then  -- rising clock edge
      app_wdf_mask <= x"0000";
      app_sr_req <= '0';
      app_ref_req <= '0';
      app_zq_req <= '0';
    end if;
  end process proc_config_optional_signal;
  
  proc_fsm_transimit: process (ui_clk, ui_clk_sync_rst) is
  begin  -- process fsm_transimit
    if ui_clk_sync_rst='1' then
      state <= IDLE;
    elsif rising_edge(ui_clk) then
      if init_calib_complete_signal='0' then
        state <= IDLE;
      else
        state <= next_state;
      end if;
    end if;
  end process proc_fsm_transimit;

  proc_state_flow: process (state,ui_clk,
                                app_rdy,wrh_rdl,write_count,app_rd_data_valid,read_count,
                             write_length,read_length) is
  begin  -- process proc_state_flow
  if rising_edge(ui_clk) then
    case state is
      when IDLE  =>
        next_state <= CMD;
      when CMD  =>
        if app_rdy = '1' then
          if wrh_rdl='1' then
            next_state <= WR_DATA;
          else
            next_state <= RD_DATA;
          end if;
        else
          next_state <= CMD;
        end if;
      when WR_DATA =>
        if(write_count < write_length) then
          next_state <= WR_DATA;
        else 
          next_state <= WR_END;
        end if;
      when WR_END =>
        next_state <= ENDING;
      when RD_WAIT =>
        if app_rd_data_valid = '1' then
          next_state <= RD_DATA;
        else
          next_state <= RD_WAIT;
        end if;
      when RD_DATA  =>
        if  read_count < read_length then
          next_state <= RD_DATA;
        else
          next_state <= ENDING; --      wait until read data valid
        end if; 
      when ENDING  =>
        next_state <= IDLE;       
      when others => 
        next_state <= IDLE;
    end case;
    end if;
  end process proc_state_flow;

  proc_state_assignment: process (state,ui_clk,
                                    app_rdy,addr_start,command,app_wdf_rdy,write_count,write_length,
                                   read_count,read_length,app_rd_data) is
  begin  -- process proc_state_assignment
  if rising_edge(ui_clk) then
    app_addr <= (others => '0');
    app_cmd <= READ;
    app_en <= '0';
    app_wdf_data <= (others => '0');
    app_wdf_end <= '0';
    app_wdf_wren <= '0';
    data_from_RAM <= (others => '0');
    write_count <= to_unsigned(0,8);
    read_count <= to_unsigned(0,8);
    
    case state is
      when IDLE =>
        app_addr <= (others => '0');
        app_cmd <= READ;
        app_en <= '0';
        app_wdf_data <= (others => '0');
        app_wdf_end <= '0';
        app_wdf_wren <= '0';
        data_from_RAM <= (others => '0');
        write_count <= to_unsigned(0,8);
        read_count <= to_unsigned(0,8);
      when CMD =>
        if app_rdy = '1' then
          app_addr <= addr_start;
          --app_wdf_data <= data_start & data_start & data_start & data_start & data_start & data_start & data_start & data_start ;
          app_cmd <= command;
          app_en <= '1';
        end if;
      when WR_DATA =>
        app_wdf_wren <= '1';
        if(app_wdf_rdy = '1') then
        --app_wdf_data <= {8{app_wdf_data[15:0] + 16'h0001}}; -- change the data only when the FIFO is available
        end if;
        if(write_count < write_length) then
          write_count <= write_count + to_unsigned(16#1#,8);
        end if;                                                                                  
      when WR_END =>
        app_en <= '0';
        if(app_wdf_rdy = '1') then
        --app_wdf_data <= {8{app_wdf_data[15:0] + 16'h0001}}; -- write the last data
        end if;
        app_wdf_end <= '1';   --assert write end
        app_wdf_wren <= '0';
        
      when RD_WAIT => 
        
      when RD_DATA =>
        if(read_count < read_length) then
          data_from_RAM <= app_rd_data;
          read_count <= read_count + to_unsigned(16#1#,8);
        else
          
        end if;
      when ENDING =>
        app_en <= '0';
        read_count <= to_unsigned(0,8);
        write_count <= to_unsigned(0,8);
        app_wdf_end <= '0';
      when others => null;
    end case;
    end if;
  end process proc_state_assignment;


  proc_initial_addr_data: process ( ui_clk_sync_rst , ui_clk) is
  begin  -- process proc_initial_addr_data
    if rising_edge(ui_clk) then
      if ui_clk_sync_rst='1' then
        addr_start <= (others => '0');
        data_start <= (others => '0') ;
        write_length <= to_unsigned(8,8);
        read_length <= to_unsigned(8,8);
      else
        addr_start <= (others => '0');
        data_start <= (others => '0');
        write_length <= to_unsigned(8,8);
        read_length <= to_unsigned(8,8);
      end if;
    end if;
  end process proc_initial_addr_data;


  proc_control: process (ui_clk_sync_rst , ui_clk) is
  begin  -- process proc_control
    if ui_clk_sync_rst='1' then
      command <= WRITE;
      command_d <= WRITE;
      wrh_rdl <= '1';
    elsif rising_edge(ui_clk) then
      if state = ENDING then
        if command(0)='1' then
          command_d <= WRITE;
          wrh_rdl <= '0';
        else
          command_d <= READ;
          wrh_rdl <= '1';
        end if;
        command <= command_d;
      end if;
    end if;
  end process proc_control;



end architecture arch_ddr2;
