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

#include "components.h"

u8 m_axis_h2c_has_data() {
  u32 data;

  // Check if FIFO is empty
  data = H2C_CSR(H2C_SHIM_FIFO_STATUS);
  if(!(data & 0x00800000)) 
    return 0;
  else
    return 1;
}

void pop_m_axis_h2c_fifo() {
  // Pop the FIFO and clearing the signal
  H2C_CSR(H2C_SHIM_FIFO_POP) = 0x00000001;
  H2C_CSR(H2C_SHIM_FIFO_POP) = 0x00000000;
}

// Only call this if you know we have data at the head of the FIFO
// Returns: 0 if the word indicates an error
// Returns: 1 on success, and the translaton address appears in pa_hi and pa_lo;
 
u8 read_at_from_m_axis_h2c(u32 *pa_hi, u32 *pa_lo) {
  u32 data = H2C_CSR(H2C_SHIM_FIFO_STATUS);
  u8 tuser_err            = (u8 )((data & 0x00000100) >> 8);
  if (tuser_err) {
    // I guess we could be more helpful here
    pop_m_axis_h2c_fifo();
    return 0;
  }
  // Okay, we have a valid address, get the swizzled address
  *pa_hi = H2C_CSR(H2C_SHIM_PA_HI);
  *pa_lo = H2C_CSR(H2C_SHIM_PA_LO);
  return 1;
}


/*
 * This function will prove the in_fifo_not_empty
 * signal to see if there is data. If there is, it
 * will read the data into the provided m_axis_h2c
 * struct. If there is no data it just returns
 */
int probe_and_read_m_axis_h2c(struct m_axis_h2c *in_struct) {

  u32 data;

  // Check if FIFO is empty
  data = *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x24);
  if(!(data & 0x00800000)) {
    return 0;
  }

  // Storing data that is in the FIFO not empty word
  in_struct->tuser_qid            = (u16 )((data & 0x007FF000) >> 12);
  in_struct->tuser_port_id        = (u8 )((data & 0x00000E00) >> 9);
  in_struct->tuser_err            = (u8 )((data & 0x00000100) >> 8);
  in_struct->tuser_mty            = (u8 )((data & 0x000000FC) >> 2);
  in_struct->tuser_zerobyte       = (u8 )((data & 0x00000002) >> 1);
  in_struct->tuser_tlast          = (u8 )(data & 0x00000001);

  for(int i = 0; i < 10; i++) {
    if(i < 8) {
      in_struct->tdata[i] = *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + i * 4);
    }
    else if(i == 9) {
      in_struct->tuser_crc = *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x20);
    }
    else {
      in_struct->tuser_mdata = *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x28);
    }
  }

  // Pop the FIFO and clearing the signal
  *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x18) = 0x00000001;
  *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x18) = 0x00000000;

  return 1;

}


void print_h2c_data(struct m_axis_h2c *in_struct) {
  for(int i = 0; i < 8; i++) {
    xil_printf("tdata[%d] = %x\r\n", i, in_struct->tdata[i]);
  }
  xil_printf("tuser_crc = %x\r\n", in_struct->tuser_crc);
  xil_printf("tuser_mdata = %x\r\n", in_struct->tuser_mdata);
  xil_printf("tuser_qid = %x\r\n", in_struct->tuser_qid);
  xil_printf("tuser_port_id = %x\r\n", in_struct->tuser_port_id);
  xil_printf("tuser_err = %x\r\n", in_struct->tuser_err);
  xil_printf("tuser_mty = %x\r\n", in_struct->tuser_mty);
  xil_printf("tuser_zerobyte = %x\r\n", in_struct->tuser_zerobyte);
  xil_printf("tuser_tlast = %x\r\n", in_struct->tuser_tlast);

}


void write_h2c_byp_in(struct h2c_byp_in *out_struct) {

  // Sending the read address
  *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR)        = out_struct->raddr[0];
  *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x04) = out_struct->raddr[1];

  // Sending the write address
  *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x08) = out_struct->waddr[0];
  *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x0C) = out_struct->waddr[1];

  // Creating 32 bit word out of struct elements and sending
  u32 dword = 0x00000000;
  dword |= (u32)out_struct->func          << 24;
  dword |= (u32)out_struct->error         << 23;
  dword |= (u32)out_struct->no_dma        << 22;
  dword |= (u32)out_struct->mrkr_req      << 21;
  dword |= (u32)out_struct->sdi           << 20;
  dword |= (u32)out_struct->eop           << 19;
  dword |= (u32)out_struct->sop           << 18;
  dword |= (u32)out_struct->at            << 16;
  dword |= (u32)out_struct->len;
  *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x10) = dword;

  // Creating 32 bit word out of struct elements and sending
  dword = 0x00000000;
  dword |= (u32)out_struct->mm_or_st		<< 30;
  dword |= (u32)out_struct->cidx          << 14;
  dword |= (u32)out_struct->port_id       << 11;
  dword |= (u32)out_struct->qid;
  *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x14) = dword;

  // Pushing the data out of the FIFO and clearing the signal
  *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x18) = 0x00000002;
  *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x18) = 0x00000000;

}

