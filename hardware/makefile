#
# Copyright (C) 2021 Xilinx, Inc
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may
# not use this file except in compliance with the License. A copy of the
# License is located at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#

#VITIS_BIN := /proj/xbuilds/SWIP/2020.1_0602_1208/installs/lin64/Vitis/2020.1/bin
#VIVADO_BIN := /proj/xbuilds/SWIP/2020.1_0602_1208/installs/lin64/Vivado/2020.1/bin

PROJECT := qdma_v4_ats_ex/qdma_v4_ats_ex.xpr
PROJECT_SOURCES :=  build/myproj/project_1.srcs/sources_1

# would be better if I stripped off the trailing /
SCRIPT_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
BUILD_DIR := build

all : xsa 

.phony : project

project : ${BUILD_DIR}/${PROJECT}

.phony : bd
bd : ${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.srcs/sources_1/bd/design_1/design_1.bd

# builds project and bd
${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.xpr \
${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.srcs/sources_1/bd/design_1/design_1.bd: ${SCRIPT_DIR}/create_project.tcl | build
	cd ${BUILD_DIR} && vivado -mode tcl -source $<


#bd : ${SCRIPT_DIR}/create_project.tcl
#	cd ${BUILD_DIR} && vivado -mode tcl -source $<

.phony : hwhoff
hwhoff : ${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.srcs/sources_1/bd/design_1/hw_handoff/design_1.hwh

${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.srcs/sources_1/bd/design_1/hw_handoff/design_1.hwh  : ${SCRIPT_DIR}/generate_products.tcl \
								             ${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.srcs/sources_1/bd/design_1/design_1.bd | ${BUILD_DIR}
	cd ${BUILD_DIR} && vivado -mode tcl -source $< ${PROJECT} 

.phony: xsa
xsa : ${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.xsa 

${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.xsa : ${SCRIPT_DIR}/generate_xsa.tcl \
				    ${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.srcs/sources_1/bd/design_1/hw_handoff/design_1.hwh | ${BUILD_DIR}
	cd ${BUILD_DIR} && vivado -mode tcl -source $< ${PROJECT}

build : 
	mkdir -p build

# ${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.runs/synth_1/design_1_wrapper.dcp
synth : ${SCRIPT_DIR}/synthesize_design.tcl ${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.xsa
	cd ${BUILD_DIR} && vivado -mode tcl -source $< ${PROJECT}
impl : ${SCRIPT_DIR}/implement_design.tcl
	cd ${BUILD_DIR} && vivado -mode tcl -source $< ${PROJECT}

.phony: bitstream
bitstream: ${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.runs/impl_1/design_1_wrapper.bit
${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.runs/impl_1/design_1_wrapper.bit : ${SCRIPT_DIR}/bitstream.tcl 
	cd ${BUILD_DIR} && vivado -mode tcl -source $< ${PROJECT}

#            ${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.runs/impl_1/design_1_wrapper.bit
updatemem : ${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.runs/impl_1/design_1_wrapper.mmi \
	    ${SCRIPT_DIR}/../software/build/ats_agent/Debug/ats_agent.elf 
	updatemem -meminfo  \
	${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.runs/impl_1/design_1_wrapper.mmi \
	-data ${SCRIPT_DIR}/../software/build/ats_agent/Debug/ats_agent.elf \
	-bit ${BUILD_DIR}/qdma_v4_ats_ex/qdma_v4_ats_ex.runs/impl_1/design_1_wrapper.bit \
	-proc design_1_i/microblaze_0 \
	-out ${BUILD_DIR}/rebuilt_bitstream.bit -force
