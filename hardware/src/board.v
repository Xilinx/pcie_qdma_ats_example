//-----------------------------------------------------------------------------
//
// (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
//
//-----------------------------------------------------------------------------
//
// Project    : The Xilinx PCI Express DMA 
// File       : board.v
// Version    : 5.0
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//
// Project    : Ultrascale FPGA Gen3 Integrated Block for PCI Express
// File       : board.v
// Version    : 4.0 
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//
// Description: Top level testbench
//
//------------------------------------------------------------------------------

`timescale 1ps/1ps

`include "board_common.vh"

`define SIMULATION

module board;

  parameter          REF_CLK_FREQ       = 0 ;      // 0 - 100 MHz, 1 - 125 MHz,  2 - 250 MHz




  localparam         REF_CLK_HALF_CYCLE = (REF_CLK_FREQ == 0) ? 5000 :
                                          (REF_CLK_FREQ == 1) ? 4000 :
                                          (REF_CLK_FREQ == 2) ? 2000 : 0;
  localparam   [2:0] PF0_DEV_CAP_MAX_PAYLOAD_SIZE = 3'b011;
  `ifdef LINKWIDTH
  localparam   [4:0] LINK_WIDTH = 5'd`LINKWIDTH;
  `else
  localparam   [4:0] LINK_WIDTH = 5'd8;
  `endif
  `ifdef LINKSPEED
  localparam   [2:0] LINK_SPEED = 3'h`LINKSPEED;
  `else
  localparam   [2:0] LINK_SPEED = 3'h4;
  `endif



  defparam board.EP.design_1_i.qdma_0.inst.pcie4c_ip_i.inst.PL_SIM_FAST_LINK_TRAINING=2'h3;




  localparam EXT_PIPE_SIM = "TRUE";
//
//
  defparam board.EP.design_1_i.qdma_0.inst.pcie4c_ip_i.inst.EXT_PIPE_SIM = "TRUE";