// There are a lot of values that we won't be changing, so this just initializes all values
void initialize_h2c_desc(struct h2c_byp_in *in_struct) {
  in_struct->raddr[1]  = 0xDEADBEEF;
  in_struct->raddr[0]  = 0xBEEFCAFE;
  in_struct->waddr[1]  = 0x00000000;
  in_struct->waddr[0]  = 0x00000000;
  in_struct->mm_or_st	 = 0;
  in_struct->func      = 0;
  in_struct->error     = 0;
  in_struct->no_dma    = 0;
  in_struct->mrkr_req  = 0; // Just going to assume this is 0
  in_struct->sdi       = 0;
  in_struct->eop       = 1;
  in_struct->sop       = 1;
  in_struct->at        = 0; // 0 - untranslated DMA, 1 - translation request, 2 - translated DMA
  in_struct->len       = 8;
  in_struct->cidx      = 1;
  in_struct->port_id   = 2;
  in_struct->qid       = 2;
}

// Initializing all structs for the C2H transfer
void initialize_c2h_structs(struct s_axis_c2h_cmpt *cmpt, struct c2h_byp_in *desc, struct s_axis_c2h *data) {

  // Initializing the descriptor
  desc->raddr[1] 			= 0x00000000;
  desc->raddr[0] 			= 0x00000500;
  desc->waddr[1]			= 0x00000000;
  desc->waddr[0]			= 0x00000000;
  desc->mm_cidx			= 0;
  desc->mm_len			= 0x0020;
  desc->mm_mrkr_req		= 0;
  desc->mm_no_dma			= 0;
  desc->mm_sdi			= 0;
  desc->at				= 0;
  desc->error				= 0;
  desc->func				= 0;
  desc->st_pfch_tag		= 0;
  desc->port_id			= 0;
  desc->qid				= 2;

  // Initialize the data
  data->data[7] 			= 0;
  data->data[6] 			= 0;
  data->data[5] 			= 0;
  data->data[4] 			= 0;
  data->data[3] 			= 0;
  data->data[2] 			= 0;
  data->data[1] 			= 0;
  data->data[0] 			= 0;
#ifdef C2H_COMPLETION
  data->has_cmpt			= 1; // PJR: I don't think we want completions
#else
  data -> has_cmpt                      = 0;
#endif
  data->tcrc				= 0; // TODO: Figure out if we need a correct CRC
  data->ecc				= 0; // TODO: Figure out of we need correct ecc
  data->port_id			= 0;
  data->qid				= 2;
  data->len				= 0x0020; // 32 bytes of data = 256 bits which is one beat
  data->marker			= 0;
  data->mty				= 0;
  data->tlast				= 1;

  // Writing the completion data
  cmpt->data[15]			= 0;
  cmpt->data[14]			= 0;
  cmpt->data[13]			= 0;
  cmpt->data[12]			= 0;
  cmpt->data[11]			= 0;
  cmpt->data[10]			= 0;
  cmpt->data[9]			= 0;
  cmpt->data[8]			= 0;
  cmpt->data[7]			= 0;
  cmpt->data[6]			= 0;
  cmpt->data[5]			= 0;
  cmpt->data[4]			= 0;
  cmpt->data[3]			= 0;
  cmpt->data[2]			= 0;
  cmpt->data[1]			= 0;
  cmpt->data[0]			= 0xBEEEBEEE;
  cmpt->size				= 0;
  cmpt->dpar				= 0;
  cmpt->wait_pld_pkt_id 	= 1;
  cmpt->user_trig			= 1;
  cmpt->qid				= 2;
  cmpt->port_id			= 0;
  cmpt->marker			= 0;
  cmpt->err_idx			= 0;
  cmpt->col_idx			= 0;
  cmpt->cmpt_type			= 3;
}




