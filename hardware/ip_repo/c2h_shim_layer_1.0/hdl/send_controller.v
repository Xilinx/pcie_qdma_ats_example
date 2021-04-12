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

`timescale 1ns / 1ps



module send_controller(
    input  wire clk,
    input  wire aresetn,
    input  wire awvalid,
    input  wire wvalid,
    input  wire bready,
    output reg awready,
    output reg wready,
    output reg bvalid,
    output reg reg_file_wr_en
);

    reg [1:0]   state, state_n;
    reg         awready_n;
    reg         wready_n;
    reg         bvalid_n;
    reg         reg_file_wr_en_n;

    localparam WAIT_STATE = 0, W_AW_STATE = 1, B_STATE = 2;


    // Registered Mealy FSM
    always@(*) begin
        case(state)
            WAIT_STATE: begin
                bvalid_n            <= 1'b0;
                reg_file_wr_en_n    <= 1'b0;
                if(~awvalid | ~wvalid) begin
                    awready_n   <= 1'b0;
                    wready_n    <= 1'b0;
                    state_n     <= WAIT_STATE;
                end
                else begin
                    awready_n   <= 1'b1;
                    wready_n    <= 1'b1;
                    state_n     <= W_AW_STATE;
                end

            end

            W_AW_STATE: begin
                reg_file_wr_en_n    <= 1'b1;
                awready_n           <= 1'b0;
                wready_n            <= 1'b0;
                bvalid_n            <= 1'b1;
                state_n             <= B_STATE;
            end
            
            B_STATE: begin
                awready_n           <= 1'b0;
                wready_n            <= 1'b0;
                reg_file_wr_en_n    <= 1'b1;
                if(~bready) begin
                    bvalid_n    <= 1'b1;
                    state_n     <= B_STATE;
                end
                else begin
                    bvalid_n    <= 1'b0;
                    state_n     <= WAIT_STATE;
                end
            end
            
        endcase
    end


    always@(posedge clk) begin
        if(~aresetn) begin
            state           <= WAIT_STATE;
            awready         <= 1'b0;
            wready          <= 1'b0;
            bvalid          <= 1'b0;
            reg_file_wr_en  <= 1'b0;
        end
        else begin
            state           <= state_n;
            awready         <= awready_n;
            wready          <= wready_n;
            bvalid          <= bvalid_n;
            reg_file_wr_en  <= reg_file_wr_en_n;
        end
    end

endmodule