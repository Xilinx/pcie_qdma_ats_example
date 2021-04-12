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

module c2h_shim_layer_v1_0 #
(
    parameter integer C_S00_AXI_DATA_WIDTH	        = 32,
    parameter integer C_S00_AXI_ADDR_WIDTH	        = 8,
    parameter integer S_AXIS_C2H_DATA_WIDTH         = 256,
    parameter integer S_AXIS_C2H_CMPT_DATA_WIDTH    = 512,
    parameter integer FIFO_DEPTH                    = 256,
    parameter integer FIFO_DATA_COUNT_WIDTH         = $clog2(FIFO_DEPTH),
    parameter integer DSC_FIFO_DATA_WIDTH           = 96 + 64 + 1 + 35,
    parameter integer DATA_FIFO_DATA_WIDTH          = S_AXIS_C2H_DATA_WIDTH + 78,
    parameter integer CMPT_FIFO_DATA_WIDTH          = S_AXIS_C2H_CMPT_DATA_WIDTH + 58
)
(

    // Non-AXI ports
    input wire aclk,
    input wire aresetn,

    // Ports of Axi Slave Bus Interface S00_AXI
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0]         s00_axi_awaddr,
    input wire [2 : 0]                              s00_axi_awprot,
    input wire                                      s00_axi_awvalid,
    output wire                                     s00_axi_awready,
    input wire [C_S00_AXI_DATA_WIDTH-1 : 0]         s00_axi_wdata,
    input wire [(C_S00_AXI_DATA_WIDTH/8)-1 : 0]     s00_axi_wstrb,
    input wire                                      s00_axi_wvalid,
    output wire                                     s00_axi_wready,
    output wire [1 : 0]                             s00_axi_bresp,
    output wire                                     s00_axi_bvalid,
    input wire                                      s00_axi_bready,
    input wire [C_S00_AXI_ADDR_WIDTH-1 : 0]         s00_axi_araddr,
    input wire [2 : 0]                              s00_axi_arprot,
    input wire                                      s00_axi_arvalid,
    output wire                                     s00_axi_arready,
    output wire [C_S00_AXI_DATA_WIDTH-1 : 0]        s00_axi_rdata,
    output wire [1 : 0]                             s00_axi_rresp,
    output wire                                     s00_axi_rvalid,
    input wire                                      s00_axi_rready,
    
    // c2h_byp_in_mm handshake and other signals uniqueue to mm interface
    output wire [63:0]                              c2h_byp_in_waddr,
    output wire                                     c2h_byp_in_mm_vld,
    input wire                                      c2h_byp_in_mm_rdy,
    output wire [15:0]                              c2h_byp_in_mm_cidx,
    output wire [15:0]                              c2h_byp_in_mm_len,
    output wire                                     c2h_byp_in_mm_mrkr_req,
    output wire                                     c2h_byp_in_mm_no_dma,
    output wire                                     c2h_byp_in_mm_sdi,
    
    // c2h_byp_in_st handhake and other signals unique to st interface
    output wire                                     c2h_byp_in_st_vld,
    input wire                                      c2h_byp_in_st_rdy,
    output wire [6:0]                               c2h_byp_in_st_pfch_tag,
    
    // Output to both c2h_byp_in_st and c2h_byp_in_mm
    output wire [63:0]                              c2h_byp_in_raddr,
    output wire [1:0]                               c2h_byp_in_at,
    output wire                                     c2h_byp_in_error,
    output wire [7:0]                               c2h_byp_in_func,
    output wire [2:0]                               c2h_byp_in_port_id,
    output wire [10:0]                              c2h_byp_in_qid,
    
    // Output to s_axis_c2h
    output wire                                     m_axis_c2h_has_cmpt,
    output wire [15:0]                              m_axis_c2h_len,
    output wire                                     m_axis_c2h_marker,
    output wire [2:0]                               m_axis_c2h_port_id,
    output wire [10:0]                              m_axis_c2h_qid,
    output wire [6:0]                               m_axis_c2h_ecc,
    output wire [5:0]                               m_axis_c2h_mty,
    output wire [31:0]                              m_axis_c2h_tcrc,
    output wire [S_AXIS_C2H_DATA_WIDTH-1:0]         m_axis_c2h_tdata,
    output wire                                     m_axis_c2h_tlast,
    input wire                                      m_axis_c2h_tready,
    output wire                                     m_axis_c2h_tvalid,
    
    // Output to s_axis_c2h_cmpt
    output wire [1:0]                               m_axis_c2h_cmpt_ctrl_cmpty_type,
    output wire [2:0]                               m_axis_c2h_cmpt_ctrl_col_idx,
    output wire [S_AXIS_C2H_CMPT_DATA_WIDTH-1:0]    m_axis_c2h_cmpt_tdata,
    output wire [15:0]                              m_axis_c2h_cmpt_dpar,
    output wire [2:0]                               m_axis_c2h_cmpt_ctrl_err_idx,
    output wire                                     m_axis_c2h_cmpt_ctrl_marker,
    output wire [2:0]                               m_axis_c2h_cmpt_ctrl_port_id,
    output wire [10:0]                              m_axis_c2h_cmpt_ctrl_qid,
    output wire [1:0]                               m_axis_c2h_cmpt_size,
    input wire                                      m_axis_c2h_cmpt_tready,
    output wire                                     m_axis_c2h_cmpt_tvalid,
    output wire                                     m_axis_c2h_cmpt_ctrl_user_trig,
    output wire [15:0]                              m_axis_c2h_cmpt_wait_pld_pkt_id
    
);



    // Registers used to write into register file
    reg [C_S00_AXI_ADDR_WIDTH-1:0]  s00_axi_awaddr_reg;
    reg [C_S00_AXI_DATA_WIDTH-1:0]  s00_axi_wdata_reg;
    wire                            reg_file_wr_en;
    
    // waddr register
    always@(posedge aclk) begin
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
    always@(posedge aclk) begin
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
    
    // Registers for the descriptor
    reg [63:0]                              c2h_byp_in_raddr_reg;
    reg [63:0]                              c2h_byp_in_waddr_reg;
    reg [1:0]                               c2h_byp_in_at_reg;
    reg                                     c2h_byp_in_error_reg;
    reg [7:0]                               c2h_byp_in_func_reg;
    reg [6:0]                               c2h_byp_in_st_pfch_tag_reg;
    reg [2:0]                               c2h_byp_in_port_id_reg;
    reg [10:0]                              c2h_byp_in_qid_reg;
    reg                                     push_desc_fifo_reg;
    reg                                     c2h_byp_in_mm_or_st_in_reg;
    wire                                    c2h_byp_in_mm_or_st_out;
    reg [15:0]                              c2h_byp_in_mm_cidx_reg;
    reg [15:0]                              c2h_byp_in_mm_len_reg;
    reg                                     c2h_byp_in_mm_mrkr_req_reg;
    reg                                     c2h_byp_in_mm_no_dma_reg;
    reg                                     c2h_byp_in_mm_sdi_reg;
    
    // Registers for the data
    reg                                     m_axis_c2h_has_cmpt_reg;
    reg [15:0]                              m_axis_c2h_len_reg;
    reg                                     m_axis_c2h_marker_reg;
    reg [2:0]                               m_axis_c2h_port_id_reg;
    reg [10:0]                              m_axis_c2h_qid_reg;
    reg [6:0]                               m_axis_c2h_ecc_reg;
    reg [5:0]                               m_axis_c2h_mty_reg;
    reg [31:0]                              m_axis_c2h_tcrc_reg;
    reg [S_AXIS_C2H_DATA_WIDTH-1:0]         m_axis_c2h_tdata_reg;
    reg                                     m_axis_c2h_tlast_reg;
    reg                                     push_cmpt_fifo_reg;
    
    // Registers for the cmpt
    reg [1:0]                               m_axis_c2h_cmpt_ctrl_cmpty_type_reg;
    reg [2:0]                               m_axis_c2h_cmpt_ctrl_col_idx_reg;
    reg [S_AXIS_C2H_CMPT_DATA_WIDTH-1:0]    m_axis_c2h_cmpt_tdata_reg;
    reg [15:0]                              m_axis_c2h_cmpt_dpar_reg;
    reg [2:0]                               m_axis_c2h_cmpt_ctrl_err_idx_reg;
    reg                                     m_axis_c2h_cmpt_ctrl_marker_reg;
    reg [2:0]                               m_axis_c2h_cmpt_ctrl_port_id_reg;
    reg [10:0]                              m_axis_c2h_cmpt_ctrl_qid_reg;
    reg [1:0]                               m_axis_c2h_cmpt_size_reg;
    reg                                     m_axis_c2h_cmpt_ctrl_user_trig_reg;
    reg [15:0]                              m_axis_c2h_cmpt_wait_pld_pkt_id_reg;
    reg                                     push_data_fifo_reg;


    send_controller send_controller(
        .clk(aclk),
        .aresetn(aresetn),
        .awvalid(s00_axi_awvalid),
        .wvalid(s00_axi_wvalid),
        .bready(s00_axi_bready),
        .awready(s00_axi_awready),
        .wready(s00_axi_wready),
        .bvalid(s00_axi_bvalid),
        .reg_file_wr_en(reg_file_wr_en)
    );

    

    // Register file which will be concatenated to output FIFO
    always@(posedge aclk) begin
        if(~aresetn) begin
            c2h_byp_in_raddr_reg                    <= 0;
            c2h_byp_in_waddr_reg                    <= 0;
            c2h_byp_in_at_reg                       <= 0;
            c2h_byp_in_error_reg                    <= 0;
            c2h_byp_in_func_reg                     <= 0;
            c2h_byp_in_st_pfch_tag_reg              <= 0;
            c2h_byp_in_port_id_reg                  <= 0;
            c2h_byp_in_qid_reg                      <= 0;
            c2h_byp_in_mm_or_st_in_reg              <= 0;
            push_desc_fifo_reg                      <= 0;
            m_axis_c2h_has_cmpt_reg                 <= 0;
            m_axis_c2h_len_reg                      <= 0;
            m_axis_c2h_marker_reg                   <= 0;
            m_axis_c2h_port_id_reg                  <= 0;
            m_axis_c2h_qid_reg                      <= 0;
            m_axis_c2h_ecc_reg                      <= 0;
            m_axis_c2h_mty_reg                      <= 0;
            m_axis_c2h_tcrc_reg                     <= 0;
            m_axis_c2h_tdata_reg                    <= 0;
            m_axis_c2h_tlast_reg                    <= 0;
            push_cmpt_fifo_reg                      <= 0;
            m_axis_c2h_cmpt_ctrl_cmpty_type_reg     <= 0;
            m_axis_c2h_cmpt_ctrl_col_idx_reg        <= 0;
            m_axis_c2h_cmpt_tdata_reg               <= 0;
            m_axis_c2h_cmpt_dpar_reg                <= 0;
            m_axis_c2h_cmpt_ctrl_err_idx_reg        <= 0;
            m_axis_c2h_cmpt_ctrl_marker_reg         <= 0;
            m_axis_c2h_cmpt_ctrl_port_id_reg        <= 0;
            m_axis_c2h_cmpt_ctrl_qid_reg            <= 0;
            m_axis_c2h_cmpt_size_reg                <= 0;
            m_axis_c2h_cmpt_ctrl_user_trig_reg      <= 0;
            m_axis_c2h_cmpt_wait_pld_pkt_id_reg     <= 0;
            push_data_fifo_reg                      <= 0;
            c2h_byp_in_mm_cidx_reg                  <= 0;
            c2h_byp_in_mm_len_reg                   <= 0;
            c2h_byp_in_mm_mrkr_req_reg              <= 0;
            c2h_byp_in_mm_no_dma_reg                <= 0;
            c2h_byp_in_mm_sdi_reg                   <= 0;
        end
        else if(reg_file_wr_en) begin
            case(s00_axi_awaddr_reg)
                8'h00: c2h_byp_in_raddr_reg[63:32]      <= s00_axi_wdata_reg;
                8'h04: c2h_byp_in_raddr_reg[31:0]       <= s00_axi_wdata_reg;
                8'h08: c2h_byp_in_waddr_reg[63:32]      <= s00_axi_wdata_reg;
                8'h0C: c2h_byp_in_waddr_reg[31:0]       <= s00_axi_wdata_reg;
                8'h10: begin
                    c2h_byp_in_at_reg                   <= s00_axi_wdata_reg[1:0];
                    c2h_byp_in_error_reg                <= s00_axi_wdata_reg[2];
                    c2h_byp_in_func_reg                 <= s00_axi_wdata_reg[10:3];
                    c2h_byp_in_st_pfch_tag_reg          <= s00_axi_wdata_reg[17:11];
                    c2h_byp_in_port_id_reg              <= s00_axi_wdata_reg[20:18];
                    c2h_byp_in_qid_reg                  <= s00_axi_wdata_reg[31:21];
                end
                8'h14: begin
                    c2h_byp_in_mm_cidx_reg              <= s00_axi_wdata_reg[15:0];
                    c2h_byp_in_mm_len_reg               <= s00_axi_wdata_reg[31:16];
                end
                8'h18: begin
                    m_axis_c2h_has_cmpt_reg             <= s00_axi_wdata_reg[0];
                    m_axis_c2h_len_reg                  <= s00_axi_wdata_reg[16:1];
                    m_axis_c2h_marker_reg               <= s00_axi_wdata_reg[17];
                    m_axis_c2h_port_id_reg              <= s00_axi_wdata_reg[20:18];
                    m_axis_c2h_qid_reg                  <= s00_axi_wdata_reg[31:21];
                end
                8'h1C: begin
                    m_axis_c2h_ecc_reg                  <= s00_axi_wdata_reg[6:0];
                    m_axis_c2h_mty_reg                  <= s00_axi_wdata_reg[12:7];
                    m_axis_c2h_tlast_reg                <= s00_axi_wdata_reg[13];
                    c2h_byp_in_mm_or_st_in_reg          <= s00_axi_wdata_reg[14];
                    c2h_byp_in_mm_mrkr_req_reg          <= s00_axi_wdata_reg[15];
                    c2h_byp_in_mm_no_dma_reg            <= s00_axi_wdata_reg[16];
                    c2h_byp_in_mm_sdi_reg               <= s00_axi_wdata_reg[17];
                end
                8'h20: m_axis_c2h_tcrc_reg              <= s00_axi_wdata_reg;
                8'h24: m_axis_c2h_tdata_reg[255:224]    <= s00_axi_wdata_reg;
                8'h28: m_axis_c2h_tdata_reg[223:192]    <= s00_axi_wdata_reg;
                8'h2C: m_axis_c2h_tdata_reg[191:160]    <= s00_axi_wdata_reg;
                8'h30: m_axis_c2h_tdata_reg[159:128]    <= s00_axi_wdata_reg;
                8'h34: m_axis_c2h_tdata_reg[127:96]     <= s00_axi_wdata_reg;
                8'h38: m_axis_c2h_tdata_reg[95:64]      <= s00_axi_wdata_reg;
                8'h3C: m_axis_c2h_tdata_reg[63:32]      <= s00_axi_wdata_reg;
                8'h40: m_axis_c2h_tdata_reg[31:0]       <= s00_axi_wdata_reg;
                8'h44: begin
                    m_axis_c2h_cmpt_ctrl_cmpty_type_reg <= s00_axi_wdata_reg[1:0];
                    m_axis_c2h_cmpt_ctrl_col_idx_reg    <= s00_axi_wdata_reg[4:2];
                    m_axis_c2h_cmpt_dpar_reg            <= s00_axi_wdata_reg[20:5];
                    m_axis_c2h_cmpt_ctrl_err_idx_reg    <= s00_axi_wdata_reg[23:21];
                    m_axis_c2h_cmpt_ctrl_marker_reg     <= s00_axi_wdata_reg[24];
                    m_axis_c2h_cmpt_ctrl_port_id_reg    <= s00_axi_wdata_reg[27:25];
                    m_axis_c2h_cmpt_size_reg            <= s00_axi_wdata_reg[29:28];
                    m_axis_c2h_cmpt_ctrl_user_trig_reg  <= s00_axi_wdata_reg[30];
                end
                8'h48: begin
                    m_axis_c2h_cmpt_ctrl_qid_reg        <= s00_axi_wdata_reg[10:0];
                    m_axis_c2h_cmpt_wait_pld_pkt_id_reg <= s00_axi_wdata_reg[26:11];
                end
                8'h4C: m_axis_c2h_cmpt_tdata_reg[511:480]   <= s00_axi_wdata_reg;
                8'h50: m_axis_c2h_cmpt_tdata_reg[479:448]   <= s00_axi_wdata_reg;
                8'h54: m_axis_c2h_cmpt_tdata_reg[447:416]   <= s00_axi_wdata_reg;
                8'h58: m_axis_c2h_cmpt_tdata_reg[415:384]   <= s00_axi_wdata_reg;
                8'h5C: m_axis_c2h_cmpt_tdata_reg[383:352]   <= s00_axi_wdata_reg;
                8'h60: m_axis_c2h_cmpt_tdata_reg[351:320]   <= s00_axi_wdata_reg;
                8'h64: m_axis_c2h_cmpt_tdata_reg[319:288]   <= s00_axi_wdata_reg;
                8'h68: m_axis_c2h_cmpt_tdata_reg[287:256]   <= s00_axi_wdata_reg;
                8'h6C: m_axis_c2h_cmpt_tdata_reg[255:224]   <= s00_axi_wdata_reg;
                8'h70: m_axis_c2h_cmpt_tdata_reg[223:192]   <= s00_axi_wdata_reg;
                8'h74: m_axis_c2h_cmpt_tdata_reg[191:160]   <= s00_axi_wdata_reg;
                8'h78: m_axis_c2h_cmpt_tdata_reg[159:128]   <= s00_axi_wdata_reg;
                8'h7C: m_axis_c2h_cmpt_tdata_reg[127:96]    <= s00_axi_wdata_reg;
                8'h80: m_axis_c2h_cmpt_tdata_reg[95:64]     <= s00_axi_wdata_reg;
                8'h84: m_axis_c2h_cmpt_tdata_reg[63:32]     <= s00_axi_wdata_reg;
                8'h88: m_axis_c2h_cmpt_tdata_reg[31:0]      <= s00_axi_wdata_reg;
                8'h8C: begin
                    push_desc_fifo_reg                      <= s00_axi_wdata_reg[0];
                    push_cmpt_fifo_reg                      <= s00_axi_wdata_reg[1];
                    push_data_fifo_reg                      <= s00_axi_wdata_reg[2];
                end
            endcase
        end
        else begin
            c2h_byp_in_raddr_reg                    <= c2h_byp_in_raddr_reg;
            c2h_byp_in_waddr_reg                    <= c2h_byp_in_waddr_reg;
            c2h_byp_in_at_reg                       <= c2h_byp_in_at_reg;
            c2h_byp_in_error_reg                    <= c2h_byp_in_error_reg;
            c2h_byp_in_func_reg                     <= c2h_byp_in_func_reg;
            c2h_byp_in_st_pfch_tag_reg              <= c2h_byp_in_st_pfch_tag_reg;
            c2h_byp_in_port_id_reg                  <= c2h_byp_in_port_id_reg;
            c2h_byp_in_qid_reg                      <= c2h_byp_in_qid_reg;
            c2h_byp_in_mm_or_st_in_reg              <= c2h_byp_in_mm_or_st_in_reg;
            c2h_byp_in_mm_cidx_reg                  <= c2h_byp_in_mm_cidx_reg;
            c2h_byp_in_mm_len_reg                   <= c2h_byp_in_mm_len_reg;
            c2h_byp_in_mm_mrkr_req_reg              <= c2h_byp_in_mm_mrkr_req_reg;
            c2h_byp_in_mm_no_dma_reg                <= c2h_byp_in_mm_no_dma_reg;
            c2h_byp_in_mm_sdi_reg                   <= c2h_byp_in_mm_sdi_reg;
            push_desc_fifo_reg                      <= push_desc_fifo_reg;
            m_axis_c2h_has_cmpt_reg                 <= m_axis_c2h_has_cmpt_reg;
            m_axis_c2h_len_reg                      <= m_axis_c2h_len_reg;
            m_axis_c2h_marker_reg                   <= m_axis_c2h_marker_reg;
            m_axis_c2h_port_id_reg                  <= m_axis_c2h_port_id_reg;
            m_axis_c2h_qid_reg                      <= m_axis_c2h_qid_reg;
            m_axis_c2h_ecc_reg                      <= m_axis_c2h_ecc_reg;
            m_axis_c2h_mty_reg                      <= m_axis_c2h_mty_reg;
            m_axis_c2h_tcrc_reg                     <= m_axis_c2h_tcrc_reg;
            m_axis_c2h_tdata_reg                    <= m_axis_c2h_tdata_reg;
            m_axis_c2h_tlast_reg                    <= m_axis_c2h_tlast_reg;
            push_cmpt_fifo_reg                      <= push_cmpt_fifo_reg;
            m_axis_c2h_cmpt_ctrl_cmpty_type_reg     <= m_axis_c2h_cmpt_ctrl_cmpty_type_reg;
            m_axis_c2h_cmpt_ctrl_col_idx_reg        <= m_axis_c2h_cmpt_ctrl_col_idx_reg;
            m_axis_c2h_cmpt_tdata_reg               <= m_axis_c2h_cmpt_tdata_reg;
            m_axis_c2h_cmpt_dpar_reg                <= m_axis_c2h_cmpt_dpar_reg;
            m_axis_c2h_cmpt_ctrl_err_idx_reg        <= m_axis_c2h_cmpt_ctrl_err_idx_reg;
            m_axis_c2h_cmpt_ctrl_marker_reg         <= m_axis_c2h_cmpt_ctrl_marker_reg;
            m_axis_c2h_cmpt_ctrl_port_id_reg        <= m_axis_c2h_cmpt_ctrl_port_id_reg;
            m_axis_c2h_cmpt_ctrl_qid_reg            <= m_axis_c2h_cmpt_ctrl_qid_reg;
            m_axis_c2h_cmpt_size_reg                <= m_axis_c2h_cmpt_size_reg;
            m_axis_c2h_cmpt_ctrl_user_trig_reg      <= m_axis_c2h_cmpt_ctrl_user_trig_reg;
            m_axis_c2h_cmpt_wait_pld_pkt_id_reg     <= m_axis_c2h_cmpt_wait_pld_pkt_id_reg;
            push_data_fifo_reg                      <= push_data_fifo_reg;
        end
    end

    
    // Generate push to data fifo for one cycle
    reg push_data_fifo_reg_d1;
    reg push_data_fifo_reg_d2;
    always @ (posedge aclk) begin
        if (!aresetn) begin
            push_data_fifo_reg_d1 <= 1'b0;
            push_data_fifo_reg_d2 <= 1'b0;
        end else if ((push_data_fifo_reg == 1'b1) && (push_data_fifo_reg_d1 == 1'b0 && push_data_fifo_reg_d2 == 1'b0 )) begin
            push_data_fifo_reg_d1 <= 1'b1;
            push_data_fifo_reg_d2 <= 1'b1;
        end else if ((push_data_fifo_reg == 1'b1) && (push_data_fifo_reg_d1 == 1'b1 && push_data_fifo_reg_d2 == 1'b1 ))  begin
            push_data_fifo_reg_d2 <= 1'b0;
        end else if (push_data_fifo_reg == 1'b0)  begin
            push_data_fifo_reg_d1 <= 1'b0;
            push_data_fifo_reg_d2 <= 1'b0;
        end else begin
            push_data_fifo_reg_d1 <= push_data_fifo_reg_d1;
            push_data_fifo_reg_d2 <= push_data_fifo_reg_d2;
        end
    end
    
    

    // Generate push to desc fifo for one cycle
    reg push_desc_fifo_reg_d1;
    reg push_desc_fifo_reg_d2;
    always @ (posedge aclk) begin
        if (!aresetn) begin
            push_desc_fifo_reg_d1 <= 1'b0;
            push_desc_fifo_reg_d2 <= 1'b0;
        end else if ((push_desc_fifo_reg == 1'b1) && (push_desc_fifo_reg_d1 == 1'b0 && push_desc_fifo_reg_d2 == 1'b0 )) begin
            push_desc_fifo_reg_d1 <= 1'b1;
            push_desc_fifo_reg_d2 <= 1'b1;
        end else if ((push_desc_fifo_reg == 1'b1) && (push_desc_fifo_reg_d1 == 1'b1 && push_desc_fifo_reg_d2 == 1'b1 ))  begin
            push_desc_fifo_reg_d2 <= 1'b0;
        end else if (push_desc_fifo_reg == 1'b0)  begin
            push_desc_fifo_reg_d1 <= 1'b0;
            push_desc_fifo_reg_d2 <= 1'b0;
        end else begin
            push_desc_fifo_reg_d1 <= push_desc_fifo_reg_d1;
            push_desc_fifo_reg_d2 <= push_desc_fifo_reg_d2;
        end
    end
    
    // Generate push to cmpt fifo for one cycle
    reg push_cmpt_fifo_reg_d1;
    reg push_cmpt_fifo_reg_d2;
    always @ (posedge aclk) begin
        if (!aresetn) begin
            push_cmpt_fifo_reg_d1 <= 1'b0;
            push_cmpt_fifo_reg_d2 <= 1'b0;
        end else if ((push_cmpt_fifo_reg == 1'b1) && (push_cmpt_fifo_reg_d1 == 1'b0 && push_cmpt_fifo_reg_d2 == 1'b0 )) begin
            push_cmpt_fifo_reg_d1 <= 1'b1;
            push_cmpt_fifo_reg_d2 <= 1'b1;
        end else if ((push_cmpt_fifo_reg == 1'b1) && (push_cmpt_fifo_reg_d1 == 1'b1 && push_cmpt_fifo_reg_d2 == 1'b1 ))  begin
            push_cmpt_fifo_reg_d2 <= 1'b0;
        end else if (push_cmpt_fifo_reg == 1'b0)  begin
            push_cmpt_fifo_reg_d1 <= 1'b0;
            push_cmpt_fifo_reg_d2 <= 1'b0;
        end else begin
            push_cmpt_fifo_reg_d1 <= push_cmpt_fifo_reg_d1;
            push_cmpt_fifo_reg_d2 <= push_cmpt_fifo_reg_d2;
        end
    end
    
    // Concatenate registers for dsc FIFO
    wire [DSC_FIFO_DATA_WIDTH-1:0]  dsc_fifo_din;
    wire [DSC_FIFO_DATA_WIDTH-1:0]  dsc_fifo_dout;
    wire                            dsc_fifo_empty;
    wire                            dsc_fifo_full;
    wire                            dsc_fifo_wr_en;
    
    assign {c2h_byp_in_raddr,
            c2h_byp_in_waddr,
            c2h_byp_in_at,
            c2h_byp_in_error,
            c2h_byp_in_func,
            c2h_byp_in_st_pfch_tag,
            c2h_byp_in_port_id,
            c2h_byp_in_qid,
            c2h_byp_in_mm_or_st_out,
            c2h_byp_in_mm_cidx,
            c2h_byp_in_mm_len,
            c2h_byp_in_mm_mrkr_req,
            c2h_byp_in_mm_no_dma,
            c2h_byp_in_mm_sdi} = dsc_fifo_dout;
    
    assign dsc_fifo_din = {         c2h_byp_in_raddr_reg,
                                    c2h_byp_in_waddr_reg,
                                    c2h_byp_in_at_reg,
                                    c2h_byp_in_error_reg,
                                    c2h_byp_in_func_reg,
                                    c2h_byp_in_st_pfch_tag_reg,
                                    c2h_byp_in_port_id_reg,
                                    c2h_byp_in_qid_reg,
                                    c2h_byp_in_mm_or_st_in_reg,
                                    c2h_byp_in_mm_cidx_reg,
                                    c2h_byp_in_mm_len_reg,
                                    c2h_byp_in_mm_mrkr_req_reg,
                                    c2h_byp_in_mm_no_dma_reg,
                                    c2h_byp_in_mm_sdi_reg};
                            
    
    
    // Hooking up desc FIFO
    assign c2h_byp_in_st_vld      = ~dsc_fifo_empty & ~c2h_byp_in_mm_or_st_in_reg;
    assign c2h_byp_in_mm_vld      = ~dsc_fifo_empty & c2h_byp_in_mm_or_st_in_reg;
    assign dsc_fifo_wr_en         = push_desc_fifo_reg_d2;
    xpm_fifo_sync #(
        .DOUT_RESET_VALUE("0"),
        .ECC_MODE("no_ecc"),
        .FIFO_MEMORY_TYPE("auto"),
        .FIFO_READ_LATENCY(1),
        .FIFO_WRITE_DEPTH(FIFO_DEPTH),
        .FULL_RESET_VALUE(0),
        .PROG_EMPTY_THRESH(10),
        .PROG_FULL_THRESH(10),
        .RD_DATA_COUNT_WIDTH(FIFO_DATA_COUNT_WIDTH),
        .READ_DATA_WIDTH(DSC_FIFO_DATA_WIDTH),
        .READ_MODE("fwft"),
        .SIM_ASSERT_CHK(0),
        .USE_ADV_FEATURES("0000"),
        .WAKEUP_TIME(0),
        .WRITE_DATA_WIDTH(DSC_FIFO_DATA_WIDTH),
        .WR_DATA_COUNT_WIDTH(FIFO_DATA_COUNT_WIDTH)
    )
    desc_fifo (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(dsc_fifo_dout),
      .empty(dsc_fifo_empty),
      .full(dsc_fifo_full),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din(dsc_fifo_din),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(c2h_byp_in_mm_or_st_in_reg ? c2h_byp_in_mm_rdy : c2h_byp_in_st_rdy),
      .rst(~aresetn), // turning into active low                
      .sleep(1'b0),
      .wr_clk(aclk),
      .wr_en(dsc_fifo_wr_en)
    );
    
    
    
    // Concatenate registers for data FIFO
    wire [DATA_FIFO_DATA_WIDTH-1:0] data_fifo_din;
    wire [DATA_FIFO_DATA_WIDTH-1:0] data_fifo_dout;
    wire                            data_fifo_empty;
    wire                            data_fifo_full;
    wire                            data_fifo_wr_en;
    
    assign {m_axis_c2h_has_cmpt,
            m_axis_c2h_len,
            m_axis_c2h_marker,
            m_axis_c2h_port_id,
            m_axis_c2h_qid,
            m_axis_c2h_ecc,
            m_axis_c2h_mty,
            m_axis_c2h_tcrc,
            m_axis_c2h_tdata,
            m_axis_c2h_tlast} = data_fifo_dout;
    
    assign data_fifo_din = {        m_axis_c2h_has_cmpt_reg,
                                    m_axis_c2h_len_reg,
                                    m_axis_c2h_marker_reg,
                                    m_axis_c2h_port_id_reg,
                                    m_axis_c2h_qid_reg,
                                    m_axis_c2h_ecc_reg,
                                    m_axis_c2h_mty_reg,
                                    m_axis_c2h_tcrc_reg,
                                    m_axis_c2h_tdata_reg,
                                    m_axis_c2h_tlast_reg}; 
                                

    // Hooking up desc FIFO
    assign m_axis_c2h_tvalid       = ~data_fifo_empty;
    assign data_fifo_wr_en         = push_data_fifo_reg_d2;
    xpm_fifo_sync #(
        .DOUT_RESET_VALUE("0"),
        .ECC_MODE("no_ecc"),
        .FIFO_MEMORY_TYPE("auto"),
        .FIFO_READ_LATENCY(1),
        .FIFO_WRITE_DEPTH(FIFO_DEPTH),
        .FULL_RESET_VALUE(0),
        .PROG_EMPTY_THRESH(10),
        .PROG_FULL_THRESH(10),
        .RD_DATA_COUNT_WIDTH(FIFO_DATA_COUNT_WIDTH),
        .READ_DATA_WIDTH(DATA_FIFO_DATA_WIDTH),
        .READ_MODE("fwft"),
        .SIM_ASSERT_CHK(0),
        .USE_ADV_FEATURES("0000"),
        .WAKEUP_TIME(0),
        .WRITE_DATA_WIDTH(DATA_FIFO_DATA_WIDTH),
        .WR_DATA_COUNT_WIDTH(FIFO_DATA_COUNT_WIDTH)
    )
    data_fifo (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(data_fifo_dout),
      .empty(data_fifo_empty),
      .full(data_fifo_full),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din(data_fifo_din),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(m_axis_c2h_tready),
      .rst(~aresetn), // turning into active low                
      .sleep(1'b0),
      .wr_clk(aclk),
      .wr_en(data_fifo_wr_en)
    );

    // Concatenate registers for cmpt FIFO
    wire [CMPT_FIFO_DATA_WIDTH-1:0] cmpt_fifo_din;
    wire [CMPT_FIFO_DATA_WIDTH-1:0] cmpt_fifo_dout;
    wire                            cmpt_fifo_empty;
    wire                            cmpt_fifo_full;
    wire                            cmpt_fifo_wr_en;
    
    
    assign {m_axis_c2h_cmpt_ctrl_cmpty_type,
            m_axis_c2h_cmpt_ctrl_col_idx,
            m_axis_c2h_cmpt_tdata,
            m_axis_c2h_cmpt_dpar,
            m_axis_c2h_cmpt_ctrl_err_idx,
            m_axis_c2h_cmpt_ctrl_marker,
            m_axis_c2h_cmpt_ctrl_port_id,
            m_axis_c2h_cmpt_ctrl_qid,
            m_axis_c2h_cmpt_size,
            m_axis_c2h_cmpt_ctrl_user_trig,
            m_axis_c2h_cmpt_wait_pld_pkt_id} = cmpt_fifo_dout;
                  
    assign cmpt_fifo_din = {        m_axis_c2h_cmpt_ctrl_cmpty_type_reg,
                                    m_axis_c2h_cmpt_ctrl_col_idx_reg,
                                    m_axis_c2h_cmpt_tdata_reg,
                                    m_axis_c2h_cmpt_dpar_reg,
                                    m_axis_c2h_cmpt_ctrl_err_idx_reg,
                                    m_axis_c2h_cmpt_ctrl_marker_reg,
                                    m_axis_c2h_cmpt_ctrl_port_id_reg,
                                    m_axis_c2h_cmpt_ctrl_qid_reg,
                                    m_axis_c2h_cmpt_size_reg,
                                    m_axis_c2h_cmpt_ctrl_user_trig_reg,
                                    m_axis_c2h_cmpt_wait_pld_pkt_id_reg};                  
   
    
    
    // Hooking up desc FIFO
    assign m_axis_c2h_cmpt_tvalid  = ~cmpt_fifo_empty;
    assign cmpt_fifo_wr_en         = push_cmpt_fifo_reg_d2;
    xpm_fifo_sync #(
        .DOUT_RESET_VALUE("0"),
        .ECC_MODE("no_ecc"),
        .FIFO_MEMORY_TYPE("auto"),
        .FIFO_READ_LATENCY(1),
        .FIFO_WRITE_DEPTH(FIFO_DEPTH),
        .FULL_RESET_VALUE(0),
        .PROG_EMPTY_THRESH(10),
        .PROG_FULL_THRESH(10),
        .RD_DATA_COUNT_WIDTH(FIFO_DATA_COUNT_WIDTH),
        .READ_DATA_WIDTH(CMPT_FIFO_DATA_WIDTH),
        .READ_MODE("fwft"),
        .SIM_ASSERT_CHK(0),
        .USE_ADV_FEATURES("0000"),
        .WAKEUP_TIME(0),
        .WRITE_DATA_WIDTH(CMPT_FIFO_DATA_WIDTH),
        .WR_DATA_COUNT_WIDTH(FIFO_DATA_COUNT_WIDTH)
    )
    cmpt_fifo (
      .almost_empty(),
      .almost_full(),
      .data_valid(),
      .dbiterr(),
      .dout(cmpt_fifo_dout),
      .empty(cmpt_fifo_empty),
      .full(cmpt_fifo_full),
      .overflow(),
      .prog_empty(),
      .prog_full(),
      .rd_data_count(),
      .rd_rst_busy(),
      .sbiterr(),
      .underflow(),
      .wr_ack(),
      .wr_data_count(),
      .wr_rst_busy(),
      .din(cmpt_fifo_din),
      .injectdbiterr(),
      .injectsbiterr(),
      .rd_en(m_axis_c2h_cmpt_tready),
      .rst(~aresetn), // turning into active low                
      .sleep(1'b0),
      .wr_clk(aclk),
      .wr_en(cmpt_fifo_wr_en)
    );

endmodule