void print_h2c_desc(struct h2c_byp_in *in_struct) {
  xil_printf("RAddr high: %x\r\n", in_struct->raddr[1]);
  xil_printf("RAddr low: %x\r\n", in_struct->raddr[0]);
  xil_printf("WAddr high: %x\r\n", in_struct->waddr[1]);
  xil_printf("WAddr low: %x\r\n", in_struct->waddr[0]);
  xil_printf("mm_or_st: %x\r\n", in_struct->mm_or_st);
  xil_printf("Func: %x\r\n", in_struct->func);
  xil_printf("Error: %x\r\n", in_struct->error);
  xil_printf("No DMA: %x\r\n", in_struct->no_dma);
  xil_printf("Marker request: %x\r\n", in_struct->mrkr_req);
  xil_printf("sdi: %x\r\n", in_struct->sdi);
  xil_printf("eop: %x\r\n", in_struct->eop);
  xil_printf("sop: %x\r\n", in_struct->sop);
  xil_printf("at: %x\r\n", in_struct->at);
  xil_printf("len: %x\r\n", in_struct->len);
  xil_printf("cidx: %x\r\n", in_struct->cidx);
  xil_printf("port_id: %x\r\n", in_struct->port_id);
  xil_printf("qid: %x\r\n", in_struct->qid);
}


int read_csr_step_counter() {
  return *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x08);
}

int read_csr_at_mode() {
  return *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x24);
}

int read_csr_len() {
  return *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x28);
}


u32 read_csr(u32 offset) {
  return *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + offset);
}

void write_csr(u32 offset, u32 val) {
  *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + offset) = val;
}


int read_csr_c2h_data(int offset) {
  return *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + C2H_DATA_CSR + offset*4);

}

void write_csr_step_counter(u32 step_counter) {
  *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x08) = step_counter;
}


void write_csr_phys_addr(struct csr *in_struct) {
  *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x0C) = in_struct->host_phys_addr[1];
  *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x10) = in_struct->host_phys_addr[0];
}


void write_csr_buff_data(struct csr *in_struct) {
  *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x14) = in_struct->host_buff_data[1];
  *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x18) = in_struct->host_buff_data[0];
}


void write_csr_c2h_buff_data(struct csr *in_struct) {
  *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x1C) = in_struct->c2h_host_buff_data[1];
  *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x20) = in_struct->c2h_host_buff_data[0];
}


void read_csr_virtual_address_csr(struct csr *in_struct) {
  in_struct->host_virt_addr[1] = *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR);
  in_struct->host_virt_addr[0] = *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x04);

}

void print_csr(struct csr *in_struct) {
  xil_printf("host_virt_addr[1]: %x\r\n", in_struct->host_virt_addr[1]);
  xil_printf("host_virt_addr[0]: %x\r\n", in_struct->host_virt_addr[0]);
  xil_printf("host_phys_addr[1]: %x\r\n", in_struct->host_phys_addr[1]);
  xil_printf("host_phys_addr[0]: %x\r\n", in_struct->host_phys_addr[0]);
  xil_printf("host_buff_data[1]: %x\r\n", in_struct->host_buff_data[1]);
  xil_printf("host_buff_data[0]: %x\r\n", in_struct->host_buff_data[0]);
}



int probe_and_read_msg_fifo(struct in_msg *in_struct) {

  u32 dw = *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE70);

  // Return if the FIFO is empty
  if(!(dw & 0x00000001)) {
    return 0;
  }


  in_struct->fifo_overflow = (dw & 0x00000002) >> 1;

  // Don't care about the first two beats of the FIFO
  *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE74) = 0x00000000;
  *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE74) = 0x00000000;

  dw = *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE74);

  // Reading third beat and clearing from FIFO
  in_struct->dword_count = dw & 0x000007FF;
  in_struct->req_type = (dw & 0x00007800) >> 11;
  in_struct->req_id = (dw & 0xFFFF0000) >> 15;
  *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE74) = 0x00000000;

  // Reading fourth beat and clearing from FIFO
  dw = *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE74);
  in_struct->msg_code = (dw & 0x0000FF00) >> 8;
  in_struct->tag = (dw & 0x000000FF);
  in_struct->msg_routing = (dw & 0x00070000) >> 16;
  *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE74) = 0x00000000;



  // Returning invalid if not an invalidate request
  if(in_struct->msg_code == 0x00000001 && in_struct->req_type == 0x0000000E) {
    // Read the first payload beat
    dw = *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE74);
    in_struct->addr[1] = dw;
    *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE74) = 0x00000000;

    // Read the second payload beat
    dw = *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE74);
    in_struct->addr[0] = dw;
    *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE74) = 0x00000000;
  }
  else {
    // Clearing all dwords in msg payload from FIFO
    for(int i = 0; i < in_struct->dword_count; i++) {
      *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE74) = 0x00000000;
    }
  }

  // Returning FIFO is not empty
  return 1;

}


