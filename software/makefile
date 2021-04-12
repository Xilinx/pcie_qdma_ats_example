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
APP_NAME := ats_agent


all : ${BUILD_DIR}/${APP_NAME}/ats_agent.elf 

${BUILD_DIR}/${APP_NAME}/ats_agent.elf : ../hardware/build/qdma_v4_ats_ex/qdma_v4_ats_ex.xsa 
	xsct build.tcl
