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
// File       : sample_tests.vh
// Version    : 5.0
//-----------------------------------------------------------------------------
//
//------------------------------------------------------------------------------


else if(testname =="irq_test0")
begin

board.RP.tx_usrapp.TSK_QDMA_MM_TEST(0, 0);
   #1000;
board.RP.tx_usrapp.TSK_USR_IRQ_TEST;   

end


else if(testname =="dma_stream0")
begin

   //----------------------------------------------------------------------------------------
   // XDMA H2C Test Starts
   //----------------------------------------------------------------------------------------

    $display(" **** XDMA AXI-ST *** \n");
    $display(" **** read Address at BAR0  = %h\n", board.RP.tx_usrapp.BAR_INIT_P_BAR[0][31:0]);
    $display(" **** read Address at BAR1  = %h\n", board.RP.tx_usrapp.BAR_INIT_P_BAR[1][31:0]);

    //-------------- Load DATA in Buffer ----------------------------------------------------
    board.RP.tx_usrapp.TSK_INIT_DATA_H2C;
    board.RP.tx_usrapp.TSK_INIT_DATA_C2H;

    board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h00);
      
    //-------------- Descriptor start address for both H2C and C2H --------------------------
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h4080, 32'h00000100, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h5080, 32'h00000300, 4'hF);
    
    // completion count writeback addresses
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h0088, 32'h00000000, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h008C, 32'h0, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h1088, 32'h00000080, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h108C, 32'h0, 4'hF);
      
    //-------------- Start DMA tranfer ------------------------------------------------------
    $display(" **** Start DMA Stream for both H2C and C2H transfer ***\n");    
    
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h1004, 32'h2fffe7f, 4'hF);   // Enable C2H DMA
    fork
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h0004, 32'h2fffe7f, 4'hF);   // Enable H2C DMA
    
    //compare C2H data
    $display("------Compare C2H Data--------\n");
    board.RP.tx_usrapp.COMPARE_DATA_C2H({16'h0,board.RP.tx_usrapp.DMA_BYTE_CNT}, 1024);
    join

    // Wait for data transfer complete.

    // For this example design there is 1 descriptor for H2c and 1 for C2H
    // Read C2H Descriptor count and wiat until it returns 1.
    // Becase it is a loopback, by reading C2H descriptor count to 1
    // it ensures H2C descriptor is also set to 1.
    loop_timeout = 0;
    desc_count = 0;
    while (desc_count == 0 && loop_timeout <= 10) begin
          board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h1040);
          $display ("**** C2H status = %h\n", P_READ_DATA);
          board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h0040);
          $display ("**** H2C status = %h\n", P_READ_DATA);
          board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h0048);
          $display ("**** H2C Decsriptor Count = %h\n", P_READ_DATA);
          board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h1048);
          $display ("**** C2H Decsriptor Count = %h\n", P_READ_DATA);
          if (P_READ_DATA == 32'h1) begin
            desc_count = 1;
          end else begin
            #10;
            loop_timeout = loop_timeout + 1;
          end
    end

        if (desc_count != 1) begin
            $display ("---***ERROR*** C2H Descriptor count mismatch,Loop Timeout occured ---\n");
        end
    // Read status of both H2C and C2H engines.
    board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h1040);
    c2h_status = P_READ_DATA;
    if (c2h_status != 32'h6) begin
        $display ("---***ERROR*** C2H status mismatch ---\n");
    end
    board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h0040);
    h2c_status = P_READ_DATA;
    if (h2c_status != 32'h6) begin
        $display ("---***ERROR*** H2C status mismatch ---\n");
    end
    // Disable run bit for H2C and C2H engine
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h1004, 32'h0, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h0004, 32'h0, 4'hF);

    #100;  
   $finish;
end

else if(testname =="dma_test0")
begin

    //------------- This test performs a 32 bit write to a 32 bit Memory space and performs a read back

	//----------------------------------------------------------------------------------------
	// XDMA H2C Test Starts
	//----------------------------------------------------------------------------------------

    $display(" *** XDMA H2C *** \n");

    $display(" **** read Address at BAR0  = %h\n", board.RP.tx_usrapp.BAR_INIT_P_BAR[0][31:0]);
    $display(" **** read Address at BAR1  = %h\n", board.RP.tx_usrapp.BAR_INIT_P_BAR[1][31:0]);

    //-------------- Load DATA in Buffer ----------------------------------------------------
      board.RP.tx_usrapp.TSK_INIT_DATA_H2C;

	//-------------- DMA Engine ID Read -----------------------------------------------------
      board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h00);
      
    //-------------- Descriptor start address x0100 -----------------------------------------
	  board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h4080, 32'h00000100, 4'hF);
      
    //-------------- Start DMA tranfer ------------------------------------------------------
      $display(" **** Start DMA H2C transfer ***\n");

    fork
    //-------------- Writing XDMA CFG Register to start DMA Transfer for H2C ----------------
      board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h0004, 32'hfffe7f, 4'hF);   // Enable H2C DMA

    //-------------- compare H2C data -------------------------------------------------------
      $display("------Compare H2C Data --------\n");
      board.RP.tx_usrapp.COMPARE_DATA_H2C({16'h0,board.RP.tx_usrapp.DMA_BYTE_CNT},1024);    //input payload bytes
    join
    loop_timeout = 0;
    desc_count = 0;
    //For this Example Design there is only one Descriptor used, so Descriptor Count would be 1
      while (desc_count == 0 && loop_timeout <= 10) begin
          board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h0040);
          $display ("**** H2C status = %h\n", P_READ_DATA);
          board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h48);
          $display ("**** H2C Decsriptor Count = %h\n", P_READ_DATA);
          if (P_READ_DATA == 32'h1) begin
            desc_count = 1;
          end else begin
            #10;
            loop_timeout = loop_timeout + 1;
          end

      end
      if (desc_count != 1) begin
          $display ("---***ERROR*** H2C Descriptor count mismatch,Loop Timeout occured ---\n");
      end
      board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h40);
      $display ("H2C DMA_STATUS  = %h\n", P_READ_DATA); // bit2 : Descriptor completed; bit1: Descriptor end; bit0: DMA Stopped
      h2c_status = P_READ_DATA;
      if (h2c_status != 32'h6) begin
        $display ("---***ERROR*** H2C status mismatch ---\n");
      end
	  $display ("bit2 : Descriptor completed; bit1: Descriptor end; bit0: DMA Stopped\n");

    //-------------- XDMA H2C and C2H Transfer separated by 1000ns --------------------------
      #1000;

    //----------------------------------------------------------------------------------------
    // XDMA C2H Test Starts
    //----------------------------------------------------------------------------------------
	
      $display(" *** XDMA C2H *** \n");

      desc_count = 0;
      loop_timeout = 0;
    //-------------- Load DATA in Buffer ----------------------------------------------------
      board.RP.tx_usrapp.TSK_INIT_DATA_C2H;

    //-------------- Descriptor start address x0300 -----------------------------------------
      board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h5080, 32'h00000300, 4'hF);

    // Start DMA transfer
      $display(" **** Start DMA C2H transfer ***\n");

    fork
    //-------------- Writing XDMA CFG Register to start DMA Transfer for C2H ----------------
      board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h1004, 32'hfffe7f, 4'hF);   // Enable C2H DMA

    //compare C2H data
      $display("------Compare C2H Data--------\n");
      board.RP.tx_usrapp.COMPARE_DATA_C2H({16'h0,board.RP.tx_usrapp.DMA_BYTE_CNT}, 1024);
    join

    //For this Example Design there is only one Descriptor used, so Descriptor Count would be 1

      while (desc_count == 0 && loop_timeout <= 10) begin
          board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h1040);
          $display ("**** C2H status = %h\n", P_READ_DATA);
          board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h1048);
          $display ("**** C2H Decsriptor Count = %h\n", P_READ_DATA);
          if (P_READ_DATA == 32'h1) begin
            desc_count = 1;
          end else begin
            #10;
            loop_timeout = loop_timeout + 1;
          end
      end
      if (desc_count != 1) begin
          $display ("---***ERROR*** C2H Descriptor count mismatch,Loop Timeout occured ---\n");
      end
      board.RP.tx_usrapp.TSK_XDMA_REG_READ(16'h1040);
      $display ("C2H DMA_STATUS  = %h\n", P_READ_DATA); // bit2 : Descriptor completed; bit1: Descriptor end; bit0: DMA Stopped
      c2h_status = P_READ_DATA;
      if (c2h_status != 32'h6) begin
        $display ("---***ERROR*** C2H status mismatch ---\n");
      end
      $display ("bit2 : Descriptor completed; bit1: Descriptor end; bit0: DMA Stopped\n");



      #100;

    #1000;

   $finish;
end
else if(testname =="qdma_mm_test0")
begin
   board.RP.tx_usrapp.TSK_QDMA_MM_TEST(0, 1);
   #1000;
   board.RP.tx_usrapp.pfTestIteration = board.RP.tx_usrapp.pfTestIteration + 1;
   if (board.RP.tx_usrapp.test_state == 1 )
     $display ("ERROR: TEST FAILED \n");
   #1000;
   $finish;
end
else if(testname =="qdma_mm_cmpt_test0")
begin
   board.RP.tx_usrapp.TSK_QDMA_MM_TEST(0, 0);
   board.RP.tx_usrapp.TSK_QDMA_IMM_TEST();
   #1000;
   board.RP.tx_usrapp.pfTestIteration = board.RP.tx_usrapp.pfTestIteration + 1;
   if (board.RP.tx_usrapp.test_state == 1 )
     $display ("ERROR: TEST FAILED \n");
   #1000;
   $finish;
end

else if(testname == "qdma_st_test0")
begin
   board.RP.tx_usrapp.TSK_QDMA_ST_TEST(0);
   #1000;
   board.RP.tx_usrapp.pfTestIteration = board.RP.tx_usrapp.pfTestIteration + 1;
    if (board.RP.tx_usrapp.test_state == 1 )
     $display ("ERROR: TEST FAILED \n");
   #1000;
   $finish;
end
else if(testname == "qdma_st_c2h_test0")
begin
   board.RP.tx_usrapp.TSK_QDMA_ST_C2H_CMPT_TEST(0);
   #1000;
   board.RP.tx_usrapp.pfTestIteration = board.RP.tx_usrapp.pfTestIteration + 1;
    if (board.RP.tx_usrapp.test_state == 1 )
     $display ("ERROR: TEST FAILED \n");
   #1000;
   $finish;
end
else if(testname == "qdma_st_loopback_test0")
begin
   board.RP.tx_usrapp.TSK_QDMA_ST_LOOPBACK_TEST(0);
   #1000;
   board.RP.tx_usrapp.pfTestIteration = board.RP.tx_usrapp.pfTestIteration + 1;
    if (board.RP.tx_usrapp.test_state == 1 )
     $display ("ERROR: TEST FAILED \n");
   #1000;
   $finish;
end

else if(testname == "qdma_imm_test0")
begin
   board.RP.tx_usrapp.TSK_QDMA_IMM_TEST();
   #1000;
   board.RP.tx_usrapp.pfTestIteration = board.RP.tx_usrapp.pfTestIteration + 1;
    if (board.RP.tx_usrapp.test_state == 1 )
     $display ("ERROR: TEST FAILED \n");
   #1000;
   $finish;
end

else if(testname == "qdma_mm_st_test0")
begin
    
    //--------------------------------------------------------------------------
    // Direct Root Port to allow upstream traffic by enabling Mem, I/O and
    // BusMstr in the command register
    //--------------------------------------------------------------------------
    $display("[%t] : Direct Root Port to allow upstream traffic by enabling Mem, I/O and  BusMstr in the command register", $realtime);   
    board.RP.cfg_usrapp.TSK_READ_CFG_DW(32'h00000001);
    board.RP.cfg_usrapp.TSK_WRITE_CFG_DW(32'h00000001, 32'h00000007, 4'b0001);
    board.RP.cfg_usrapp.TSK_READ_CFG_DW(32'h00000001);
    
    if (board.RP.tx_usrapp.test_state == 1 )
        $display ("ERROR: TEST FAILED \n");
        
        
    // This is to just test other messages
    $display("[%t] : Issue VDM message",$realtime); 
    board.RP.tx_usrapp.TSK_TX_MESSAGE_VDM(      
        board.RP.tx_usrapp.DEFAULT_TAG,     // [7:0]    tag_;
        3'b000,                             // [2:0]    tc_;
        11'b00000000001,                    // [10:0]   len_;
        64'h0000000000009038,               // [63:0]   data_; 63_32 = VDM header 31:16 = dest_id 15:0 = Vend_id
        3'b011,                             // [2:0]    message_rtg_;
        8'h7E                               // [7:0]    message_code_;  
    );
    
    // First invalidate has an address of 0
    $display("[%t] : Issue invalidate request to 0x0000000000000000",$realtime);
    board.RP.tx_usrapp.TSK_TX_ATS_MESSAGE_DATA(
       board.RP.tx_usrapp.DEFAULT_TAG,     //input  [4:0]    itag_;           
       64'h0000000000000000,               //input  [63:0]   addr_;           
       1'b0,                               //input           s_ rangei is greater than 4096 
       8'h01,                              //input  [7:0]   dest_dev_id_bus_;                                                             
       8'h00                               //input  [7:0]   dest_dev_id_num_; 
    );     
    #50000; 
    
    // Second invalidate signifies to clear IOTLB
    $display("[%t] : Issue invalidate request to 0x7FFFFFFFFFFFFFFF",$realtime);  
    board.RP.tx_usrapp.TSK_TX_ATS_MESSAGE_DATA(             
        board.RP.tx_usrapp.DEFAULT_TAG,     //input  [4:0]    itag_;   
        64'h7FFFFFFFFFFFFFFF,               //input  [63:0]   addr_;           
        1'b0,                               //input           s_ rangei is greater than 4096              
        8'h01,                              //input  [7:0]    dest_dev_id_bus_;
        8'h00                               //input  [7:0]    dest_dev_id_num_;
    );
    #50000;
    
    // Assign Q 2 for AXI-ST
    pf0_qmax = 11'h200;
    axi_st_q = 11'h2;
   
    // initilize all ring size to some value.
    //-------------- Global Ring Size for Queue 0  0x204  : num of dsc 16 ------------------------
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h204, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h208, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h20C, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h210, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h214, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h218, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h21C, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h220, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h224, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h228, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h22C, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h230, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h234, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h238, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h23C, 32'h00000010, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h240, 32'h00000010, 4'hF);


    //-------------- Global Function MAP 0x400  : Func0 22:11 Qnumber ( 1 Queue ) : 10:0 Qid_base for this Func
    //-------------- Global Function MAP 0x400  : Func0 22:11 Qnumber ( 16 Queue ) : 10:0 Qid_base for this Func
    // set up 16Queues
    // Func number is 0 : 0*4 = 0: address 0x400+ Fnum*4 = 0x400
    // 22:11 : 1_0000 : number of queues for this function. 
    // 10:0  : 000_0000_0000 : Queue off set 
    // 1000_0000_0000_0000 : 0x8000
    $display ("[%t] : Setting global function map", $realtime);
    for(pf_loop_index=0; pf_loop_index <= pfTestIteration; pf_loop_index = pf_loop_index + 1) begin
	   if(pf_loop_index == pfTestIteration) begin
            wr_dat = {14'h0,pf0_qmax[10:0],11'h00};
            board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h400+(pf_loop_index*4), wr_dat[31:0], 4'hF);
	   end else begin
	        wr_dat = 32'h00000000;
            board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h400+(pf_loop_index*4), wr_dat[31:0], 4'hF);
       end
    end
    
    // This is necessary to start H2C MM engine. Streaming doesn't seem to need it
    $display ("[%t] : Setting run bit in H2C MM engine", $realtime);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h1204, 32'h00000001, 4'hF);     
    #50000;
    
    // This is necessary to start C2H MM engine. Streaming doesn't seem to need it
    $display ("[%t] : Setting run bit in C2H MM engine", $realtime);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h1004, 32'h00000001, 4'hF);     
    #50000;
    
    // Setup context
    //-------------- Ind Dire CTXT MASK 0xffffffff for all 256 bits -------------------
    $display ("[%t] : Setting CTXT MASK", $realtime);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h824, 32'hffffffff, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h828, 32'hffffffff, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h82C, 32'hffffffff, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h830, 32'hffffffff, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h834, 32'hffffffff, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h838, 32'hffffffff, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h83C, 32'hffffffff, 4'hF);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h840, 32'hffffffff, 4'hF);
    

    //-------------- Program C2H DSC buffer size to 4K ----------------------------------------------
    $display ("[%t] : Programming C2H DSC Buffer", $realtime);
    board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'hAB0, 32'h00001000, 4'hF);


    // setup Stream C2H context
    //-------------- C2H CTXT DATA -------------------
    // ring size index is at 1
    $display ("[%t] : Setting up C2H context", $realtime);
    wr_dat[255:128] = 'd0;
    wr_dat[127:64]  =  (64'h0 | C2H_ADDR); // dsc base
    wr_dat[63]      =  1'b0;  // is_mm
    wr_dat[62]      =  1'b0;  // mrkr_dis
    wr_dat[61]      =  1'b0;  // irq_req
    wr_dat[60]      =  1'b0;  // err_wb_sent
    wr_dat[59:58]   =  2'b0;  // err        
    wr_dat[57]      =  1'b0;  // irq_no_last
    wr_dat[56:54]   =  3'h0;  // port_id
    wr_dat[53]      =  1'b0;  // irq_en     
    wr_dat[52]      =  1'b1;  // wbk_en     
    wr_dat[51]      =  1'b0;  // mm_chn     
    wr_dat[50]      =  1'b1;  // bypass     
    wr_dat[49:48]   =  2'b00; // dsc_sz, 8bytes     
    wr_dat[47:44]   =  4'h1;  // rng_sz     
    wr_dat[43:41]   =  3'h0;  // reserved
    wr_dat[40:37]   =  4'h0;  // fetch_max
    wr_dat[36]      =  1'b0;  // atc
    wr_dat[35]      =  1'b0;  // wbi_intvl_en
    wr_dat[34]      =  1'b1;  // wbi_chk    
    wr_dat[33]      =  1'b1;  // fcrd_en    
    wr_dat[32]      =  1'b1;  // qen        
    wr_dat[31:25]   =  7'h0;  // reserved
    wr_dat[24:17]   =  7'd0; // func_id        
    wr_dat[16]      =  1'b0;  // irq_arm    
    wr_dat[15:0]    =  16'b0; // pidx

   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h804, wr_dat[31 :0], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h808, wr_dat[63 :32], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h80C, wr_dat[95 :64], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h810, wr_dat[127:96], 4'hF);
   
   
   //-------------- Ind Dire CTXT CMD 0x844 [17:7] Qid : 0 [17:7} : CMD MDMA_CTXT_CMD_WR=1 ---------    
   // [17:7] QID : 2
   // [6:5 ] MDMA_CTXT_CMD_WR=1 : 01
   // [4:1]  MDMA_CTXT_SELC_DSC_SW_C2H = 0 : 0000
   // 0      BUSY : 0 
   //        00000000001_01_0000_0 : 1010_0000 : 0xA0
   wr_dat = {14'h0,axi_st_q[10:0],7'b0100000};
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h844, wr_dat[31:0], 4'hF);
    
    
   //-------------- Completion  CTXT DATA -------------------
   $display ("[%t] : Programming completion context", $realtime);
   wr_dat[0]      = 1;      // en_stat_desc = 1
   wr_dat[1]      = 0;      // en_int = 0
   wr_dat[4:2]    = 3'h1;   // trig_mode = 3'b001
   wr_dat[12:5]   = {4'h0,pfTestIteration[3:0]};   // function ID
   wr_dat[16:13]  = 4'h0;   // reserved
   wr_dat[20:17]  = 4'h0;   // countr_idx  = 4'b0000 
   wr_dat[24:21]  = 4'h0;   // timer_idx = 4'b0000  
   wr_dat[26:25]  = 2'h0;   // int_st = 2'b00       
   wr_dat[27]     = 1'h1;   // color = 1            
   wr_dat[31:28]  = 4'h0;   // size_64 = 4'h0       
   wr_dat[89:32]  = (58'h0 | CMPT_ADDR[31:6]);  // baddr_64 = [63:6]only 
   wr_dat[91:90]  = 2'h0;   // desc_size = 2'b00    
   wr_dat[107:92] = 16'h0;  // pidx 16              
   wr_dat[123:108]= 16'h0;  // Cidx 16              
   wr_dat[124]    = 1'h1;   // valid = 1            
   wr_dat[126:125]= 2'h0;   // err
   wr_dat[127]    = 'h0;    // user_trig_pend
   wr_dat[128]    = 'h0;    // timer_running
   wr_dat[129]    = 'h0;    // full_upd
   wr_dat[130]    = 'h0;    // ovf_chk_dis
   wr_dat[131]    = 'h0;    // at
   wr_dat[142:132]= 'd4;   // vec MSI-X Vector
   wr_dat[143]     = 'd0;   // int_aggr
   wr_dat[144]     = 'h0;   // dis_intr_on_vf
   wr_dat[145]     = 'h0;   // vio
   wr_dat[146]     = 'h1;   // dir_c2h ; 1 = C2H, 0 = H2C direction
   wr_dat[150:147] = 'h0;   // reserved
   wr_dat[173:151] = 'h0;   // reserved
   wr_dat[174]     = 'h0;   // reserved
   wr_dat[178:175] = 'h0 | CMPT_ADDR[5:2];   // reserved
   wr_dat[179]     = 'h0 ;  // sh_cmpt 
   wr_dat[255:180] = 'h0;   // reserved

   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h804, wr_dat[31:0], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h808, wr_dat[63:32], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h80C, wr_dat[95:64], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h810, wr_dat[127:96], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h814, wr_dat[159:128], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h818, wr_dat[191:160], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h81C, wr_dat[223:192], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h820, wr_dat[255:224], 4'hF);

   //-------------- Ind Dire CTXT CMD 0x844 [17:7] Qid : 0 [17:7} : CMD MDMA_CTXT_CMD_WR=1 ---------    
   // [17:7] QID   01
   // [6:5 ] MDMA_CTXT_CMD_WR=1 : 01
   // [4:1]  MDMA_CTXT_SELC_CMPT = 6 : 0110
   // 0      BUSY : 0 
   //        00000000001_01_0110_0 : 1010_1100 : 0xAC
   wr_dat = {14'h0,axi_st_q[10:0],7'b0101100};
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h844, wr_dat[31:0], 4'hF);
   
   //Also update CIDX 0x00 for CMPT context 
   $display ("[%t] : Updating CIDX for CMPT context", $realtime);
   wr_dat[31:29] = 4'h0;   // reserver = 0
   wr_dat[28]    = 4'h0;   // irq_en_wrb = 0
   wr_dat[27]    = 1'b1;   // en_stat_desc = 1
   wr_dat[26:24] = 3'h1;   // trig_mode = 3'001 (every)
   wr_dat[23:20] = 4'h0;   // timer_idx = 4'h0
   wr_dat[19:16] = 4'h0;   // counter_idx = 4'h0
   wr_dat[15:0]  = 16'h0;  //sw_cidx = 16'h0000

   wr_add = QUEUE_PTR_PF_ADDR + (axi_st_q* 16) + 12;  // 32'h0000641C
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(wr_add[31:0], wr_dat[31:0], 4'hF);
   
    
   //-------------- PreFetch CTXT DATA -------------------
   $display ("[%t] : Programming prefetch context", $realtime);
   wr_dat[0]      = 1'b1;  // bypass
   wr_dat[4:1]    = 4'h0;  // buf_size_idx
   wr_dat[7 :5]   = 3'h0;  // port_id
   wr_dat[8]      = 1'h0;  // var_desc. set to 0.
   wr_dat[9]      = 1'h0;  // virtio 
   wr_dat[15:10]  = 5'h0;  // num_pfch
   wr_dat[21:16]  = 5'h0;  // pfch_need
   wr_dat[25:22]  = 4'h0;  // reserverd
   wr_dat[26]     = 1'h0;  // error
   wr_dat[27]     = 1'h0;  // prefetch enable
   wr_dat[28]     = 1'b0;  // prefetch (Q is in prefetch)
   wr_dat[44 :29] = 16'h0; // sw_crdt
   wr_dat[45]     = 1'b1;  // valid
   wr_dat[245:46] = 'h0;

   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h804, wr_dat[31:0], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h808, wr_dat[63:32], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h80C, wr_dat[95:64], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h810, wr_dat[127:96], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h814, wr_dat[159:128], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h818, wr_dat[191:160], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h81C, wr_dat[223:192], 4'hF);
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h820, wr_dat[255:224], 4'hF);
      
    
   //-------------- Ind Dire CTXT CMD 0x844 [17:7] Qid : 0 [17:7} : CMD MDMA_CTXT_CMD_WR=1 ---------    
   // [17:7] QID   01
   // [6:5 ] MDMA_CTXT_CMD_WR=1 : 01
   // [4:1]  MDMA_CTXT_SELC_PFTCH = 7 : 0111
   // 0      BUSY : 0 
   //        00000000001_01_0111_0 : 1010_1110 : 0xAE
   wr_dat = {14'h0,axi_st_q[10:0],7'b0101110};
   board.RP.tx_usrapp.TSK_XDMA_REG_WRITE(16'h844, wr_dat[31:0], 4'hF);
    
    
    $display("ENGINE PROGRAMMING OVER. BEGINNING BRING-UP TEST");
    
    // Spinning on counter to be 1
    $display("Spinning on step counter to be 1");
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    while(board.RP.tx_usrapp.P_READ_DATA != 1) begin
        board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    end
    #50000;
    

    
    // Setting up buffers
    $display("Storing translated address and buffer");                           
                     
    // Store Address for Address Translate Completion 
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[0] = 8'hEF;                          
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[1] = 8'hBE; 
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[2] = 8'h00;                                                                   
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[3] = 8'h00;                                                                   
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[4] = 8'h00;                                                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[5] = 8'h00;                                         
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[6] = 8'h00;  // bit 3 = size of tranlation = 4096 byte range
                                                      // bit 4 = Non-snooped accesses   If this field is 1b, 
                                                      // then the read and write requests that use
                                                      // this translation must Clear the No Snoop bit in the Attribute field. 
                                                      // If it is 0b, then the Function may use other means to determine if No Snoop should be Set.                                         
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[7] = 8'h01;  // bit 2 = Untranslated access only  
                                                      // bit 1 = Write  requets are supported
                                                      // bit 0 = read request are supported
                                                      // bits 1:0 = 00 Neither are supported
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[8] = 8'h00;
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[9] = 8'h00;
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[10] = 8'h00;
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[11] = 8'h00;
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[12] = 8'h00;
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[13] = 8'h00;
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[14] = 8'h00;
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[15] = 8'h00;
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[16] = 8'h00;
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[17] = 8'h00;
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[18] = 8'h00;
    board.RP.tx_usrapp.TRNSLD_ADDR_STORE[19] = 8'h00;

                  
  
    // Save translated address read data for translated address read 
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF]     = 8'hFE;                                                                                                
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 1] = 8'hCA;                                                                    
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 2] = 8'hFE;                                                                    
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 3] = 8'hCA;                                                                           
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 4] = 8'hFE;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 5] = 8'hCA;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 6] = 8'hFE;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 7] = 8'hCA;
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 8] = 8'hFE;                                                                                                
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 9] = 8'hCA;                                                                    
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 10] = 8'hFE;                                                                    
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 11] = 8'hCA;                                                                           
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 12] = 8'hFE;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 13] = 8'hCA;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 14] = 8'hFE;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 15] = 8'hCA;
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 16] = 8'hFE;                                                                                                
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 17] = 8'hCA;                                                                    
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 18] = 8'hFE;                                                                    
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 19] = 8'hCA;                                                                           
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 20] = 8'hFE;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 21] = 8'hCA;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 22] = 8'hFE;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 23] = 8'hCA;
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 24] = 8'hFE;                                                                                                
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 25] = 8'hCA;                                                                    
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 26] = 8'hFE;                                                                    
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 27] = 8'hCA;                                                                           
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 28] = 8'hFE;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 29] = 8'hCA;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 30] = 8'hFE;                                          
    board.RP.tx_usrapp.TRNSLD_ADDR_DATA_STORE[16'hBEEF + 31] = 8'hCA;


    // Writing VA to CSR and incrementing step counter
    $display ("Notifying EP to send address translate request");
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000000, 32'h00000000, 4'hF);
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000004, 32'h00000000, 4'hF);
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000008, 32'h00000002, 4'hF);
    
    // Spinning on counter to be 3
    $display("Spinning on step counter to be 3");
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    while(board.RP.tx_usrapp.P_READ_DATA != 3) begin
        board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    end
    #50000;
    
    $display ("Translated addresses");
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h0000000C);
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000010);
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000008, 32'h00000004, 4'hF);
    #50000;
    
    // Spinning on counter to be 5
    $display("Spinning on step counter to be 5");
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    while(board.RP.tx_usrapp.P_READ_DATA != 5) begin
        board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    end
    #50000;
    
    $display ("Buffer data on card");
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000014);
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000018);
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000008, 32'h00000006, 4'hF);
 
    // Will monitor RP cq bus and print valid info.
    $display("Waiting on RP cq data");
    board.RP.tx_usrapp.COMPARE_DATA_C2H_ADDR_TRNSLD;
 
    $display("Spinning on step counter to be 7");
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    while(board.RP.tx_usrapp.P_READ_DATA != 7) begin
        board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    end
   
    
    
    $display ("H2C Buffer Data on Card");
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h0000001C);
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000020);
    
 // skip takes too long in vivado sim 
 /*
 $display("Issuing First C2H write test 256 byte write");
    // VA Hi  = 00
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000000, 32'h00000000, 4'hF);
    // VA lo = 00
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000004, 32'h00000000, 4'hF);
    // AT_MODE = 0  (untranslated)
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000024, 32'h00000000, 4'hF);
    // LEN - bytes 0x100 = 256 bytes
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000028, 32'h00001000, 4'hF);
    //ATS _MODE  = 8 C2H write with Completion
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000008, 32'h00000008, 4'hF);
    
    $display("Spinning on step counter to be not 8");
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    while(board.RP.tx_usrapp.P_READ_DATA == 8) begin
        board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    end
    */
   
 $display("Issuing C2H write test 33 bytes");
    // VA Hi  = 00
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000000, 32'h00000000, 4'hF);
    // VA lo = 00
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000004, 32'h00000000, 4'hF);
    // AT_MODE = 0  (untranslated)
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000024, 32'h00000000, 4'hF);
    // LEN - bytes 0x21 = 33 bytes
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000028, 32'h00000021, 4'hF);
    //ATS _MODE  = 8 C2H write with Completion
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h00000008, 32'h00000008, 4'hF);
    
    $display("Spinning on step counter to be not 8");
    board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    while(board.RP.tx_usrapp.P_READ_DATA == 8) begin
        board.RP.tx_usrapp.TSK_USR_BAR_REG_READ(32'h00000008);
    end 
 
    #50000;   
        
    
    $display ("No More tasked to run, Done :)\n");
    $finish;
end

else if(testname == "qdma_h2c_lp_c2h_imm_test0")
begin
   board.RP.tx_usrapp.TSK_QDMA_H2C_LP_C2H_IMM_TEST(1);
   #1000;
   board.RP.tx_usrapp.pfTestIteration = board.RP.tx_usrapp.pfTestIteration + 1;
    if (board.RP.tx_usrapp.test_state == 1 )
     $display ("ERROR: TEST FAILED \n");
   #1000;
   $finish;
end

else if(testname == "qdma_mm_st_dsc_byp_test0")
begin
   board.RP.tx_usrapp.TSK_QDMA_MM_TEST(1, 0);
   board.RP.tx_usrapp.TSK_QDMA_ST_TEST(1);
   #1000;
   board.RP.tx_usrapp.pfTestIteration = board.RP.tx_usrapp.pfTestIteration + 1;
    if (board.RP.tx_usrapp.test_state == 1 )
     $display ("ERROR: TEST FAILED \n");
   #1000;
   $finish;
end
else if(testname =="qdma_mm_user_reset_test0")
begin
   board.RP.tx_usrapp.TSK_QDMA_MM_TEST(0, 0);
    #1000;
    board.RP.tx_usrapp.TSK_USR_BAR_REG_WRITE(32'h98, 32'h640001, 4'hF);
    #30000000  
    board.RP.tx_usrapp.TSK_QDMA_MM_TEST(0, 0);
     if (board.RP.tx_usrapp.test_state == 1 )
     $display ("ERROR: TEST FAILED \n");

   $finish;
end



else if(testname == "sample_smoke_test0")
begin


    TSK_SIMULATION_TIMEOUT(5050);

    //System Initialization
    TSK_SYSTEM_INITIALIZATION;




    
    $display("[%t] : Expected Device/Vendor ID = %x", $realtime, DEV_VEN_ID); 
    
    //--------------------------------------------------------------------------
    // Read core configuration space via PCIe fabric interface
    //--------------------------------------------------------------------------

    $display("[%t] : Reading from PCI/PCI-Express Configuration Register 0x00", $realtime);

    TSK_TX_TYPE0_CONFIGURATION_READ(DEFAULT_TAG, 12'h0, 4'hF);
    TSK_WAIT_FOR_READ_DATA;
    if  (P_READ_DATA != DEV_VEN_ID) begin
        $display("ERROR: [%t] : TEST FAILED --- Data Error Mismatch, Write Data %x != Read Data %x", $realtime, 
                                    DEV_VEN_ID, P_READ_DATA);
    end
    else begin
        $display("[%t] : TEST PASSED --- Device/Vendor ID %x successfully received", $realtime, P_READ_DATA);
        $display("[%t] : Test Completed Successfully",$realtime);
    end

    //--------------------------------------------------------------------------
    // Direct Root Port to allow upstream traffic by enabling Mem, I/O and
    // BusMstr in the command register
    //--------------------------------------------------------------------------

    board.RP.cfg_usrapp.TSK_READ_CFG_DW(32'h00000001);
    board.RP.cfg_usrapp.TSK_WRITE_CFG_DW(32'h00000001, 32'h00000007, 4'b0001);
    board.RP.cfg_usrapp.TSK_READ_CFG_DW(32'h00000001);
    
     if (board.RP.tx_usrapp.test_state == 1 )
     $display ("ERROR: TEST FAILED \n");

  $finish;
end


else if(testname == "sample_smoke_test1")
begin

    // This test use tlp expectation tasks.

    TSK_SIMULATION_TIMEOUT(5050);

    // System Initialization
    TSK_SYSTEM_INITIALIZATION;
    // Program BARs (Required so Completer ID at the Endpoint is updated)
    TSK_BAR_INIT;

fork
  begin
    //--------------------------------------------------------------------------
    // Read core configuration space via PCIe fabric interface
    //--------------------------------------------------------------------------

    $display("[%t] : Reading from PCI/PCI-Express Configuration Register 0x00", $realtime);

    TSK_TX_TYPE0_CONFIGURATION_READ(DEFAULT_TAG, 12'h0, 4'hF);
    DEFAULT_TAG = DEFAULT_TAG + 1;
    TSK_TX_CLK_EAT(100);
  end
    //---------------------------------------------------------------------------
    // List Rx TLP expections
    //---------------------------------------------------------------------------
  begin
    test_vars[0] = 0;                                                                                                                         
                                          
    $display("[%t] : Expected Device/Vendor ID = %x", $realtime, DEV_VEN_ID);                                              

    expect_cpld_payload[0] = DEV_VEN_ID[31:24];
    expect_cpld_payload[1] = DEV_VEN_ID[23:16];
    expect_cpld_payload[2] = DEV_VEN_ID[15:8];
    expect_cpld_payload[3] = DEV_VEN_ID[7:0];
    @(posedge pcie_rq_tag_vld);
    exp_tag = pcie_rq_tag;

    board.RP.com_usrapp.TSK_EXPECT_CPLD(
      3'h0, //traffic_class;
      1'b0, //td;
      1'b0, //ep;
      2'h0, //attr;
      10'h1, //length;
      board.RP.tx_usrapp.EP_BUS_DEV_FNS, //completer_id;
      3'h0, //completion_status;
      1'b0, //bcm;
      12'h4, //byte_count;
      board.RP.tx_usrapp.RP_BUS_DEV_FNS, //requester_id;
      exp_tag ,
      7'b0, //address_low;
      expect_status //expect_status;
    );

    if (expect_status) 
      test_vars[0] = test_vars[0] + 1;      
  end
join
  
  expect_finish_check = 1;

  if (test_vars[0] == 1) begin
    $display("[%t] : TEST PASSED --- Finished transmission of PCI-Express TLPs", $realtime);
    $display("[%t] : Test Completed Successfully",$realtime);
  end else begin
    $display("ERROR: [%t] : TEST FAILED --- Haven't Received All Expected TLPs", $realtime);

    //--------------------------------------------------------------------------
    // Direct Root Port to allow upstream traffic by enabling Mem, I/O and
    // BusMstr in the command register
    //--------------------------------------------------------------------------

    board.RP.cfg_usrapp.TSK_READ_CFG_DW(32'h00000001);
    board.RP.cfg_usrapp.TSK_WRITE_CFG_DW(32'h00000001, 32'h00000007, 4'b0001);
    board.RP.cfg_usrapp.TSK_READ_CFG_DW(32'h00000001);

  end

  $finish;
end

else if(testname == "pio_writeReadBack_test0")
begin

    // This test performs a 32 bit write to a 32 bit Memory space and performs a read back

    board.RP.tx_usrapp.TSK_SIMULATION_TIMEOUT(10050);

    board.RP.tx_usrapp.TSK_SYSTEM_INITIALIZATION;

    board.RP.tx_usrapp.TSK_BAR_INIT;

//--------------------------------------------------------------------------
// Event : Testing BARs
//--------------------------------------------------------------------------

        for (board.RP.tx_usrapp.ii = 0; board.RP.tx_usrapp.ii <= 6; board.RP.tx_usrapp.ii =
            board.RP.tx_usrapp.ii + 1) begin
            if ((board.RP.tx_usrapp.BAR_INIT_P_BAR_ENABLED[board.RP.tx_usrapp.ii] > 2'b00)) // bar is enabled
               case(board.RP.tx_usrapp.BAR_INIT_P_BAR_ENABLED[board.RP.tx_usrapp.ii])
                   2'b01 : // IO SPACE
                        begin

                          $display("[%t] : Transmitting TLPs to IO Space BAR %x", $realtime, board.RP.tx_usrapp.ii);

                          //--------------------------------------------------------------------------
                          // Event : IO Write bit TLP
                          //--------------------------------------------------------------------------



                          board.RP.tx_usrapp.TSK_TX_IO_WRITE(board.RP.tx_usrapp.DEFAULT_TAG,
                             board.RP.tx_usrapp.BAR_INIT_P_BAR[board.RP.tx_usrapp.ii][31:0], 4'hF, 32'hdead_beef);
                             @(posedge pcie_rq_tag_vld);
                             exp_tag = pcie_rq_tag;


                          board.RP.com_usrapp.TSK_EXPECT_CPL(3'h0, 1'b0, 1'b0, 2'b0,
                             board.RP.tx_usrapp.EP_BUS_DEV_FNS, 3'h0, 1'b0, 12'h4,
                             board.RP.tx_usrapp.RP_BUS_DEV_FNS, exp_tag,
                             board.RP.tx_usrapp.BAR_INIT_P_BAR[board.RP.tx_usrapp.ii][31:0], test_vars[0]);

                          board.RP.tx_usrapp.TSK_TX_CLK_EAT(10);
                          board.RP.tx_usrapp.DEFAULT_TAG = board.RP.tx_usrapp.DEFAULT_TAG + 1;

                          //--------------------------------------------------------------------------
                          // Event : IO Read bit TLP
                          //--------------------------------------------------------------------------


                          // make sure P_READ_DATA has known initial value
                          board.RP.tx_usrapp.P_READ_DATA = 32'hffff_ffff;
                          fork
                             board.RP.tx_usrapp.TSK_TX_IO_READ(board.RP.tx_usrapp.DEFAULT_TAG,
                                board.RP.tx_usrapp.BAR_INIT_P_BAR[board.RP.tx_usrapp.ii][31:0], 4'hF);
                             board.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;
                          join
                          if  (board.RP.tx_usrapp.P_READ_DATA != 32'hdead_beef)
                             begin
			       testError=1'b1;
                               $display("ERROR:  [%t] : Test FAILED --- Data Error Mismatch, Write Data %x != Read Data %x",
                                   $realtime, 32'hdead_beef, board.RP.tx_usrapp.P_READ_DATA);
                             end
                          else
                             begin
                               $display("[%t] : Test PASSED --- Write Data: %x successfully received",
                                   $realtime, board.RP.tx_usrapp.P_READ_DATA);
                             end


                          board.RP.tx_usrapp.TSK_TX_CLK_EAT(10);
                          board.RP.tx_usrapp.DEFAULT_TAG = board.RP.tx_usrapp.DEFAULT_TAG + 1;


                        end

                   2'b10 : // MEM 32 SPACE
                        begin


                          $display("[%t] : Transmitting TLPs to Memory 32 Space BAR %x", $realtime,
                              board.RP.tx_usrapp.ii);

                          //--------------------------------------------------------------------------
                          // Event : Memory Write 32 bit TLP
                          //--------------------------------------------------------------------------

                          board.RP.tx_usrapp.DATA_STORE[0] = 8'h04;
                          board.RP.tx_usrapp.DATA_STORE[1] = 8'h03;
                          board.RP.tx_usrapp.DATA_STORE[2] = 8'h02;
                          board.RP.tx_usrapp.DATA_STORE[3] = 8'h01;

                          board.RP.tx_usrapp.TSK_TX_MEMORY_WRITE_32(board.RP.tx_usrapp.DEFAULT_TAG,
                              board.RP.tx_usrapp.DEFAULT_TC, 11'd1,
                              board.RP.tx_usrapp.BAR_INIT_P_BAR[board.RP.tx_usrapp.ii][31:0]+8'h10, 4'h0, 4'hF, 1'b0);
                          board.RP.tx_usrapp.TSK_TX_CLK_EAT(100);
                          board.RP.tx_usrapp.DEFAULT_TAG = board.RP.tx_usrapp.DEFAULT_TAG + 1;

                          //--------------------------------------------------------------------------
                          // Event : Memory Read 32 bit TLP
                          //--------------------------------------------------------------------------


                         // make sure P_READ_DATA has known initial value
                         board.RP.tx_usrapp.P_READ_DATA = 32'hffff_ffff;
                          fork
                             board.RP.tx_usrapp.TSK_TX_MEMORY_READ_32(board.RP.tx_usrapp.DEFAULT_TAG,
                                 board.RP.tx_usrapp.DEFAULT_TC, 11'd1,
                                 board.RP.tx_usrapp.BAR_INIT_P_BAR[board.RP.tx_usrapp.ii][31:0]+8'h10, 4'h0, 4'hF);
                             board.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;
                          join
                          if  (board.RP.tx_usrapp.P_READ_DATA != {board.RP.tx_usrapp.DATA_STORE[3],
                             board.RP.tx_usrapp.DATA_STORE[2], board.RP.tx_usrapp.DATA_STORE[1],
                             board.RP.tx_usrapp.DATA_STORE[0] })
                             begin
			       testError=1'b1;
                               $display("ERROR: [%t] : Test FAILED --- Data Error Mismatch, Write Data %x != Read Data %x",
                                    $realtime, {board.RP.tx_usrapp.DATA_STORE[3],board.RP.tx_usrapp.DATA_STORE[2],
                                     board.RP.tx_usrapp.DATA_STORE[1],board.RP.tx_usrapp.DATA_STORE[0]},
                                     board.RP.tx_usrapp.P_READ_DATA);

                             end
                          else
                             begin
                               $display("[%t] : Test PASSED --- Write Data: %x successfully received",
                                   $realtime, board.RP.tx_usrapp.P_READ_DATA);
                             end


                          board.RP.tx_usrapp.TSK_TX_CLK_EAT(10);
                          board.RP.tx_usrapp.DEFAULT_TAG = board.RP.tx_usrapp.DEFAULT_TAG + 1;

                     end
                2'b11 : // MEM 64 SPACE
                     begin


                          $display("[%t] : Transmitting TLPs to Memory 64 Space BAR %x", $realtime,
                              board.RP.tx_usrapp.ii);


                          //--------------------------------------------------------------------------
                          // Event : Memory Write 64 bit TLP
                          //--------------------------------------------------------------------------

                          board.RP.tx_usrapp.DATA_STORE[0] = 8'h64;
                          board.RP.tx_usrapp.DATA_STORE[1] = 8'h63;
                          board.RP.tx_usrapp.DATA_STORE[2] = 8'h62;
                          board.RP.tx_usrapp.DATA_STORE[3] = 8'h61;

                          board.RP.tx_usrapp.TSK_TX_MEMORY_WRITE_64(board.RP.tx_usrapp.DEFAULT_TAG,
                              board.RP.tx_usrapp.DEFAULT_TC, 10'd1,
                              {board.RP.tx_usrapp.BAR_INIT_P_BAR[board.RP.tx_usrapp.ii+1][31:0],
                              board.RP.tx_usrapp.BAR_INIT_P_BAR[board.RP.tx_usrapp.ii][31:0]+8'h20}, 4'h0, 4'hF, 1'b0);
                          board.RP.tx_usrapp.TSK_TX_CLK_EAT(10);
                          board.RP.tx_usrapp.DEFAULT_TAG = board.RP.tx_usrapp.DEFAULT_TAG + 1;

                          //--------------------------------------------------------------------------
                          // Event : Memory Read 64 bit TLP
                          //--------------------------------------------------------------------------


                          // make sure P_READ_DATA has known initial value
                          board.RP.tx_usrapp.P_READ_DATA = 32'hffff_ffff;
                          fork
                             board.RP.tx_usrapp.TSK_TX_MEMORY_READ_64(board.RP.tx_usrapp.DEFAULT_TAG,
                                 board.RP.tx_usrapp.DEFAULT_TC, 10'd1,
                                 {board.RP.tx_usrapp.BAR_INIT_P_BAR[board.RP.tx_usrapp.ii+1][31:0],
                                 board.RP.tx_usrapp.BAR_INIT_P_BAR[board.RP.tx_usrapp.ii][31:0]+8'h20}, 4'h0, 4'hF);
                             board.RP.tx_usrapp.TSK_WAIT_FOR_READ_DATA;
                          join
                          if  (board.RP.tx_usrapp.P_READ_DATA != {board.RP.tx_usrapp.DATA_STORE[3],
                             board.RP.tx_usrapp.DATA_STORE[2], board.RP.tx_usrapp.DATA_STORE[1],
                             board.RP.tx_usrapp.DATA_STORE[0] })

                             begin
			       testError=1'b1;
                               $display("ERROR: [%t] : Test FAILED --- Data Error Mismatch, Write Data %x != Read Data %x",
                                   $realtime, {board.RP.tx_usrapp.DATA_STORE[3],
                                   board.RP.tx_usrapp.DATA_STORE[2], board.RP.tx_usrapp.DATA_STORE[1],
                                   board.RP.tx_usrapp.DATA_STORE[0]}, board.RP.tx_usrapp.P_READ_DATA);

                             end
                          else
                             begin
                               $display("[%t] : Test PASSED --- Write Data: %x successfully received",
                                   $realtime, board.RP.tx_usrapp.P_READ_DATA);
                             end


                          board.RP.tx_usrapp.TSK_TX_CLK_EAT(10);
                          board.RP.tx_usrapp.DEFAULT_TAG = board.RP.tx_usrapp.DEFAULT_TAG + 1;


                     end
                default : $display("Error case in usrapp_tx\n");
            endcase

         end
    if(testError==1'b0)
      $display("[%t] : Test Completed Successfully",$realtime);

    $display("[%t] : Finished transmission of PCI-Express TLPs", $realtime);
    $finish;
end
