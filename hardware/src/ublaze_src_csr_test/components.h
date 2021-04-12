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


#define DEBUG

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
        u32 host_addr[2];       // Will store the addr we want to DMA to/from
};


int probe_and_read_csr_test(struct csr *in_struct);
int probe_and_read_msg_fifo(struct in_msg *in_struct);
void send_invl_completion(struct in_msg *in_struct);
int check_invalidate(struct in_msg *in_struct);
void print_msg(struct in_msg *in_struct);
void print_csr(struct csr *in_struct);


