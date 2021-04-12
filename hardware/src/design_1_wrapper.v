//Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2020.1 (lin64) Build 2902540 Wed May 27 19:54:35 MDT 2020
//Date        : Mon Jul 27 14:42:24 2020
//Host        : xsjrdevl163 running 64-bit CentOS Linux release 7.4.1708 (Core)
//Command     : generate_target design_1_wrapper.bd
//Design      : design_1_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_1_wrapper
   (disable_hbm_cattrip,
    pci_express_x8_rxn,
    pci_express_x8_rxp,
    pci_express_x8_txn,
    pci_express_x8_txp,
    pcie_perstn,
    pcie_refclk_clk_n,
    pcie_refclk_clk_p,
    rs232_uart_rxd,
    rs232_uart_txd);
  output [0:0]disable_hbm_cattrip;
  input [7:0]pci_express_x8_rxn;
  input [7:0]pci_express_x8_rxp;
  output [7:0]pci_express_x8_txn;
  output [7:0]pci_express_x8_txp;
  input pcie_perstn;
  input pcie_refclk_clk_n;
  input pcie_refclk_clk_p;
  input rs232_uart_rxd;
  output rs232_uart_txd;

  wire [0:0]disable_hbm_cattrip;
  wire [7:0]pci_express_x8_rxn;
  wire [7:0]pci_express_x8_rxp;
  wire [7:0]pci_express_x8_txn;
  wire [7:0]pci_express_x8_txp;
  wire [25:0]pcie_ext_pipe_ep_usp_0_commands_in;
  wire [25:0]pcie_ext_pipe_ep_usp_0_commands_out;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_0;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_1;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_10;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_11;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_12;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_13;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_14;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_15;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_2;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_3;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_4;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_5;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_6;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_7;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_8;
  wire [83:0]pcie_ext_pipe_ep_usp_0_rx_9;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_0;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_1;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_10;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_11;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_12;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_13;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_14;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_15;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_2;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_3;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_4;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_5;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_6;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_7;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_8;
  wire [83:0]pcie_ext_pipe_ep_usp_0_tx_9;
  wire pcie_perstn;
  wire pcie_refclk_clk_n;
  wire pcie_refclk_clk_p;
  wire rs232_uart_rxd;
  wire rs232_uart_txd;
  
  assign pcie_ext_pipe_ep_usp_0_commands_out =26'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_0   = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_1   = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_10  = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_11  = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_12  = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_13  = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_14  = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_15  = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_2   = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_3   = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_4   = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_5   = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_6   = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_7   = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_8   = 84'b0;
  assign pcie_ext_pipe_ep_usp_0_tx_9   = 84'b0;    

  design_1 design_1_i
       (.disable_hbm_cattrip(disable_hbm_cattrip),
        .pci_express_x8_rxn(pci_express_x8_rxn),
        .pci_express_x8_rxp(pci_express_x8_rxp),
        .pci_express_x8_txn(pci_express_x8_txn),
        .pci_express_x8_txp(pci_express_x8_txp),
        .pcie_ext_pipe_ep_usp_0_commands_in(pcie_ext_pipe_ep_usp_0_commands_in),
        .pcie_ext_pipe_ep_usp_0_commands_out(pcie_ext_pipe_ep_usp_0_commands_out),
        .pcie_ext_pipe_ep_usp_0_rx_0(pcie_ext_pipe_ep_usp_0_rx_0),
        .pcie_ext_pipe_ep_usp_0_rx_1(pcie_ext_pipe_ep_usp_0_rx_1),
        .pcie_ext_pipe_ep_usp_0_rx_10(pcie_ext_pipe_ep_usp_0_rx_10),
        .pcie_ext_pipe_ep_usp_0_rx_11(pcie_ext_pipe_ep_usp_0_rx_11),
        .pcie_ext_pipe_ep_usp_0_rx_12(pcie_ext_pipe_ep_usp_0_rx_12),
        .pcie_ext_pipe_ep_usp_0_rx_13(pcie_ext_pipe_ep_usp_0_rx_13),
        .pcie_ext_pipe_ep_usp_0_rx_14(pcie_ext_pipe_ep_usp_0_rx_14),
        .pcie_ext_pipe_ep_usp_0_rx_15(pcie_ext_pipe_ep_usp_0_rx_15),
        .pcie_ext_pipe_ep_usp_0_rx_2(pcie_ext_pipe_ep_usp_0_rx_2),
        .pcie_ext_pipe_ep_usp_0_rx_3(pcie_ext_pipe_ep_usp_0_rx_3),
        .pcie_ext_pipe_ep_usp_0_rx_4(pcie_ext_pipe_ep_usp_0_rx_4),
        .pcie_ext_pipe_ep_usp_0_rx_5(pcie_ext_pipe_ep_usp_0_rx_5),
        .pcie_ext_pipe_ep_usp_0_rx_6(pcie_ext_pipe_ep_usp_0_rx_6),
        .pcie_ext_pipe_ep_usp_0_rx_7(pcie_ext_pipe_ep_usp_0_rx_7),
        .pcie_ext_pipe_ep_usp_0_rx_8(pcie_ext_pipe_ep_usp_0_rx_8),
        .pcie_ext_pipe_ep_usp_0_rx_9(pcie_ext_pipe_ep_usp_0_rx_9),
        .pcie_ext_pipe_ep_usp_0_tx_0(pcie_ext_pipe_ep_usp_0_tx_0),
        .pcie_ext_pipe_ep_usp_0_tx_1(pcie_ext_pipe_ep_usp_0_tx_1),
        .pcie_ext_pipe_ep_usp_0_tx_10(pcie_ext_pipe_ep_usp_0_tx_10),
        .pcie_ext_pipe_ep_usp_0_tx_11(pcie_ext_pipe_ep_usp_0_tx_11),
        .pcie_ext_pipe_ep_usp_0_tx_12(pcie_ext_pipe_ep_usp_0_tx_12),
        .pcie_ext_pipe_ep_usp_0_tx_13(pcie_ext_pipe_ep_usp_0_tx_13),
        .pcie_ext_pipe_ep_usp_0_tx_14(pcie_ext_pipe_ep_usp_0_tx_14),
        .pcie_ext_pipe_ep_usp_0_tx_15(pcie_ext_pipe_ep_usp_0_tx_15),
        .pcie_ext_pipe_ep_usp_0_tx_2(pcie_ext_pipe_ep_usp_0_tx_2),
        .pcie_ext_pipe_ep_usp_0_tx_3(pcie_ext_pipe_ep_usp_0_tx_3),
        .pcie_ext_pipe_ep_usp_0_tx_4(pcie_ext_pipe_ep_usp_0_tx_4),
        .pcie_ext_pipe_ep_usp_0_tx_5(pcie_ext_pipe_ep_usp_0_tx_5),
        .pcie_ext_pipe_ep_usp_0_tx_6(pcie_ext_pipe_ep_usp_0_tx_6),
        .pcie_ext_pipe_ep_usp_0_tx_7(pcie_ext_pipe_ep_usp_0_tx_7),
        .pcie_ext_pipe_ep_usp_0_tx_8(pcie_ext_pipe_ep_usp_0_tx_8),
        .pcie_ext_pipe_ep_usp_0_tx_9(pcie_ext_pipe_ep_usp_0_tx_9),
        .pcie_perstn(pcie_perstn),
        .pcie_refclk_clk_n(pcie_refclk_clk_n),
        .pcie_refclk_clk_p(pcie_refclk_clk_p),
        .rs232_uart_rxd(rs232_uart_rxd),
        .rs232_uart_txd(rs232_uart_txd));
endmodule
