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



module receive_controller(
    input  wire clk,
    input  wire aresetn,
    input  wire arvalid,
    input  wire rready,
    output reg arready,
    output reg rvalid
);
    
    reg [1:0]   state, state_n;
    reg         arready_n;
    reg         rvalid_n;

    localparam WAIT_STATE = 0, AR_STATE = 1, R_STATE = 2;
    
    
    // Registered Mealy FSM
    always@(*) begin
        case(state)
            WAIT_STATE: begin            
                rvalid_n    <= 1'b0;
                if(~arvalid) begin
                    arready_n   <= 1'b0;
                    state_n     <= WAIT_STATE;
                end
                else begin
                    arready_n   <= 1'b1;
                    state_n     <= AR_STATE;
                end
            
            end
        
            AR_STATE: begin
                arready_n   <= 1'b0;
                rvalid_n    <= 1'b1;
                state_n     <= R_STATE;
            end
            
            R_STATE: begin
                arready_n   <= 1'b0;
                if(~rready) begin
                    rvalid_n    <= 1'b1;
                    state_n     <= R_STATE;
                end
                else begin
                    rvalid_n    <= 1'b0;
                    state_n     <= WAIT_STATE;
                end
            end    
        endcase
    end 
    
    
    always@(posedge clk) begin
        if(~aresetn) begin
            state       <= WAIT_STATE;
            arready     <= 1'b0;
            rvalid      <= 1'b0;
        end
        else begin
            state       <= state_n;
            arready     <= arready_n;
            rvalid      <= rvalid_n;
        end
    end


endmodule
