/**
* Copyright (C) 2021 Xilinx, Inc
*
* Licensed under the Apache License, Version 2.0 (the "License"). You may
* not use this file except in compliance with the License. A copy of the
* License is located at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
* License for the specific language governing permissions and limitations
* under the License.
*/


`timescale 1 ns / 1 ps

module axil_addr_offset_v1_0 #
(


    // Parameters of Axi Slave Bus Interface S00_AXI
    parameter integer C_S00_AXI_DATA_WIDTH	= 32,
    parameter integer C_S00_AXI_ADDR_WIDTH	= 32,

    // Parameters of Axi Master Bus Interface M00_AXI
    parameter  C_M00_AXI_START_DATA_VALUE	= 32'hAA000000,
    parameter  C_M00_AXI_TARGET_SLAVE_BASE_ADDR	= 32'h40000000,
    parameter integer C_M00_AXI_ADDR_WIDTH	= 32,
    parameter integer C_M00_AXI_DATA_WIDTH	= 32,
    parameter integer C_M00_AXI_TRANSACTIONS_NUM	= 4
)
(
    // Non-AXI ports
    input wire aclk,
    input wire aresetn,

    // Ports of Axi Slave Bus Interface S00_AXI
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0]       s00_axi_awaddr,
    input wire [2 : 0]                            s00_axi_awprot,
    input wire                                    s00_axi_awvalid,
    output wire                                   s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0]       s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0]   s00_axi_wstrb,
    input wire                                    s00_axi_wvalid,
    output wire                                   s00_axi_wready,
    output wire [1 : 0]                           s00_axi_bresp,
    output wire                                   s00_axi_bvalid,
    input wire                                    s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0]       s00_axi_araddr,
    input wire [2 : 0]                            s00_axi_arprot,
    input wire                                    s00_axi_arvalid,
    output wire                                   s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0]      s00_axi_rdata,
    output wire [1 : 0]                           s00_axi_rresp,
    output wire                                   s00_axi_rvalid,
    input wire                                    s00_axi_rready,

    // Ports of Axi Master Bus Interface M00_AXI
    output wire [C_M00_AXI_ADDR_WIDTH-1 : 0]      m00_axi_awaddr,
    output wire [2 : 0]                           m00_axi_awprot,
    output wire                                   m00_axi_awvalid,
    input wire                                    m00_axi_awready,
    output wire [C_M00_AXI_DATA_WIDTH-1 : 0]      m00_axi_wdata,
    output wire [C_M00_AXI_DATA_WIDTH/8-1 : 0]    m00_axi_wstrb,
    output wire                                   m00_axi_wvalid,
    input wire                                    m00_axi_wready,
    input wire [1 : 0]                            m00_axi_bresp,
    input wire                                    m00_axi_bvalid,
    output wire                                   m00_axi_bready,
    output wire [C_M00_AXI_ADDR_WIDTH-1 : 0]      m00_axi_araddr,
    output wire [2 : 0]                           m00_axi_arprot,
    output wire                                   m00_axi_arvalid,
    input wire                                    m00_axi_arready,
    input wire [C_M00_AXI_DATA_WIDTH-1 : 0]       m00_axi_rdata,
    input wire [1 : 0]                            m00_axi_rresp,
    input wire                                    m00_axi_rvalid,
    output wire                                   m00_axi_rready
);

    // Adding offset to addresses
    assign m00_axi_araddr   = s00_axi_araddr | 32'hC0000000;
    assign m00_axi_awaddr   = s00_axi_awaddr | 32'hC0000000;


    // Hook up everything that is not addresses
    assign s00_axi_awready  = m00_axi_awready;
    assign s00_axi_wready   = m00_axi_wready;  
    assign s00_axi_bresp    = m00_axi_bresp;
    assign s00_axi_bvalid   = m00_axi_bvalid;
    assign s00_axi_arready  = m00_axi_arready;
    assign s00_axi_rdata    = m00_axi_rdata;
    assign s00_axi_rresp    = m00_axi_rresp;
    assign s00_axi_rvalid   = m00_axi_rvalid;
    
    
    
    assign m00_axi_awprot   = s00_axi_awprot;
    assign m00_axi_awvalid  = s00_axi_awvalid;
    assign m00_axi_wdata    = s00_axi_wdata;
    assign m00_axi_wstrb    = s00_axi_wstrb;
    assign m00_axi_wvalid   = s00_axi_wvalid;
    assign m00_axi_bready   = s00_axi_bready;
    
    assign m00_axi_arprot   = s00_axi_arprot;
    assign m00_axi_arvalid  = s00_axi_arvalid;
    assign m00_axi_rready   = s00_axi_rready;
    
    
    
    
endmodule
