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

module h2c_shim_layer_v1_0 #
(
    parameter integer C_S00_AXI_DATA_WIDTH	    = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH	    = 8,
    parameter integer S_AXIS_H2C_DATA_WIDTH     = 256,
    parameter integer IN_FIFO_DEPTH             = 256,
    parameter integer OUT_FIFO_DEPTH            = 256,
    parameter integer IN_FIFO_DATA_WIDTH        = S_AXIS_H2C_DATA_WIDTH + (S_AXIS_H2C_DATA_WIDTH/8) + 55,
    parameter integer OUT_FIFO_DATA_WIDTH       = 126 + 64 + 1,
    parameter integer IN_FIFO_DATA_COUNT_WIDTH  = $clog2(IN_FIFO_DATA_WIDTH),
    parameter integer OUT_FIFO_DATA_COUNT_WIDTH = $clog2(OUT_FIFO_DATA_WIDTH)
)
(

    // Non-AXI IO
    input  wire                                     clk,
    input  wire                                     aresetn,

    // S_AXI_LITE interface
    input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0]        s00_axi_awaddr,
    input  wire [2 : 0]                             s00_axi_awprot,
    input  wire                                     s00_axi_awvalid,
    output wire                                     s00_axi_awready,
    input  wire [C_S00_AXI_DATA_WIDTH-1 : 0]        s00_axi_wdata,
    input  wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0]    s00_axi_wstrb, // Currently not using strobe, might have to
    input  wire                                     s00_axi_wvalid,
    output wire                                     s00_axi_wready,
    output wire [1 : 0]                             s00_axi_bresp,
    output wire                                     s00_axi_bvalid,
    input  wire                                     s00_axi_bready,
    input  wire [C_S00_AXI_ADDR_WIDTH-1 : 0]        s00_axi_araddr,
    input  wire [2 : 0]                             s00_axi_arprot,
    input  wire                                     s00_axi_arvalid,
    output wire                                     s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0]        s00_axi_rdata,
    output wire [1 : 0]                             s00_axi_rresp,
    output wire                                     s00_axi_rvalid,
    input  wire                                     s00_axi_rready,
    
    
    // Input from m_axis_h2c 
    input  wire [S_AXIS_H2C_DATA_WIDTH-1 : 0]       s_axis_h2c_tdata,
    input  wire [(S_AXIS_H2C_DATA_WIDTH/8)-1:0]     s_axis_h2c_tuser_crc,
    input  wire [10:0]                              s_axis_h2c_tuser_qid,
    input  wire [2:0]                               s_axis_h2c_tuser_port_id,
    input  wire                                     s_axis_h2c_tuser_err,
    input  wire [31:0]                              s_axis_h2c_tuser_mdata,
    input  wire [5:0]                               s_axis_h2c_tuser_mty,
    input  wire                                     s_axis_h2c_tuser_zerobyte,
    input  wire                                     s_axis_h2c_tvalid,
    input  wire                                     s_axis_h2c_tlast,
    output wire                                     s_axis_h2c_tready,
    
    // h2c_byp_in_mm handshake and w address
    output wire                                     m_h2c_byp_in_mm_vld,
    input wire                                      m_h2c_byp_in_mm_rdy,
    output wire [63:0]                              m_h2c_byp_in_waddr,
                       
    // h2c_byp_in_st handshake
    output wire                                     m_h2c_byp_in_st_vld,
    input  wire                                     m_h2c_byp_in_st_rdy,                 
    
    // Output logic to h2c_byp_in_st and h2c_byp_in_mm
    output wire [63:0]                              m_h2c_byp_in_raddr,
    output wire [15:0]                              m_h2c_byp_in_cidx,
    output wire [1:0]                               m_h2c_byp_in_at,
    output wire                                     m_h2c_byp_in_eop,
    output wire                                     m_h2c_byp_in_error,
    output wire [7:0]                               m_h2c_byp_in_func,
    output wire [15:0]                              m_h2c_byp_in_len,
    output wire                                     m_h2c_byp_in_mrkr_req,
    output wire                                     m_h2c_byp_in_no_dma,
    output wire [2:0]                               m_h2c_byp_in_port_id,
    output wire [10:0]                              m_h2c_byp_in_qid,
    output wire                                     m_h2c_byp_in_sdi,
    output wire                                     m_h2c_byp_in_sop
);

    
    
    
    // Wires for the input FIFO
    wire [IN_FIFO_DATA_WIDTH-1:0]           in_fifo_dout;
    wire [IN_FIFO_DATA_WIDTH-1:0]           in_fifo_din;
    wire                                    in_fifo_empty;
    wire                                    in_fifo_full;
    wire                                    in_fifo_wr_en;
    wire                                    in_fifo_rd_en; 
    wire                                    in_fifo_rd_rst_busy; // TODO: integrate rst_busy signals into controller
    wire                                    in_fifo_wr_rst_busy;

    // Registered to read out of memory map
    reg                                     in_fifo_not_empty_reg;
    
    // Wires for the output FIFO
    wire [OUT_FIFO_DATA_WIDTH-1:0]          out_fifo_dout;
    wire [OUT_FIFO_DATA_WIDTH-1:0]          out_fifo_din;
    wire                                    out_fifo_empty;
    wire                                    out_fifo_full;
    wire                                    out_fifo_wr_en;
    wire                                    out_fifo_rd_en; 
    wire                                    out_fifo_rd_rst_busy; // TODO: integreate rst_busy signals into controller
    wire                                    out_fifo_wr_rst_busy;
    
    // Splitting up the fifo output data into different segments
    wire [S_AXIS_H2C_DATA_WIDTH-1:0]        in_fifo_dout_tdata;
    wire [(S_AXIS_H2C_DATA_WIDTH/8)-1:0]    in_fifo_dout_tuser_crc;
    wire [10:0]                             in_fifo_dout_qid;
    wire [2:0]                              in_fifo_dout_tuser_port_id; 
    wire                                    in_fifo_dout_tuser_err;
    wire [31:0]                             in_fifo_dout_tuser_mdata;
    wire [5:0]                              in_fifo_dout_tuser_mty;
    wire                                    in_fifo_dout_tuser_zerobyte;
    wire                                    in_fifo_dout_tlast;
    
    // Register for s00_axi_rdata
    reg [C_S00_AXI_DATA_WIDTH-1:0]          s00_axi_rdata_reg;
    reg [C_S00_AXI_ADDR_WIDTH-1:0]          s00_axi_araddr_reg;
    
    // Tying valid-ready handshake to FIFO full/empty signals
    assign in_fifo_wr_en        = s_axis_h2c_tvalid;
    assign s_axis_h2c_tready    = ~in_fifo_full;
    
    // Connecting rdata to its corresponding register
    assign s00_axi_rdata = s00_axi_rdata_reg;
    
    // TODO: Integrate this into controller to handle errors
    assign s00_axi_rresp = 2'b00;
    assign s00_axi_bresp = 2'b00;
    
    assign {in_fifo_dout_tdata, 
            in_fifo_dout_tuser_crc, 
            in_fifo_dout_qid,
            in_fifo_dout_tuser_port_id,
            in_fifo_dout_tuser_err,
            in_fifo_dout_tuser_mdata,
            in_fifo_dout_tuser_mty,
            in_fifo_dout_tuser_zerobyte,
            in_fifo_dout_tlast} = in_fifo_dout;
            
    // Putting all data in input fifo din
    assign in_fifo_din = {  s_axis_h2c_tdata, 
                            s_axis_h2c_tuser_crc, 
                            s_axis_h2c_tuser_qid, 
                            s_axis_h2c_tuser_port_id, 
                            s_axis_h2c_tuser_err,
                            s_axis_h2c_tuser_mdata,
                            s_axis_h2c_tuser_mty,
                            s_axis_h2c_tuser_zerobyte,
                            s_axis_h2c_tlast};
                           
    // Registering the empty signal
    always@(posedge clk) begin
        if(~aresetn) begin
            in_fifo_not_empty_reg <= 1'b0;
        end
        else begin
            in_fifo_not_empty_reg <= ~in_fifo_empty;
        end
    end 
                            
                            
    xpm_fifo_sync #(
        .DOUT_RESET_VALUE("0"),
        .ECC_MODE("no_ecc"),
        .FIFO_MEMORY_TYPE("auto"),
        .FIFO_READ_LATENCY(1),
        .FIFO_WRITE_DEPTH(IN_FIFO_DEPTH),
        .FULL_RESET_VALUE(0),
        .PROG_EMPTY_THRESH(10),
        .PROG_FULL_THRESH(10),
        .RD_DATA_COUNT_WIDTH(IN_FIFO_DATA_COUNT_WIDTH),
        .READ_DATA_WIDTH(IN_FIFO_DATA_WIDTH),
        .READ_MODE("fwft"),
        .SIM_ASSERT_CHK(0),
        .USE_ADV_FEATURES("0000"),
        .WAKEUP_TIME(0),
        .WRITE_DATA_WIDTH(IN_FIFO_DATA_WIDTH),
        .WR_DATA_COUNT_WIDTH(IN_FIFO_DATA_COUNT_WIDTH)
    )
    in_fifo (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(in_fifo_dout),
      .empty(in_fifo_empty),
      .full(in_fifo_full),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(),
      .rd_rst_busy(in_fifo_rd_rst_busy),
      .sbiterr(),
      .underflow(),
      .wr_ack(),        
      .wr_data_count(),
      .wr_rst_busy(in_fifo_wr_rst_busy),
      .din(in_fifo_din),
      .injectdbiterr(), 
      .injectsbiterr(), 
      .rd_en(in_fifo_rd_en),
      .rst(~aresetn), // turning into active low                
      .sleep(1'b0),
      .wr_clk(clk),
      .wr_en(in_fifo_wr_en)
    );
                            
    // Reg to store last valid address to address mux
    always@(posedge clk) begin
        if(~aresetn) begin
            s00_axi_araddr_reg <= 0;
        end
        else if(s00_axi_arvalid) begin
            s00_axi_araddr_reg <= s00_axi_araddr;
        end
        else begin
            s00_axi_araddr_reg <= s00_axi_araddr_reg;
        end
    end
    
    // MUX to choose which 32-bit portion is to be read
    always @ (*) begin
        case(s00_axi_araddr_reg) 
           8'h00:      s00_axi_rdata_reg <= in_fifo_dout_tdata[255:224];
           8'h04:      s00_axi_rdata_reg <= in_fifo_dout_tdata[223:192];
           8'h08:      s00_axi_rdata_reg <= in_fifo_dout_tdata[191:160];
           8'h0C:      s00_axi_rdata_reg <= in_fifo_dout_tdata[159:128];
           8'h10:      s00_axi_rdata_reg <= in_fifo_dout_tdata[127:96];
           8'h14:      s00_axi_rdata_reg <= in_fifo_dout_tdata[95:64];
           8'h18:      s00_axi_rdata_reg <= in_fifo_dout_tdata[63:32];
           8'h1C:      s00_axi_rdata_reg <= in_fifo_dout_tdata[31:0];
           8'h20:      s00_axi_rdata_reg <= in_fifo_dout_tuser_crc;
           8'h24:      s00_axi_rdata_reg <= {8'd0,                          // [31:24]
                                            in_fifo_not_empty_reg,         // [23]
                                            in_fifo_dout_qid,              // [22:12]
                                            in_fifo_dout_tuser_port_id,    // [11:9]
                                            in_fifo_dout_tuser_err,        // [8]
                                            in_fifo_dout_tuser_mty,        // [7:5]
                                            in_fifo_dout_tuser_zerobyte,   // [1]
                                            in_fifo_dout_tlast};           // [0]
           8'h28:      s00_axi_rdata_reg <= in_fifo_dout_tuser_mdata;
           // Address 0x2c = un-swizzled low order 32 bits of a translated address 
           8'h2c:      s00_axi_rdata_reg <= {in_fifo_dout_tdata[39:32],in_fifo_dout_tdata[47:40],in_fifo_dout_tdata[55:52],12'h000};
           // Address 0x30 = un-swizzled  high order 32 bits of a translated address 
           8'h30:      s00_axi_rdata_reg <= {in_fifo_dout_tdata[7:0],in_fifo_dout_tdata[15:8],in_fifo_dout_tdata[23:16],in_fifo_dout_tdata[31:24]};
           //  un-swizzled and packed 5 bits  of a translated address data field  bits 4:0 = S, N, U, W, R
           8'h34:      s00_axi_rdata_reg <= {27'b000000000000000000000000000,in_fifo_dout_tdata[51:50],in_fifo_dout_tdata[58:56]};
        endcase
    end
    
    receive_controller receive_controller(
        .clk(clk),
        .aresetn(aresetn),
        .arvalid(s00_axi_arvalid),
        .rready(s00_axi_rready),
        .arready(s00_axi_arready),
        .rvalid(s00_axi_rvalid)
    );
    
    // Signals for the send path
    reg [C_S00_AXI_ADDR_WIDTH-1:0]  s00_axi_awaddr_reg;
    reg [C_S00_AXI_DATA_WIDTH-1:0]  s00_axi_wdata_reg;
    wire                            reg_file_wr_en;
    reg [63:0]                      m_h2c_byp_in_raddr_reg;
    reg [63:0]                      m_h2c_byp_in_waddr_reg;
    reg [15:0]                      m_h2c_byp_in_cidx_reg;
    reg [1:0]                       m_h2c_byp_in_at_reg;
    reg                             m_h2c_byp_in_eop_reg;
    reg                             m_h2c_byp_in_error_reg;
    reg [7:0]                       m_h2c_byp_in_func_reg;
    reg [15:0]                      m_h2c_byp_in_len_reg;
    reg                             m_h2c_byp_in_mrkr_req_reg;
    reg                             m_h2c_byp_in_no_dma_reg;
    reg [2:0]                       m_h2c_byp_in_port_id_reg;
    reg [10:0]                      m_h2c_byp_in_qid_reg;
    reg                             m_h2c_byp_in_sdi_reg;
    reg                             m_h2c_byp_in_sop_reg;
    reg                             pop_in_fifo_reg;
    reg                             push_out_fifo_reg;
    reg                             m_h2c_byp_in_mm_or_st_in_reg;
    wire                            m_h2c_byp_in_mm_or_st_out;
 
 
    send_controller send_controller(
        .clk(clk),
        .aresetn(aresetn),
        .awvalid(s00_axi_awvalid),
        .wvalid(s00_axi_wvalid),
        .bready(s00_axi_bready),
        .awready(s00_axi_awready),
        .wready(s00_axi_wready),
        .bvalid(s00_axi_bvalid),
        .reg_file_wr_en(reg_file_wr_en)
    );
    
    // waddr register
    always@(posedge clk) begin
        if(~aresetn) begin
            s00_axi_awaddr_reg <= 0;
        end
        else if(s00_axi_awvalid) begin
            s00_axi_awaddr_reg <= s00_axi_awaddr;
        end
        else begin
            s00_axi_awaddr_reg <= s00_axi_awaddr_reg;
        end
    end
    
    // wdata register
    always@(posedge clk) begin
        if(~aresetn) begin
            s00_axi_wdata_reg <= 0;
        end
        else if(s00_axi_wvalid) begin
            s00_axi_wdata_reg <= s00_axi_wdata;
        end
        else begin
            s00_axi_wdata_reg <= s00_axi_wdata_reg;
        end
    end
    
    // Register file which will be concatenated to output FIFO
    always@(posedge clk) begin
        if(~aresetn) begin
            m_h2c_byp_in_raddr_reg          <= 0;
            m_h2c_byp_in_waddr_reg          <= 0;
            m_h2c_byp_in_cidx_reg           <= 0;
            m_h2c_byp_in_eop_reg            <= 0;
            m_h2c_byp_in_error_reg          <= 0;
            m_h2c_byp_in_func_reg           <= 0;
            m_h2c_byp_in_len_reg            <= 0;
            m_h2c_byp_in_at_reg             <= 0;
            m_h2c_byp_in_mrkr_req_reg       <= 0;
            m_h2c_byp_in_no_dma_reg         <= 0;
            m_h2c_byp_in_port_id_reg        <= 0;
            m_h2c_byp_in_qid_reg            <= 0;
            m_h2c_byp_in_sdi_reg            <= 0;
            m_h2c_byp_in_sop_reg            <= 0;
            pop_in_fifo_reg                 <= 0;
            push_out_fifo_reg               <= 0;
            m_h2c_byp_in_mm_or_st_in_reg    <= 0;
        end
        else if(reg_file_wr_en) begin
            case(s00_axi_awaddr_reg)
                8'h00: m_h2c_byp_in_raddr_reg[63:32]    <= s00_axi_wdata_reg;
                8'h04: m_h2c_byp_in_raddr_reg[31:0]     <= s00_axi_wdata_reg;
                8'h08: m_h2c_byp_in_waddr_reg[63:32]    <= s00_axi_wdata_reg;
                8'h0C: m_h2c_byp_in_waddr_reg[31:0]     <= s00_axi_wdata_reg;
                8'h10: begin
                    m_h2c_byp_in_len_reg                <= s00_axi_wdata_reg[15:0];
                    m_h2c_byp_in_at_reg                 <= s00_axi_wdata_reg[17:16];
                    m_h2c_byp_in_sop_reg                <= s00_axi_wdata_reg[18];
                    m_h2c_byp_in_eop_reg                <= s00_axi_wdata_reg[19];
                    m_h2c_byp_in_sdi_reg                <= s00_axi_wdata_reg[20];
                    m_h2c_byp_in_mrkr_req_reg           <= s00_axi_wdata_reg[21];
                    m_h2c_byp_in_no_dma_reg             <= s00_axi_wdata_reg[22];
                    m_h2c_byp_in_error_reg              <= s00_axi_wdata_reg[23];
                    m_h2c_byp_in_func_reg               <= s00_axi_wdata_reg[31:24];
                end
                8'h14: begin
                    m_h2c_byp_in_qid_reg                <= s00_axi_wdata_reg[10:0];
                    m_h2c_byp_in_port_id_reg            <= s00_axi_wdata_reg[13:11];
                    m_h2c_byp_in_cidx_reg               <= s00_axi_wdata_reg[29:14];
                    m_h2c_byp_in_mm_or_st_in_reg        <= s00_axi_wdata_reg[30];
                end
                8'h18: begin
                    pop_in_fifo_reg                     <= s00_axi_wdata_reg[0];
                    push_out_fifo_reg                   <= s00_axi_wdata_reg[1];
                end
            endcase
        end
        else begin
            m_h2c_byp_in_raddr_reg          <= m_h2c_byp_in_raddr_reg;
            m_h2c_byp_in_waddr_reg          <= m_h2c_byp_in_waddr_reg;
            m_h2c_byp_in_cidx_reg           <= m_h2c_byp_in_cidx_reg;
            m_h2c_byp_in_eop_reg            <= m_h2c_byp_in_eop_reg;
            m_h2c_byp_in_error_reg          <= m_h2c_byp_in_error_reg;
            m_h2c_byp_in_func_reg           <= m_h2c_byp_in_func_reg;
            m_h2c_byp_in_len_reg            <= m_h2c_byp_in_len_reg;
            m_h2c_byp_in_mrkr_req_reg       <= m_h2c_byp_in_mrkr_req_reg;
            m_h2c_byp_in_no_dma_reg         <= m_h2c_byp_in_no_dma_reg;
            m_h2c_byp_in_port_id_reg        <= m_h2c_byp_in_port_id_reg;
            m_h2c_byp_in_qid_reg            <= m_h2c_byp_in_qid_reg;
            m_h2c_byp_in_sdi_reg            <= m_h2c_byp_in_sdi_reg;
            m_h2c_byp_in_sop_reg            <= m_h2c_byp_in_sop_reg;
            pop_in_fifo_reg                 <= pop_in_fifo_reg;
            push_out_fifo_reg               <= push_out_fifo_reg;
            m_h2c_byp_in_mm_or_st_in_reg    <= m_h2c_byp_in_mm_or_st_in_reg;
        end
    end
    
    reg push_out_fifo_reg_d1;
    reg push_out_fifo_reg_d2;
    
    // Genereate pop to in fifo for one cycle
    always @ (posedge clk) begin
        if (!aresetn) begin
            push_out_fifo_reg_d1 <= 1'b0;
            push_out_fifo_reg_d2 <= 1'b0;
        end else if ((push_out_fifo_reg == 1'b1) && (push_out_fifo_reg_d1 == 1'b0 && push_out_fifo_reg_d2 == 1'b0 )) begin
            push_out_fifo_reg_d1 <= 1'b1;
            push_out_fifo_reg_d2 <= 1'b1;
        end else if ((push_out_fifo_reg == 1'b1) && (push_out_fifo_reg_d1 == 1'b1 && push_out_fifo_reg_d2 == 1'b1 ))  begin
            push_out_fifo_reg_d2 <= 1'b0;
        end else if (push_out_fifo_reg == 1'b0)  begin
            push_out_fifo_reg_d1 <= 1'b0;
            push_out_fifo_reg_d2 <= 1'b0;
        end else begin
            push_out_fifo_reg_d1 <= push_out_fifo_reg_d1;
            push_out_fifo_reg_d2 <= push_out_fifo_reg_d2;
        end
    end


    reg pop_in_fifo_reg_d1;
    reg pop_in_fifo_reg_d2;
    assign in_fifo_rd_en = pop_in_fifo_reg_d2;
    
    // Genereate push to out fifo for one cycle
    always @ (posedge clk) begin
        if (!aresetn) begin
            pop_in_fifo_reg_d1 <= 1'b0;
            pop_in_fifo_reg_d2 <= 1'b0;
        end else if ((pop_in_fifo_reg == 1'b1) && (pop_in_fifo_reg_d1 == 1'b0 && pop_in_fifo_reg_d2 == 1'b0 )) begin
            pop_in_fifo_reg_d1 <= 1'b1;
            pop_in_fifo_reg_d2 <= 1'b1;
        end else if ((pop_in_fifo_reg  == 1'b1) && (pop_in_fifo_reg_d1 == 1'b1 && pop_in_fifo_reg_d2 == 1'b1 ))  begin
            pop_in_fifo_reg_d2 <= 1'b0;
        end else if (pop_in_fifo_reg  == 1'b0)  begin
            pop_in_fifo_reg_d1 <= 1'b0;
            pop_in_fifo_reg_d2 <= 1'b0;
        end else begin
            pop_in_fifo_reg_d1 <= pop_in_fifo_reg_d1;
            pop_in_fifo_reg_d2 <= pop_in_fifo_reg_d2;
        end
    end
    
    // Concatenating register file data to input of FIFO
    assign out_fifo_din = { m_h2c_byp_in_raddr_reg,
                            m_h2c_byp_in_waddr_reg,
                            m_h2c_byp_in_cidx_reg,
                            m_h2c_byp_in_at_reg,
                            m_h2c_byp_in_eop_reg,
                            m_h2c_byp_in_error_reg,
                            m_h2c_byp_in_func_reg,
                            m_h2c_byp_in_len_reg,
                            m_h2c_byp_in_mrkr_req_reg,
                            m_h2c_byp_in_no_dma_reg,
                            m_h2c_byp_in_port_id_reg,
                            m_h2c_byp_in_qid_reg,
                            m_h2c_byp_in_sdi_reg,
                            m_h2c_byp_in_sop_reg,
                            m_h2c_byp_in_mm_or_st_in_reg};
                            
     // Outputting data from the FIFO to QDMA
    assign {m_h2c_byp_in_raddr,
            m_h2c_byp_in_waddr,
            m_h2c_byp_in_cidx,
            m_h2c_byp_in_at,
            m_h2c_byp_in_eop,
            m_h2c_byp_in_error,
            m_h2c_byp_in_func,
            m_h2c_byp_in_len,
            m_h2c_byp_in_mrkr_req,
            m_h2c_byp_in_no_dma,
            m_h2c_byp_in_port_id,
            m_h2c_byp_in_qid,
            m_h2c_byp_in_sdi,
            m_h2c_byp_in_sop,
            m_h2c_byp_in_mm_or_st_out}      = out_fifo_dout;
    
    // 2-to-1 demux
    assign m_h2c_byp_in_mm_vld              =  ~out_fifo_empty & m_h2c_byp_in_mm_or_st_out; 
    assign m_h2c_byp_in_st_vld              =  ~out_fifo_empty & ~m_h2c_byp_in_mm_or_st_out;
    
    
    assign out_fifo_wr_en                   = push_out_fifo_reg_d2;
    
    xpm_fifo_sync #(
        .DOUT_RESET_VALUE("0"),
        .ECC_MODE("no_ecc"),
        .FIFO_MEMORY_TYPE("auto"),
        .FIFO_READ_LATENCY(1),
        .FIFO_WRITE_DEPTH(OUT_FIFO_DEPTH),
        .FULL_RESET_VALUE(0),
        .PROG_EMPTY_THRESH(10),
        .PROG_FULL_THRESH(10),
        .RD_DATA_COUNT_WIDTH(OUT_FIFO_DATA_COUNT_WIDTH),
        .READ_DATA_WIDTH(OUT_FIFO_DATA_WIDTH),
        .READ_MODE("fwft"),
        .SIM_ASSERT_CHK(0),
        .USE_ADV_FEATURES("0000"),
        .WAKEUP_TIME(0),
        .WRITE_DATA_WIDTH(OUT_FIFO_DATA_WIDTH),
        .WR_DATA_COUNT_WIDTH(OUT_FIFO_DATA_COUNT_WIDTH)
    )
    out_fifo (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),             
      .dout(out_fifo_dout),
      .empty(out_fifo_empty),
      .full(out_fifo_full),
      .overflow(),
      .prog_empty(),       
      .prog_full(),         
      .rd_data_count(), 
      .rd_rst_busy(out_fifo_rd_rst_busy),    
      .sbiterr(),            
      .underflow(),        
      .wr_ack(),               
      .wr_data_count(), 
      .wr_rst_busy(out_fifo_wr_rst_busy),     
      .din(out_fifo_din),                     
      .injectdbiterr(), 
      .injectsbiterr(), 
      .rd_en(m_h2c_byp_in_mm_or_st_out ? m_h2c_byp_in_mm_rdy : m_h2c_byp_in_st_rdy),
      .rst(~aresetn), // turning into active low                
      .sleep(1'b0),                 
      .wr_clk(clk),
      .wr_en(out_fifo_wr_en)
    );



endmodule
