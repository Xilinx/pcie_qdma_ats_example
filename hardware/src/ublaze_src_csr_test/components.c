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

/* This is just testing the CSR functionality. It will read the first two
 * data words of the CSR, and if either of them are non-zero it will set them
 * both back to 0 and then return true. Otherwise it will just return false.
 */
int probe_and_read_csr_test(struct csr *in_struct) {
	in_struct->host_addr[0]  = *(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR);

	if(in_struct->host_addr[0] == in_struct->host_addr[1]) {
		return 0;
	}
	else {
		in_struct->host_addr[1] = in_struct->host_addr[0];
		*(u32 *)(XPAR_AXI_BRAM_CTRL_0_S_AXI_BASEADDR + 0x04) = in_struct->host_addr[1];
		return 1;
	}
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
	xil_printf("FIFO overflow: %x\r\n", in_struct->fifo_overflow);
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
		*(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE68) = 0x00010000 << in_struct->tag;
	}
	else if(in_struct->tag < 24) {
		*(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE68) = 0x00000100 << in_struct->tag;
	}
	else if(in_struct->tag < 32) {
		*(u32 *)(XPAR_QDMA_0_BASEADDR + 0xE68) = 0x00000001 << in_struct->tag;
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
