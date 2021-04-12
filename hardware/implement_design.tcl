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

remove_cluster_configurations -quiet [get_cluster_configurations lsf_maxmem]

create_cluster_configuration -name lsf_maxmem -submit_cmd { bsub -R "select[os == lin && type == X86_64 && (osdistro == rhel || osdistro == centos) && (osver == ws7)] rusage[mem=4096]" -M 80000000 -N -q medium } -kill_cmd { bkill } -type LSF
reset_run synth_1

launch_runs impl_1 -cluster_configuration lsf_maxmem

wait_on_run [current_run -implementation]

#check run status

exit 0
