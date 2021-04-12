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

setws build

set script_directory [file dirname [file normalize [info script]]]

set root_directory [file normalize [file join $script_directory "../"]]



platform create -name "mb" -hw [file join ${root_directory} \
		     "hardware/build/qdma_v4_ats_ex/qdma_v4_ats_ex.xsa"]

::common::get_property NAME [hsi::get_cells -filter {IP_TYPE==PROCESSOR}]
domain create -name microblaze -proc microblaze_0 

platform generate

app create -name ats_agent -platform mb -domain microblaze \
    -template "Empty Application" 

importsources -name ats_agent -soft-link -path [file join $root_directory \
						    "hardware/src/ublaze_src"]

app build -name ats_agent