int check_invalidate(struct in_msg *in_struct) {

  if(in_struct->msg_code == 0x00000001 && in_struct->req_type == 0x0000000E) {
    return 1;
  }
  else {
    return 0;
  }
}


void print_msg(struct in_msg *in_struct) {
  xil_printf("FIFO overflow: %d\r\n", in_struct->fifo_overflow);
  xil_printf("Tag: %x\r\n", in_struct->tag);
  xil_printf("Req ID: %x\r\n", in_struct->req_id);
  xil_printf("Req Type: %x\r\n", in_struct->req_type);
  xil_printf("Msg Code: %x\r\n", in_struct->msg_code);
  xil_printf("Msg Routing: %x\r\n", in_struct->msg_routing);
  xil_printf("Dword Count: %x\r\n", in_struct->dword_count);
  xil_printf("Invld High Address: %x\r\n", in_struct->addr[1]);
  xil_printf("Invld Low Address: %x\r\n", in_struct->addr[0]);
}


void send_invl_completion(struct in_msg *in_struct) {

  // Writing the HDR_L field
  *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE64) = 0x01000000;

  // Writing the HDR H field, bytes are flipped so have to do this weird thing
  if(in_struct->tag < 8) {
    *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE68) = 0x01000000 << in_struct->tag;
  }
  else if(in_struct->tag < 16) {
    *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE68) = 0x00010000 << (in_struct->tag % 8);
  }
  else if(in_struct->tag < 24) {
    *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE68) = 0x00000100 << (in_struct->tag % 8);
  }
  else if(in_struct->tag < 32) {
    *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE68) = 0x00000001 << (in_struct->tag % 8);
  }
  else {
#ifdef DEBUG
    xil_printf("incorrect tag\r\n");
#endif
  }


  // Writing the DW3 field
  *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xF3C) = 0x00020200;

  // Writing FUNC field
  *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xF38) = 0x00000000;

  // Writing execute bit to 1 to send msg
  *(u32 *)(XPAR_QDMA_0_BASEADDR + 0xF34) = 0x00000001;


}


void write_c2h_byp_in(struct c2h_byp_in *out_struct) {
  // Writing the host address
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR)        = out_struct->raddr[1];
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x04) = out_struct->raddr[0];

  // Writing the host address
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x08) = out_struct->waddr[1];
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x0C) = out_struct->waddr[0];

  // Creating 32 bit word out of struct elements and sending
  u32 dword = 0x00000000;
  dword |= (u32)out_struct->qid          	<< 21;
  dword |= (u32)out_struct->port_id       << 18;
  dword |= (u32)out_struct->st_pfch_tag   << 11;
  dword |= (u32)out_struct->func      	<< 3;
  dword |= (u32)out_struct->error         << 2;
  dword |= (u32)out_struct->at;
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x10) = dword;

  // Creating 32 bit word out of struct elements and sending
  dword = 0x00000000;
  dword |= (u32)out_struct->mm_len        << 16;
  dword |= (u32)out_struct->mm_cidx;
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x14) = dword;

  // Creating 32 bit word out of struct elements and sending
  dword = 0x00000000;
  dword |= (u32)out_struct->mm_sdi        << 17;
  dword |= (u32)out_struct->mm_no_dma     << 16;
  dword |= (u32)out_struct->mm_mrkr_req   << 15;
  dword |= (u32)out_struct->mm_or_st   	<< 14;
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x1C) = dword;

  // Pushing the data into the FIFO and clearing the signal
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x8C) = 0x00000001;
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x8C) = 0x00000000;
}


void write_c2h_data(struct s_axis_c2h *out_struct) {

  // Creating 32 bit word out of struct elements and sending
  u32 dword = 0x00000000;
  dword |= (u32)out_struct->qid          	<< 21;
  dword |= (u32)out_struct->port_id       << 18;
  dword |= (u32)out_struct->marker      	<< 17;
  dword |= (u32)out_struct->len      		<< 1;
  dword |= (u32)out_struct->has_cmpt;
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x18) = dword;

  // Creating 32 bit word out of struct elements and sending
  dword = 0x00000000;
  dword |= (u32)out_struct->tlast         << 13;
  dword |= (u32)out_struct->mty	        << 7;
  dword |= (u32)out_struct->ecc;
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x1C) = dword;

  // Writing CRC
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x20) = out_struct->tcrc;

  // Writing the data
  for(int i = 0; i < 8; i++) {
    *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x24 + 4 * i) = out_struct->data[7-i];
  }

  // Pushing the data into the FIFO and clearing the signal
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x8C) = 0x00000004;
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x8C) = 0x00000000;

}


