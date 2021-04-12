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

#include "xil_types.h"
#include "xparameters.h"
#include "xil_printf.h"

#define DEBUG
//#define MM_ENABLE
//#define C2H_COMPLETION
//#define USE_TIMER

// CSR offsets
#define HOST_PHYS_ADDR_0_OFFSET 0x0C
#define HOST_PHYS_ADDR_1_OFFSET 0x10

#define H2C_SHIM_FIFO_POP    0x18
#define H2C_SHIM_FIFO_STATUS 0x24
#define H2C_SHIM_PA_LO       0x2C
#define H2C_SHIM_PA_HI       0x30

#define H2C_CSR(X) *(u32 *)(XPAR_H2C_SHIM_LAYER_0_S00_AXI_BASEADDR + X)

#define VERSION     0x38

#define C2H_DATA_CSR 0x100

struct m_axis_h2c {
        u32 tdata[8]; // Store all 256 bits of m_axis_h2c_tdata
        u32 tuser_crc;
        u32 tuser_mdata;
        u16 tuser_qid:11;
        u8  tuser_port_id:3;
        u8  tuser_err:1;
        u8  tuser_mty:6;
        u8  tuser_zerobyte:1;
        u8  tuser_tlast:1;
};


struct h2c_byp_in {
        u32 raddr[2];
        u32 waddr[2];
        u8  func;
        u8  error:1;
        u8  no_dma:1;
        u8  mrkr_req:1;
        u8  sdi:1;
        u8  eop:1;
        u8  sop:1;
        u8  at:2;
        u16 len;
        u16 cidx;
        u8	mm_or_st:1; // 1 means mm, 0 means st
        u8  port_id:3;
        u16 qid:11;
};

// Contains the C2H descriptor
struct c2h_byp_in {
        u32 raddr[2];
        u32 waddr[2];
        u8 	mm_or_st:1;
        u16 mm_cidx;
        u16 mm_len;
        u8 	mm_mrkr_req:1;
        u8	mm_no_dma:1;
        u8	mm_sdi:1;
        u8  at:2;
        u8  error:1;
        u8  func;
        u8 	st_pfch_tag:8;
        u8  port_id:3;
        u16 qid:11;
};

// Contains the C2H data
struct s_axis_c2h {
        u32 data[8]; //
        u8 	has_cmpt:1;
        u16 len;
        u8 	marker:1;
        u8  port_id:3;
        u16 qid:11;
        u8	ecc:7;
        u8	mty:6;
        u8 	tlast:1;
        u32 tcrc;

};

// Contains the completion data
struct s_axis_c2h_cmpt {
		u32 data[16];	// Completion data
		u8 	cmpt_type:2;
		u8	col_idx:3;
		u16	dpar;
		u8 	err_idx:3;
		u8 	marker:1;
		u8  port_id:3;
		u8	size:2;
		u8	user_trig:1;
		u16 qid:11;
		u16	wait_pld_pkt_id;
};


struct in_msg {
        u8 	fifo_overflow:1; // Tells us if the fifo has overflowed and messages have been dropped
        u8 	tag;
        u16 req_id;
        u8 	req_type:5;
        u8	msg_code;
        u8	msg_routing:3;
        u16 dword_count:11;
        u32 addr[2];			//	 The address to be invalidated
};


struct csr {
        u32 host_virt_addr[2];
        u32 host_phys_addr[2];
        u32 host_buff_data[2];
        u32 c2h_host_buff_data[2];
};

// CSR related functions
int read_csr_step_counter();
int read_csr_at_mode();
int read_csr_len();

u32 read_csr();
void write_csr(u32, u32);

int read_csr_c2h_data(int);

void read_csr_virtual_address_csr(struct csr *in_struct);
void write_csr_step_counter(u32 step_counter);
void write_csr_phys_addr(struct csr *in_struct);
void write_csr_buff_data(struct csr *in_struct);
void write_csr_c2h_buff_data(struct csr *in_struct);


// H2C transfer related functions
u8 m_axis_h2c_has_data();
void pop_m_axis_h2c_fifo();
u8 read_at_from_m_axis_h2c(u32 *, u32 *);
int probe_and_read_m_axis_h2c(struct m_axis_h2c *in_struct);
void write_h2c_byp_in(struct h2c_byp_in *out_struct);
void initialize_h2c_desc(struct h2c_byp_in *in_struct);


// C2H transfer related functions
void write_c2h_cmpt(struct s_axis_c2h_cmpt *out_struct);
void write_c2h_byp_in(struct c2h_byp_in *out_struct);
void write_c2h_data(struct s_axis_c2h *out_struct);
void initialize_c2h_structs(struct s_axis_c2h_cmpt *cmpt, struct c2h_byp_in *desc, struct s_axis_c2h *data);


// Msg related functions
int probe_and_read_msg_fifo(struct in_msg *in_struct);
void send_invl_completion(struct in_msg *in_struct);
int check_invalidate(struct in_msg *in_struct);

// Timer related functions
void start_timer();
u32 read_timer();
int end_timer();


// Debug related functions
void print_csr(struct csr *in_struct);
void print_msg(struct in_msg *in_struct);
void print_h2c_desc(struct h2c_byp_in *in_struct);
void print_h2c_data(struct m_axis_h2c *in_struct);
void print_c2h_desc(struct c2h_byp_in *in_struct);
void print_c2h_data(struct s_axis_c2h *in_struct);
