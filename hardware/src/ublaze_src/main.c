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

#include <stdlib.h>
#include "xparameters.h"
#include "xio.h"
#include "xuartlite.h"
#include "xil_printf.h"
#include "components.h"


// Move all the structs up here, don't malloc them, just make them regular variables

struct m_axis_h2c 		data_from_host;
struct h2c_byp_in 	h2c_desc;
struct csr 				csr_data;
struct in_msg 			in_msg_data;
struct c2h_byp_in	c2h_desc;
struct s_axis_c2h		c2h_data;
struct s_axis_c2h_cmpt	c2h_cmpt;

int main(void) {


  u32 step_counter = 0;
  u32 num_invalidates_received = 0;
  u32 num_outstanding_descriptors = 0;
  u32 print_state = 1;
  int num_cycles = 0;

  write_csr(VERSION, 0x00010000); // 1.0.0;

  initialize_c2h_structs(&c2h_cmpt, &c2h_desc, &c2h_data);
  initialize_h2c_desc(&h2c_desc);

#ifdef DEBUG
  xil_printf("Elf compiled on %s at %s. Starting...\r\n", __DATE__, __TIME__);
#else
  xil_printf("1");
#endif

  while(1) {

    // Check if we have any messages. If so send completion immediately
    if(probe_and_read_msg_fifo(&in_msg_data)) {
      if(check_invalidate(&in_msg_data)) {
#ifdef USE_TIMER
	start_timer();
	send_invl_completion(&in_msg_data);
	num_cycles = end_timer();
	xil_printf("Inv: %d\r\n", num_cycles);
#else
	send_invl_completion(&in_msg_data);
#endif

#ifdef DEBUG
	xil_printf("Compl\r\n");
#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
	xil_printf("!");
#endif
	// When we receive 2 invalidates, set the step_counter to 1
	num_invalidates_received++;
	if(num_invalidates_received >= 2) {
	  write_csr_step_counter(1);
	}
      }
#ifdef DEBUG
      xil_printf("Msg received. Info:\r\n");
      print_msg(&in_msg_data);
#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
      xil_printf(".");
#endif
    }


    // Check what step we are currently on
    step_counter = read_csr_step_counter();
    if(step_counter < 2) {
      continue;
    }
    else if(step_counter == 2) {

      if (print_state == 1) {
#ifdef DEBUG
	xil_printf("\r\n### 2: ADDRESS TRANSLATION REQUEST Info:\r\n");
	print_csr(&csr_data);
#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
	xil_printf("2");
#endif
	print_state = 0;
      }

      if(num_outstanding_descriptors == 0) {
	read_csr_virtual_address_csr(&csr_data);
	h2c_desc.raddr[1] = csr_data.host_virt_addr[1];
	h2c_desc.raddr[0] = csr_data.host_virt_addr[0];
	h2c_desc.at = 1;
	h2c_desc.len = read_csr_len();

#ifdef DEBUG
	xil_printf("Sending ATS descriptor. Info: \r\n");
	print_h2c_desc(&h2c_desc);
#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
	xil_printf("+");
#endif
	write_h2c_byp_in(&h2c_desc);
	num_outstanding_descriptors++;
      }
      else if(m_axis_h2c_has_data()) {
#ifdef DEBUG
	xil_printf("There is a translated address response\r\n");
#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
	xil_printf("-");
#endif
	u32 *pa_hi = (u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + HOST_PHYS_ADDR_1_OFFSET);
	u32 *pa_lo = (u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + HOST_PHYS_ADDR_0_OFFSET);
	if (read_at_from_m_axis_h2c(pa_hi, pa_lo)) {
	  // Cool!  No error!
#ifdef DEBUG
	  xil_printf("PA is 0x%08X_%08X\r\n", *pa_hi, *pa_lo);
#endif
	  
#if !defined(DEBUG) && !defined(USE_TIMER)
	  xil_printf("A");
#endif
	}
	  
	else {
#ifdef DEBUG
	  xil_printf("Address translation request returned an error\r\n"); // Sorry!  We could print more info here I guess
#endif
	  
#if !defined(DEBUG) && !defined(USE_TIMER)
	  xil_printf("a");
#endif
	  
	}
	pop_m_axis_h2c_fifo();
	  
	write_csr_step_counter(3);
	num_outstanding_descriptors--;
      }
      else {
	continue;
      }
    }
    else if(step_counter == 3) {
      continue;
    }
    else if(step_counter == 4) {
      if (print_state == 1) {
#ifdef DEBUG
	xil_printf("\r\n### 4: READ. Info:\r\n");
	print_csr(&csr_data);
#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
	xil_printf("4");
#endif
	print_state = 0;
      }
      if(num_outstanding_descriptors == 0) {
	read_csr_virtual_address_csr(&csr_data);
	h2c_desc.raddr[1] = csr_data.host_virt_addr[1];
	h2c_desc.raddr[0] = csr_data.host_virt_addr[0];
	h2c_desc.at = read_csr_at_mode();
	h2c_desc.len = read_csr_len();

#ifdef DEBUG
	xil_printf("Sending read descriptor. Info: \r\n");
	print_h2c_desc(&h2c_desc);
#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
	xil_printf("x");
#endif
	write_h2c_byp_in(&h2c_desc);
	num_outstanding_descriptors++;
      }
      else if(probe_and_read_m_axis_h2c(&data_from_host))
	{
#ifdef DEBUG
	  xil_printf("Received H2C streaming data. Info: \r\n");
	  print_h2c_data(&data_from_host);
#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
	  xil_printf("/");
#endif
	  csr_data.host_buff_data[1] = data_from_host.tdata[7];
	  csr_data.host_buff_data[0] = data_from_host.tdata[6];
	  write_csr_buff_data(&csr_data);
	  write_csr_step_counter(5);
	  num_outstanding_descriptors--;
	}
    }
    else if(step_counter == 5) {
      print_state = 1;
      continue;
    }
    else if(step_counter == 6) {
      print_state = 1;

#ifdef DEBUG
      xil_printf("\r\n### 6: WRITE. Info:\r\n");
      print_csr(&csr_data);
#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
      xil_printf("6");
#endif
      initialize_c2h_structs(&c2h_cmpt, &c2h_desc, &c2h_data);

      read_csr_virtual_address_csr(&csr_data);

      // Yes, this is correct.  The addressing on waddr does not match how our registers are written
      c2h_desc.waddr[0] = csr_data.host_virt_addr[1];
      c2h_desc.waddr[1] = csr_data.host_virt_addr[0];
      c2h_desc.raddr[1] = 0x00000000; // Unused
      c2h_desc.raddr[0] = 0x00000500; // Unused
      c2h_desc.at = read_csr_at_mode();

#ifdef MM_ENABLE
      c2h_desc->mm_or_st = 1;
      write_c2h_byp_in(c2h_desc);
#else
      c2h_desc.mm_or_st = 0;

      //c2h_desc->len = 8;
      c2h_data.len = read_csr_len();

      // The assumption for this function is that we only need one FIFO pop
      // so tlast is set, and we need to set the mty correctly
      c2h_data.tlast = 1;
      c2h_data.mty = (32-(c2h_data.len % (8*4))) & 0x1f;

      // These are in bytes.  Lets see how many words we need ...
      unsigned write_len_dwords = c2h_data.len / 4;
      if (c2h_data.len % 4) write_len_dwords++;
      for (int d=0;d<write_len_dwords;d++)
	c2h_data.data[d] = read_csr_c2h_data(d);

      write_c2h_byp_in(&c2h_desc);
      write_c2h_data(&c2h_data);
#endif

#ifdef DEBUG
      xil_printf("I was asked to read %d data CSRs\r\n",write_len_dwords);
      xil_printf("This is the c2h descriptor\r\n");
      print_c2h_desc(&c2h_desc);
      xil_printf("This is the c2h data\r\n");
      print_c2h_data(&c2h_data);

#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
      xil_printf("6");
#endif
      for (int k=0;k<8;k++)
	csr_data.c2h_host_buff_data[k] = c2h_data.data[k];

      write_csr_c2h_buff_data(&csr_data);
#ifdef C2H_COMPLETION
      write_c2h_cmpt(&c2h_cmpt);
#endif

      write_csr_step_counter(7);
    }
    else if(step_counter == 8) {
      print_state = 1;
#ifdef DEBUG
      xil_printf("\r\n### 8: PATTERN WRITE. Info:\r\n");
#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
      xil_printf("8");
#endif

      read_csr_virtual_address_csr(&csr_data);

      // Yes, this is correct.  The addressing on waddr does not match how our registers are written
      c2h_desc.waddr[0] = csr_data.host_virt_addr[1];
      c2h_desc.waddr[1] = csr_data.host_virt_addr[0];
      c2h_desc.raddr[1] = 0x00000000; // Unused
      c2h_desc.raddr[0] = 0x00000500; // Unused
      c2h_desc.at = read_csr_at_mode();

#ifdef MM_ENABLE
      c2h_desc->mm_or_st = 1;
      write_c2h_byp_in(c2h_desc);
#else
      c2h_desc.mm_or_st = 0;
#endif

      //c2h_desc->len = 8;
      c2h_data.len = read_csr_len();
#ifdef DEBUG
      xil_printf("Asked to write a pattern of %d bytes\r\n", c2h_data.len);
#endif
      u32 phases = c2h_data.len / (8*4);
      if (c2h_data.len % (8*4))
	phases++;
#ifdef DEBUG
      xil_printf("Will send %d phases\r\n", phases);
#endif
      write_c2h_byp_in(&c2h_desc);
      for (int p=0;p<phases;p++) {
	// If its last phase, we set tlast
	// and then the mty is used to figure out the number
	// of valid bytes
	c2h_data.tlast = (p==(phases-1))?1:0;
	if (p==(phases-1))
	  c2h_data.mty = (32-(c2h_data.len % (8*4))) & 0x1f;
	else
	  c2h_data.mty = 0;

	for (int w=0;w<8;w++)
	  c2h_data.data[w] = (p*8)+w;
#ifdef DEBUG
	print_c2h_data(&c2h_data);
#endif
	write_c2h_data(&c2h_data);
      }
#ifdef C2H_COMPLETION
      write_c2h_cmpt(&c2h_cmpt);
#endif
      write_csr_step_counter(0);
    }
    else if(step_counter == 9) { 
      print_state = 1;
#ifdef DEBUG
      xil_printf("\r\n### 9: PCIe Config Space Dump\r\n");
#endif
#if !defined(DEBUG) && !defined(USE_TIMER)
      xil_printf("9");
#endif
  for(int i = 0; i < 4095; i=i+16) {
  dump_pcie_config_space(i);
  }
  write_csr_step_counter(0);
    }

  }

  return 0;

}