void write_c2h_cmpt(struct s_axis_c2h_cmpt *out_struct) {
  // Creating 32 bit word out of struct elements and sending
  u32 dword = 0x00000000;
  dword |= (u32)out_struct->user_trig     << 30;
  dword |= (u32)out_struct->size	       	<< 28;
  dword |= (u32)out_struct->port_id     	<< 25;
  dword |= (u32)out_struct->marker     	<< 24;
  dword |= (u32)out_struct->err_idx     	<< 21;
  dword |= (u32)out_struct->dpar	     	<< 5;
  dword |= (u32)out_struct->col_idx     	<< 2;
  dword |= (u32)out_struct->cmpt_type;
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x44) = dword;

  // Creating 32 bit word out of struct elements and sending
  dword = 0x00000000;
  dword |= (u32)out_struct->wait_pld_pkt_id 	<< 11;
  dword |= (u32)out_struct->qid;
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x48) = dword;

  for(int i = 0; i < 16; i++) {
    *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x4C + 4 * i) = out_struct->data[15-i];
  }

  // Pushing the data into the FIFO and clearing the signal
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x8C) = 0x00000002;
  *(u32 *)(XPAR_C2H_SHIM_LAYER_0_S00_AXI_BASEADDR + 0x8C) = 0x00000000;

}


void print_c2h_desc(struct c2h_byp_in *in_struct) {
  xil_printf("raddr[1] = %x\r\n", in_struct->raddr[1]);
  xil_printf("raddr[0] = %x\r\n", in_struct->raddr[0]);
  xil_printf("waddr[1] = %x\r\n", in_struct->waddr[1]);
  xil_printf("waddr[0] = %x\r\n", in_struct->waddr[0]);
  xil_printf("mm_cidx = %x\r\n", in_struct->mm_cidx);
  xil_printf("mm_len = %x\r\n", in_struct->mm_len);
  xil_printf("mm_mrkr_req = %x\r\n", in_struct->mm_mrkr_req);
  xil_printf("mm_no_dma = %x\r\n", in_struct->mm_no_dma);
  xil_printf("at = %x\r\n", in_struct->at);
  xil_printf("error = %x\r\n", in_struct->error);
  xil_printf("func = %x\r\n", in_struct->func);
  xil_printf("pfch_tag = %x\r\n", in_struct->st_pfch_tag);
  xil_printf("port_id = %x\r\n", in_struct->port_id);
  xil_printf("qid = %x\r\n", in_struct->qid);
}


void print_c2h_data(struct s_axis_c2h *in_struct) {
  for(int i = 0; i < 8; i++) {
    xil_printf("data[%d] = %x\r\n", i, in_struct->data[i]);
  }

  xil_printf("has_cmpt = %x\r\n", in_struct->has_cmpt);
  xil_printf("len = %x\r\n", in_struct->len);
  xil_printf("marker = %x\r\n", in_struct->marker);
  xil_printf("port_id = %x\r\n", in_struct->port_id);
  xil_printf("qid = %x\r\n", in_struct->qid);
  xil_printf("ecc = %x\r\n", in_struct->ecc);
  xil_printf("mty = %x\r\n", in_struct->mty);
  xil_printf("tlast = %x\r\n", in_struct->tlast);
  xil_printf("tcrc = %x\r\n", in_struct->tcrc);
}

// Timer related functions
void start_timer() {
  // Load the counter value to zero (assuming that register defaults to 0)
  *(u32 *)(XPAR_AXI_TIMER_0_BASEADDR) = 0x00000020;

  // Starting the counter
  *(u32 *)(XPAR_AXI_TIMER_0_BASEADDR) = 0x00000080;


}


u32 read_timer() {
  return *(u32 *)(XPAR_AXI_TIMER_0_BASEADDR + 0x08);
}

int end_timer() {
  // Disable the counter
  *(u32 *)(XPAR_AXI_TIMER_0_BASEADDR) = 0x00000000;

  // Returning the count
  return *(u32 *)(XPAR_AXI_TIMER_0_BASEADDR + 0x08);
  return 0;
}
void dump_pcie_config_space(u16 cfg_addr) {
  xil_printf("Address: %04x ", cfg_addr);
  for(int i = 0; i < 4; i++){
    u32 dw = *(u32 *)(XPAR_QDMA_0_BASEADDR + cfg_addr);
    xil_printf(" %08x ", dw);
    cfg_addr = cfg_addr +4;
   }
  xil_printf("\r\n");
}
