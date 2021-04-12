#!/bin/bash

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


# Notes:
# The "dma_ip_drivers_2020.1" is the top level directry name of the Vivado 2020.1 version of the DMA drivers  for QDMA 
# driver source repository tree
# The shell script is ment to be lunched at the same directory level jsut above the "dma_ip_drivers_2020.1"  

echo "Patching QDMA drivers to support ATS feature" 
patch  -ruN -p1 -d dma_ip_drivers-2020.1/ < qdma_ats.patch