//
//
  defparam board.RP.pcie_4_0_rport.pcie_4_0_int_inst.EXT_PIPE_SIM = "TRUE";
  defparam board.RP.EXT_PIPE_SIM = "TRUE";

  integer            i;

  // System-level clock and reset
  reg                sys_rst_n;

  wire               ep_sys_clk;
  wire               rp_sys_clk;
  wire               ep_sys_clk_p;
  wire               ep_sys_clk_n;
  wire               rp_sys_clk_p;
  wire               rp_sys_clk_n;



  //
  // PCI-Express Serial Interconnect
  //
  wire  [8:0 ]  pci_express_x8_rxn;
  wire  [8:0 ]  pci_express_x8_rxp;
  wire          disable_hbm_cattrip;
  
  // Simulating UART
  wire  rs232_uart_txd;
  wire  rs232_uart_rxd;
  assign rs232_uart_rxd = 1'b0;
  
  
  // Setting to zero because using PIPE sim
  assign pci_express_x8_rxn = 8'd0;
  assign pci_express_x8_rxp = 8'd0;
  
  

  // Xilinx Pipe Interface
  wire  [25:0]  common_commands_out;
  wire  [83:0]  xil_tx0_sigs_ep;
  wire  [83:0]  xil_tx1_sigs_ep;
  wire  [83:0]  xil_tx2_sigs_ep;
  wire  [83:0]  xil_tx3_sigs_ep;
  wire  [83:0]  xil_tx4_sigs_ep;
  wire  [83:0]  xil_tx5_sigs_ep;
  wire  [83:0]  xil_tx6_sigs_ep;
  wire  [83:0]  xil_tx7_sigs_ep;
  wire  [83:0]  xil_tx8_sigs_ep;
  wire  [83:0]  xil_tx9_sigs_ep;
  wire  [83:0]  xil_tx10_sigs_ep;
  wire  [83:0]  xil_tx11_sigs_ep;
  wire  [83:0]  xil_tx12_sigs_ep;
  wire  [83:0]  xil_tx13_sigs_ep;
  wire  [83:0]  xil_tx14_sigs_ep;
  wire  [83:0]  xil_tx15_sigs_ep;

  wire  [83:0]  xil_rx0_sigs_ep;
  wire  [83:0]  xil_rx1_sigs_ep;
  wire  [83:0]  xil_rx2_sigs_ep;
  wire  [83:0]  xil_rx3_sigs_ep;
  wire  [83:0]  xil_rx4_sigs_ep;
  wire  [83:0]  xil_rx5_sigs_ep;
  wire  [83:0]  xil_rx6_sigs_ep;
  wire  [83:0]  xil_rx7_sigs_ep;
  wire  [83:0]  xil_rx8_sigs_ep;
  wire  [83:0]  xil_rx9_sigs_ep;
  wire  [83:0]  xil_rx10_sigs_ep;
  wire  [83:0]  xil_rx11_sigs_ep;
  wire  [83:0]  xil_rx12_sigs_ep;
  wire  [83:0]  xil_rx13_sigs_ep;
  wire  [83:0]  xil_rx14_sigs_ep;
  wire  [83:0]  xil_rx15_sigs_ep;

  wire  [83:0]  xil_tx0_sigs_rp;
  wire  [83:0]  xil_tx1_sigs_rp;
  wire  [83:0]  xil_tx2_sigs_rp;
  wire  [83:0]  xil_tx3_sigs_rp;
  wire  [83:0]  xil_tx4_sigs_rp;
  wire  [83:0]  xil_tx5_sigs_rp;
  wire  [83:0]  xil_tx6_sigs_rp;
  wire  [83:0]  xil_tx7_sigs_rp;
  wire  [83:0]  xil_tx8_sigs_rp;
  wire  [83:0]  xil_tx9_sigs_rp;
  wire  [83:0]  xil_tx10_sigs_rp;
  wire  [83:0]  xil_tx11_sigs_rp;
  wire  [83:0]  xil_tx12_sigs_rp;
  wire  [83:0]  xil_tx13_sigs_rp;
  wire  [83:0]  xil_tx14_sigs_rp;
  wire  [83:0]  xil_tx15_sigs_rp;

  //------------------------------------------------------------------------------//
  // Generate system clock
  //------------------------------------------------------------------------------//
  sys_clk_gen_ds # (
    .halfcycle(REF_CLK_HALF_CYCLE), 
    .offset(0)
  )
  CLK_GEN_RP (
    .sys_clk_p(rp_sys_clk_p),
    .sys_clk_n(rp_sys_clk_n)
  );

  sys_clk_gen_ds # (
    .halfcycle(REF_CLK_HALF_CYCLE),
    .offset(0)
  )
  CLK_GEN_EP (
    .sys_clk_p(ep_sys_clk_p),
    .sys_clk_n(ep_sys_clk_n)
  );



  //------------------------------------------------------------------------------//
  // Generate system-level reset
  //------------------------------------------------------------------------------//
  parameter ON=3, OFF=4, UNIQUE=32, UNIQUE0=64, PRIORITY=128;

  initial begin
    `ifndef XILINX_SIMULATOR
    // Disable UNIQUE, UNIQUE0, and PRIORITY analysis during reset because signal can be at unknown value during reset
    $assertcontrol( OFF , UNIQUE | UNIQUE0 | PRIORITY);
    `endif

    $display("[%t] : System Reset Is Asserted...", $realtime);
    sys_rst_n = 1'b0;
    repeat (500) @(posedge rp_sys_clk_p);
    $display("[%t] : System Reset Is De-asserted...", $realtime);
    sys_rst_n = 1'b1;

    `ifndef XILINX_SIMULATOR
    // Re-enable UNIQUE, UNIQUE0, and PRIORITY analysis
    $assertcontrol( ON , UNIQUE | UNIQUE0 | PRIORITY);
    `endif
  end
  //------------------------------------------------------------------------------//
  
  
  //------------------------------------------------------------------------------//
  // EndPoint DUT with PIO Slave
  //------------------------------------------------------------------------------//
  //
  // PCI-Express Endpoint Instance
  //
  
  design_1_wrapper_sim EP (
    .pci_express_x8_rxn(pci_express_x8_rxn),
    .pci_express_x8_rxp(pci_express_x8_rxp),
    .pci_express_x8_txn(),
    .pci_express_x8_txp(),
    .pcie_ext_pipe_ep_usp_0_commands_in(common_commands_out),
    .pcie_ext_pipe_ep_usp_0_commands_out(26'd0), //[0] - pipe_clk out
    .pcie_ext_pipe_ep_usp_0_rx_0(xil_rx0_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_1(xil_rx1_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_2(xil_rx2_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_3(xil_rx3_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_4(xil_rx4_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_5(xil_rx5_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_6(xil_rx6_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_7(xil_rx7_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_8(xil_rx8_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_9(xil_rx9_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_10(xil_rx10_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_11(xil_rx11_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_12(xil_rx12_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_13(xil_rx13_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_14(xil_rx14_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_rx_15(xil_rx15_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_0(xil_tx0_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_1(xil_tx1_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_2(xil_tx2_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_3(xil_tx3_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_4(xil_tx4_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_5(xil_tx5_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_6(xil_tx6_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_7(xil_tx7_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_8(xil_tx8_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_9(xil_tx9_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_10(xil_tx10_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_11(xil_tx11_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_12(xil_tx12_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_13(xil_tx13_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_14(xil_tx14_sigs_ep),
    .pcie_ext_pipe_ep_usp_0_tx_15(xil_tx15_sigs_ep),
    .pcie_perstn(sys_rst_n),
    .pcie_refclk_clk_n(ep_sys_clk_n),
    .pcie_refclk_clk_p(ep_sys_clk_p),
    .rs232_uart_rxd(rs232_uart_rxd),
    .rs232_uart_txd(rs232_uart_txd),
    .disable_hbm_cattrip(disable_hbm_cattrip)
  );

  
  /*xilinx_qdma_pcie_ep
  #(
   .EXT_PIPE_SIM       (EXT_PIPE_SIM)
   )
   EP (
    // SYS Inteface
    .sys_clk_n(ep_sys_clk_n),
    .sys_clk_p(ep_sys_clk_p),
    .sys_rst_n(sys_rst_n),

  

    .led_0(led_0),
    .led_1(led_1),
    .led_2(led_2),

    // Xilinx Pipe Interface
    .common_commands_in (26'b0 ),
    .pipe_rx_0_sigs     (xil_rx0_sigs_ep),
    .pipe_rx_1_sigs     (xil_rx1_sigs_ep),
    .pipe_rx_2_sigs     (xil_rx2_sigs_ep),
    .pipe_rx_3_sigs     (xil_rx3_sigs_ep),
    .pipe_rx_4_sigs     (xil_rx4_sigs_ep),
    .pipe_rx_5_sigs     (xil_rx5_sigs_ep),
    .pipe_rx_6_sigs     (xil_rx6_sigs_ep),
    .pipe_rx_7_sigs     (xil_rx7_sigs_ep),
    .pipe_rx_8_sigs     (xil_rx8_sigs_ep),    
    .pipe_rx_9_sigs     (xil_rx9_sigs_ep),
    .pipe_rx_10_sigs    (xil_rx10_sigs_ep),
    .pipe_rx_11_sigs    (xil_rx11_sigs_ep),
    .pipe_rx_12_sigs    (xil_rx12_sigs_ep),
    .pipe_rx_13_sigs    (xil_rx13_sigs_ep),
    .pipe_rx_14_sigs    (xil_rx14_sigs_ep),
    .pipe_rx_15_sigs    (xil_rx15_sigs_ep),   
    .common_commands_out(common_commands_out), //[0] - pipe_clk out
    
    .pipe_tx_0_sigs     (xil_tx0_sigs_ep),
    .pipe_tx_1_sigs     (xil_tx1_sigs_ep),
    .pipe_tx_2_sigs     (xil_tx2_sigs_ep),
    .pipe_tx_3_sigs     (xil_tx3_sigs_ep),
    .pipe_tx_4_sigs     (xil_tx4_sigs_ep),
    .pipe_tx_5_sigs     (xil_tx5_sigs_ep),
    .pipe_tx_6_sigs     (xil_tx6_sigs_ep),
    .pipe_tx_7_sigs     (xil_tx7_sigs_ep),
    .pipe_tx_8_sigs     (xil_tx8_sigs_ep),
    .pipe_tx_9_sigs     (xil_tx9_sigs_ep),
    .pipe_tx_10_sigs     (xil_tx10_sigs_ep),
    .pipe_tx_11_sigs     (xil_tx11_sigs_ep),
    .pipe_tx_12_sigs     (xil_tx12_sigs_ep),
    .pipe_tx_13_sigs     (xil_tx13_sigs_ep),
    .pipe_tx_14_sigs     (xil_tx14_sigs_ep),
    .pipe_tx_15_sigs     (xil_tx15_sigs_ep)
  
  );*/

  //------------------------------------------------------------------------------//
  // Simulation Root Port Model
  // (Comment out this module to interface EndPoint with BFM)
  //------------------------------------------------------------------------------//
  //
  // PCI-Express Model Root Port Instance
  //

  xilinx_pcie4_uscale_rp
  #(
     .PF0_DEV_CAP_MAX_PAYLOAD_SIZE(PF0_DEV_CAP_MAX_PAYLOAD_SIZE)
     //ONLY FOR RP
  ) RP (

    // SYS Inteface
    .sys_clk_n(rp_sys_clk_n),
    .sys_clk_p(rp_sys_clk_p),
    .sys_rst_n                  ( sys_rst_n ),
    // Xilinx Pipe Interface
    .common_commands_in ({25'b0,common_commands_out[0]} ), // pipe_clk from EP
    .pipe_rx_0_sigs     ({45'b0,xil_rx0_sigs_ep[38:0]}),
    .pipe_rx_1_sigs     ({45'b0,xil_rx1_sigs_ep[38:0]}),
    .pipe_rx_2_sigs     ({45'b0,xil_rx2_sigs_ep[38:0]}),
    .pipe_rx_3_sigs     ({45'b0,xil_rx3_sigs_ep[38:0]}),
    .pipe_rx_4_sigs     ({45'b0,xil_rx4_sigs_ep[38:0]}),
    .pipe_rx_5_sigs     ({45'b0,xil_rx5_sigs_ep[38:0]}),
    .pipe_rx_6_sigs     ({45'b0,xil_rx6_sigs_ep[38:0]}),
    .pipe_rx_7_sigs     ({45'b0,xil_rx7_sigs_ep[38:0]}),
    .pipe_rx_8_sigs      ({45'b0,xil_rx8_sigs_ep[38:0]}),
    .pipe_rx_9_sigs      ({45'b0,xil_rx9_sigs_ep[38:0]}),
    .pipe_rx_10_sigs     ({45'b0,xil_rx10_sigs_ep[38:0]}),
    .pipe_rx_11_sigs     ({45'b0,xil_rx11_sigs_ep[38:0]}),
    .pipe_rx_12_sigs     ({45'b0,xil_rx12_sigs_ep[38:0]}),
    .pipe_rx_13_sigs     ({45'b0,xil_rx13_sigs_ep[38:0]}),
    .pipe_rx_14_sigs     ({45'b0,xil_rx14_sigs_ep[38:0]}),
    .pipe_rx_15_sigs     ({45'b0,xil_rx15_sigs_ep[38:0]}),    
    .common_commands_out(),
    .pipe_tx_0_sigs     (xil_tx0_sigs_rp),
    .pipe_tx_1_sigs     (xil_tx1_sigs_rp),
    .pipe_tx_2_sigs     (xil_tx2_sigs_rp),
    .pipe_tx_3_sigs     (xil_tx3_sigs_rp),
    .pipe_tx_4_sigs     (xil_tx4_sigs_rp),
    .pipe_tx_5_sigs     (xil_tx5_sigs_rp),
    .pipe_tx_6_sigs     (xil_tx6_sigs_rp),
    .pipe_tx_7_sigs     (xil_tx7_sigs_rp),
    .pipe_tx_8_sigs     (xil_tx8_sigs_rp),
    .pipe_tx_9_sigs     (xil_tx9_sigs_rp),
    .pipe_tx_10_sigs    (xil_tx10_sigs_rp),
    .pipe_tx_11_sigs    (xil_tx11_sigs_rp),
    .pipe_tx_12_sigs    (xil_tx12_sigs_rp),
    .pipe_tx_13_sigs    (xil_tx13_sigs_rp),
    .pipe_tx_14_sigs    (xil_tx14_sigs_rp),
    .pipe_tx_15_sigs    (xil_tx15_sigs_rp)
  
  
  );

  initial begin

    if ($test$plusargs ("dump_all")) begin

  `ifdef NCV // Cadence TRN dump

      $recordsetup("design=board",
                   "compress",
                   "wrapsize=100M",
                   "version=1",
                   "run=1");
      $recordvars();

  `elsif VCS //Synopsys VPD dump

      $vcdplusfile("board.vpd");
      $vcdpluson;
      $vcdplusglitchon;
      $vcdplusflush;

  `else

      // Verilog VC dump
      $dumpfile("board.vcd");
      $dumpvars(0, board);

  `endif

    end

  end
  
     assign xil_tx0_sigs_ep  = {45'b0,xil_tx0_sigs_rp[38:0]};
     assign xil_tx1_sigs_ep  = {45'b0,xil_tx1_sigs_rp[38:0]};
     assign xil_tx2_sigs_ep  = {45'b0,xil_tx2_sigs_rp[38:0]};
     assign xil_tx3_sigs_ep  = {45'b0,xil_tx3_sigs_rp[38:0]};
     assign xil_tx4_sigs_ep  = {45'b0,xil_tx4_sigs_rp[38:0]};
     assign xil_tx5_sigs_ep  = {45'b0,xil_tx5_sigs_rp[38:0]};
     assign xil_tx6_sigs_ep  = {45'b0,xil_tx6_sigs_rp[38:0]};
     assign xil_tx7_sigs_ep  = {45'b0,xil_tx7_sigs_rp[38:0]};

     assign xil_tx8_sigs_ep   = {45'b0,xil_tx8_sigs_rp[38:0]};
     assign xil_tx9_sigs_ep   = {45'b0,xil_tx9_sigs_rp[38:0]};
     assign xil_tx10_sigs_ep  = {45'b0,xil_tx10_sigs_rp[38:0]};
     assign xil_tx11_sigs_ep  = {45'b0,xil_tx11_sigs_rp[38:0]};
     assign xil_tx12_sigs_ep  = {45'b0,xil_tx12_sigs_rp[38:0]};
     assign xil_tx13_sigs_ep  = {45'b0,xil_tx13_sigs_rp[38:0]};
     assign xil_tx14_sigs_ep  = {45'b0,xil_tx14_sigs_rp[38:0]};
     assign xil_tx15_sigs_ep  = {45'b0,xil_tx15_sigs_rp[38:0]};
  //------------------------------------------------------------------------------//
  // Simulation with BFM 
  //------------------------------------------------------------------------------//
  //
  // PCI-Express use case with BFM Instance
  //
  //-----------------------------------------------------------------------------
  //-- Description:  Pipe Mode Interface
  //-- 16bit data for Gen1 rate @ Pipe Clk 125 
  //-- 16bit data for Gen2 rate @ Pipe Clk 250
  //-- 32bit data for Gen3 rate @ Pipe Clk 250  
  //-- For Gen1/Gen2 use case, tie-off rx*_start_block, rx*_data_valid, rx*_syncheader & rx*_data[31:16]
  //-- Pipe Clk is provided as output of this module - All pipe signals need to be aligned to provided Pipe Clk
  //-- pipe_tx_rate (00 - Gen1, 01 -Gen2 & 10- Gen3)
  //-- Rcvr Detect is handled internally by the core (Rcvr Detect Bypassed)
  //-- RX Status and PHY Status are handled internally (speed change & rcvr detect )
  //-- Phase2/3 needs to be disabled 
  //-- LF & FS values are 40 & 12 decimal
  //-- RP should provide TX preset hint of 5 (in EQ TS2's before changing rate to Gen3)
  //-----------------------------------------------------------------------------
//------------------------------------------------------------------------------//
  // Simulation with BFM 
  //------------------------------------------------------------------------------//
  //
  // PCI-Express use case with BFM Instance
  //
  //-----------------------------------------------------------------------------
  //-- Description:  Pipe Mode Interface
  //-- 16bit data for Gen1 rate @ Pipe Clk 125 
  //-- 16bit data for Gen2 rate @ Pipe Clk 250
  //-- 32bit data for Gen3 rate @ Pipe Clk 250  
  //-- For Gen1/Gen2 use case, tie-off rx*_start_block, rx*_data_valid, rx*_syncheader & rx*_data[31:16]
  //-- Pipe Clk is provided as output of this module - All pipe signals need to be aligned to provided Pipe Clk
  //-- pipe_tx_rate (00 - Gen1, 01 -Gen2 & 10- Gen3)
  //-- Rcvr Detect is handled internally by the core (Rcvr Detect Bypassed)
  //-- RX Status and PHY Status are handled internally (speed change & rcvr detect )
  //-- Phase2/3 needs to be disabled 
  //-- LF & FS values are 40 & 12 decimal
  //-- RP should provide TX preset hint of 5 (in EQ TS2's before changing rate to Gen3)
  //-----------------------------------------------------------------------------
  /*
   xil_sig2pipe xil_dut_pipe (
     .xil_rx0_sigs(xil_rx0_sigs_ep),
     .xil_rx1_sigs(xil_rx1_sigs_ep),
     .xil_rx2_sigs(xil_rx2_sigs_ep),
     .xil_rx3_sigs(xil_rx3_sigs_ep),
     .xil_rx4_sigs(xil_rx4_sigs_ep),
     .xil_rx5_sigs(xil_rx5_sigs_ep),
     .xil_rx6_sigs(xil_rx6_sigs_ep),
     .xil_rx7_sigs(xil_rx7_sigs_ep),
     .xil_rx8_sigs(xil_rx8_sigs_ep),
     .xil_rx9_sigs(xil_rx9_sigs_ep),
     .xil_rx10_sigs(xil_rx10_sigs_ep),
     .xil_rx11_sigs(xil_rx11_sigs_ep),
     .xil_rx12_sigs(xil_rx12_sigs_ep),
     .xil_rx13_sigs(xil_rx13_sigs_ep),
     .xil_rx14_sigs(xil_rx14_sigs_ep),
     .xil_rx15_sigs(xil_rx15_sigs_ep),
     .xil_tx0_sigs(xil_tx0_sigs_ep),
     .xil_tx1_sigs(xil_tx1_sigs_ep),
     .xil_tx2_sigs(xil_tx2_sigs_ep),
     .xil_tx3_sigs(xil_tx3_sigs_ep),
     .xil_tx4_sigs(xil_tx4_sigs_ep),
     .xil_tx5_sigs(xil_tx5_sigs_ep),
     .xil_tx6_sigs(xil_tx6_sigs_ep),
     .xil_tx7_sigs(xil_tx7_sigs_ep),     

     .xil_common_commands(common_commands_out),
      ///////////// do not modify above this line //////////
      //////////Connect the following pipe ports to BFM///////////////
     .pipe_clk(),               // input to BFM  (pipe clock output)                 
     .pipe_tx_rate(),           // input to BFM  (rate)
     .pipe_tx_detect_rx(),      // input to BFM  (Receiver Detect)  
     .pipe_tx_powerdown(),      // input to BFM  (Powerdown)  
      // Pipe TX Interface
     .pipe_tx0_data(),          // input to BFM
     .pipe_tx1_data(),          // input to BFM
     .pipe_tx2_data(),          // input to BFM
     .pipe_tx3_data(),          // input to BFM
     .pipe_tx4_data(),          // input to BFM
     .pipe_tx5_data(),          // input to BFM
     .pipe_tx6_data(),          // input to BFM
     .pipe_tx7_data(),          // input to BFM
     .pipe_tx0_char_is_k(),     // input to BFM
     .pipe_tx1_char_is_k(),     // input to BFM
     .pipe_tx2_char_is_k(),     // input to BFM
     .pipe_tx3_char_is_k(),     // input to BFM
     .pipe_tx4_char_is_k(),     // input to BFM
     .pipe_tx5_char_is_k(),     // input to BFM
     .pipe_tx6_char_is_k(),     // input to BFM
     .pipe_tx7_char_is_k(),     // input to BFM
     .pipe_tx0_elec_idle(),     // input to BFM
     .pipe_tx1_elec_idle(),     // input to BFM
     .pipe_tx2_elec_idle(),     // input to BFM
     .pipe_tx3_elec_idle(),     // input to BFM
     .pipe_tx4_elec_idle(),     // input to BFM
     .pipe_tx5_elec_idle(),     // input to BFM
     .pipe_tx6_elec_idle(),     // input to BFM
     .pipe_tx7_elec_idle(),     // input to BFM
     .pipe_tx0_start_block(),   // input to BFM
     .pipe_tx1_start_block(),   // input to BFM
     .pipe_tx2_start_block(),   // input to BFM
     .pipe_tx3_start_block(),   // input to BFM
     .pipe_tx4_start_block(),   // input to BFM
     .pipe_tx5_start_block(),   // input to BFM
     .pipe_tx6_start_block(),   // input to BFM
     .pipe_tx7_start_block(),   // input to BFM
     .pipe_tx0_syncheader(),    // input to BFM
     .pipe_tx1_syncheader(),    // input to BFM
     .pipe_tx2_syncheader(),    // input to BFM
     .pipe_tx3_syncheader(),    // input to BFM
     .pipe_tx4_syncheader(),    // input to BFM
     .pipe_tx5_syncheader(),    // input to BFM
     .pipe_tx6_syncheader(),    // input to BFM
     .pipe_tx7_syncheader(),    // input to BFM
     .pipe_tx0_data_valid(),    // input to BFM
     .pipe_tx1_data_valid(),    // input to BFM
     .pipe_tx2_data_valid(),    // input to BFM
     .pipe_tx3_data_valid(),    // input to BFM
     .pipe_tx4_data_valid(),    // input to BFM
     .pipe_tx5_data_valid(),    // input to BFM
     .pipe_tx6_data_valid(),    // input to BFM
     .pipe_tx7_data_valid(),    // input to BFM
     // Pipe RX Interface
     .pipe_rx0_data(),          // output of BFM
     .pipe_rx1_data(),          // output of BFM
     .pipe_rx2_data(),          // output of BFM
     .pipe_rx3_data(),          // output of BFM
     .pipe_rx4_data(),          // output of BFM
     .pipe_rx5_data(),          // output of BFM
     .pipe_rx6_data(),          // output of BFM
     .pipe_rx7_data(),          // output of BFM
     .pipe_rx0_char_is_k(),     // output of BFM
     .pipe_rx1_char_is_k(),     // output of BFM
     .pipe_rx2_char_is_k(),     // output of BFM
     .pipe_rx3_char_is_k(),     // output of BFM
     .pipe_rx4_char_is_k(),     // output of BFM
     .pipe_rx5_char_is_k(),     // output of BFM
     .pipe_rx6_char_is_k(),     // output of BFM
     .pipe_rx7_char_is_k(),     // output of BFM
     .pipe_rx0_elec_idle(),     // output of BFM
     .pipe_rx1_elec_idle(),     // output of BFM
     .pipe_rx2_elec_idle(),     // output of BFM
     .pipe_rx3_elec_idle(),     // output of BFM
     .pipe_rx4_elec_idle(),     // output of BFM
     .pipe_rx5_elec_idle(),     // output of BFM
     .pipe_rx6_elec_idle(),     // output of BFM
     .pipe_rx7_elec_idle(),     // output of BFM
     .pipe_rx0_start_block(),   // output of BFM
     .pipe_rx1_start_block(),   // output of BFM
     .pipe_rx2_start_block(),   // output of BFM
     .pipe_rx3_start_block(),   // output of BFM
     .pipe_rx4_start_block(),   // output of BFM
     .pipe_rx5_start_block(),   // output of BFM
     .pipe_rx6_start_block(),   // output of BFM
     .pipe_rx7_start_block(),   // output of BFM
     .pipe_rx0_syncheader(),    // output of BFM
     .pipe_rx1_syncheader(),    // output of BFM
     .pipe_rx2_syncheader(),    // output of BFM
     .pipe_rx3_syncheader(),    // output of BFM
     .pipe_rx4_syncheader(),    // output of BFM
     .pipe_rx5_syncheader(),    // output of BFM
     .pipe_rx6_syncheader(),    // output of BFM
     .pipe_rx7_syncheader(),    // output of BFM
     .pipe_rx0_data_valid(),    // output of BFM
     .pipe_rx1_data_valid(),    // output of BFM
     .pipe_rx2_data_valid(),    // output of BFM
     .pipe_rx3_data_valid(),    // output of BFM
     .pipe_rx4_data_valid(),    // output of BFM
     .pipe_rx5_data_valid(),    // output of BFM
     .pipe_rx6_data_valid(),    // output of BFM
     .pipe_rx7_data_valid()     // output of BFM
);

*/
 


endmodule // BOARD
