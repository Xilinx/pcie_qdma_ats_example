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

int main(void) {

	struct csr 				*csr_data;
	struct in_msg 			*in_msg_data;

	csr_data        = (struct csr *)            malloc(sizeof(struct csr));
	in_msg_data		= (struct in_msg *)			malloc(sizeof(struct in_msg));

#ifdef DEBUG
	//xil_printf("CSR Test. Elf compiled on %s at %s. Starting...\r\n", __DATE__, __TIME__);
#endif

	while(1) {

		// Check if we have any messages. If so send completion immediately
		if(probe_and_read_msg_fifo(in_msg_data)) {
			if(check_invalidate(in_msg_data)) {
				send_invl_completion(in_msg_data);
#ifdef DEBUG
				xil_printf("Compl\r\n");
#endif
			}
#ifdef DEBUG
			xil_printf("Msg received. Info:\r\n");
			print_msg(in_msg_data);
#endif
		}

		// When the CSR are written to, use that data as an address for an untranslated request
		if(probe_and_read_csr_test(csr_data)) {
#ifdef DEBUG
			xil_printf("%x\r\n", csr_data->host_addr[0]);
#endif
		}


	}


	return 0;

}
