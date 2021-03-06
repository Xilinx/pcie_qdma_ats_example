
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
# Generated by Vivado tools

################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2020.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcu280-fsvh2892-2L-e
   set_property BOARD_PART xilinx.com:au280:part0:1.1 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:axi_bram_ctrl:4.1\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:axi_timer:2.0\
xilinx.com:ip:axi_uartlite:2.0\
user.org:user:c2h_shim_layer:1.0\
user.org:user:h2c_shim_layer:1.0\
xilinx.com:ip:mdm:3.2\
xilinx.com:ip:microblaze:11.0\
xilinx.com:ip:qdma:4.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:util_ds_buf:2.1\
xilinx.com:ip:lmb_bram_if_cntlr:4.0\
xilinx.com:ip:lmb_v10:3.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: microblaze_0_local_memory
proc create_hier_cell_microblaze_0_local_memory { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_microblaze_0_local_memory() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 DLMB

  create_bd_intf_pin -mode MirroredMaster -vlnv xilinx.com:interface:lmb_rtl:1.0 ILMB


  # Create pins
  create_bd_pin -dir I -type clk LMB_Clk
  create_bd_pin -dir I -type rst SYS_Rst

  # Create instance: dlmb_bram_if_cntlr, and set properties
  set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $dlmb_bram_if_cntlr

  # Create instance: dlmb_v10, and set properties
  set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]

  # Create instance: ilmb_bram_if_cntlr, and set properties
  set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
  set_property -dict [ list \
   CONFIG.C_ECC {0} \
 ] $ilmb_bram_if_cntlr

  # Create instance: ilmb_v10, and set properties
  set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]

  # Create instance: lmb_bram, and set properties
  set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lmb_bram ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
   CONFIG.use_bram_block {BRAM_Controller} \
 ] $lmb_bram

  # Create interface connections
  connect_bd_intf_net -intf_net microblaze_0_dlmb [get_bd_intf_pins DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_bus [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB] [get_bd_intf_pins dlmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_cntlr [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net microblaze_0_ilmb [get_bd_intf_pins ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_bus [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB] [get_bd_intf_pins ilmb_v10/LMB_Sl_0]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_cntlr [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]

  # Create port connections
  connect_bd_net -net SYS_Rst_1 [get_bd_pins SYS_Rst] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins LMB_Clk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports
  set pci_express_x8 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pci_express_x8 ]

  set pcie_ext_pipe_ep_usp_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:pcie_ext_pipe_rtl:1.0 pcie_ext_pipe_ep_usp_0 ]

  set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $pcie_refclk

  set rs232_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 rs232_uart ]


  # Create ports
  set disable_hbm_cattrip [ create_bd_port -dir O -from 0 -to 0 disable_hbm_cattrip ]
  set pcie_perstn [ create_bd_port -dir I -type rst pcie_perstn ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pcie_perstn

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_0 ]

  # Create instance: axi_bram_ctrl_0_bram, and set properties
  set axi_bram_ctrl_0_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 axi_bram_ctrl_0_bram ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
 ] $axi_bram_ctrl_0_bram

  # Create instance: axi_bram_ctrl_1, and set properties
  set axi_bram_ctrl_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.1 axi_bram_ctrl_1 ]
  set_property -dict [ list \
   CONFIG.DATA_WIDTH {256} \
   CONFIG.ECC_TYPE {0} \
 ] $axi_bram_ctrl_1

  # Create instance: axi_bram_ctrl_1_bram, and set properties
  set axi_bram_ctrl_1_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 axi_bram_ctrl_1_bram ]
  set_property -dict [ list \
   CONFIG.Memory_Type {True_Dual_Port_RAM} \
 ] $axi_bram_ctrl_1_bram

  # Create instance: axi_timer_0, and set properties
  set axi_timer_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_timer:2.0 axi_timer_0 ]

  # Create instance: axi_uartlite_0, and set properties
  set axi_uartlite_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_0 ]
  set_property -dict [ list \
   CONFIG.C_BAUDRATE {115200} \
   CONFIG.C_S_AXI_ACLK_FREQ_HZ {250000000} \
   CONFIG.UARTLITE_BOARD_INTERFACE {rs232_uart} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $axi_uartlite_0

  # Create instance: c2h_shim_layer_0, and set properties
  set c2h_shim_layer_0 [ create_bd_cell -type ip -vlnv user.org:user:c2h_shim_layer:1.0 c2h_shim_layer_0 ]

  # Create instance: h2c_shim_layer_0, and set properties
  set h2c_shim_layer_0 [ create_bd_cell -type ip -vlnv user.org:user:h2c_shim_layer:1.0 h2c_shim_layer_0 ]

  # Create instance: mdm_1, and set properties
  set mdm_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm_1 ]

  # Create instance: microblaze_0, and set properties
  set microblaze_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 microblaze_0 ]
  set_property -dict [ list \
   CONFIG.C_DEBUG_ENABLED {1} \
   CONFIG.C_D_AXI {1} \
   CONFIG.C_D_LMB {1} \
   CONFIG.C_I_LMB {1} \
 ] $microblaze_0

  # Create instance: microblaze_0_local_memory
  create_hier_cell_microblaze_0_local_memory [current_bd_instance .] microblaze_0_local_memory

  # Create instance: qdma_0, and set properties
  set qdma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:qdma:4.0 qdma_0 ]
  set_property -dict [ list \
   CONFIG.PF0_SRIOV_FIRST_VF_OFFSET {1} \
   CONFIG.PF0_SRIOV_VF_DEVICE_ID {A038} \
   CONFIG.PF1_INTERRUPT_PIN {INTA} \
   CONFIG.PF1_MSIX_CAP_TABLE_SIZE_qdma {000} \
   CONFIG.PF1_SRIOV_FIRST_VF_OFFSET {4} \
   CONFIG.PF1_SRIOV_VF_DEVICE_ID {A138} \
   CONFIG.PF2_INTERRUPT_PIN {INTA} \
   CONFIG.PF2_MSIX_CAP_TABLE_SIZE_qdma {000} \
   CONFIG.PF2_SRIOV_FIRST_VF_OFFSET {7} \
   CONFIG.PF2_SRIOV_VF_DEVICE_ID {A238} \
   CONFIG.PF3_INTERRUPT_PIN {INTA} \
   CONFIG.PF3_MSIX_CAP_TABLE_SIZE_qdma {000} \
   CONFIG.PF3_SRIOV_FIRST_VF_OFFSET {10} \
   CONFIG.PF3_SRIOV_VF_DEVICE_ID {A338} \
   CONFIG.axi_data_width {256_bit} \
   CONFIG.axisten_if_enable_msg_route {3FFFF} \
   CONFIG.csr_axilite_slave {true} \
   CONFIG.dsc_byp_mode {Descriptor_bypass_and_internal} \
   CONFIG.en_bridge {true} \
   CONFIG.enable_at_ports {true} \
   CONFIG.mode_selection {Advanced} \
   CONFIG.pf0_ats_enabled {true} \
   CONFIG.pf0_device_id {9038} \
   CONFIG.pf0_msix_cap_pba_offset {00010050} \
   CONFIG.pf0_msix_cap_table_offset {00010040} \
   CONFIG.pf0_pciebar2axibar_2 {0x00000000C0000000} \
   CONFIG.pf1_msix_enabled_qdma {false} \
   CONFIG.pf2_device_id {9238} \
   CONFIG.pf2_msix_enabled_qdma {false} \
   CONFIG.pf3_device_id {9338} \
   CONFIG.pf3_msix_enabled_qdma {false} \
   CONFIG.pipe_sim {true} \
   CONFIG.pl_link_cap_max_link_width {X8} \
 ] $qdma_0

  # Create instance: rst_qdma_0_250M, and set properties
  set rst_qdma_0_250M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_qdma_0_250M ]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property -dict [ list \
   CONFIG.NUM_MI {6} \
   CONFIG.NUM_SI {2} \
 ] $smartconnect_0

  # Create instance: tie_off_no_wr_bk_mkr, and set properties
  set tie_off_no_wr_bk_mkr [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 tie_off_no_wr_bk_mkr ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $tie_off_no_wr_bk_mkr

  # Create instance: util_ds_buf, and set properties
  set util_ds_buf [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_ds_buf:2.1 util_ds_buf ]
  set_property -dict [ list \
   CONFIG.C_BUF_TYPE {IBUFDSGTE} \
   CONFIG.DIFF_CLK_IN_BOARD_INTERFACE {pcie_refclk} \
   CONFIG.USE_BOARD_FLOW {true} \
 ] $util_ds_buf

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_1

  # Create interface connections
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTB [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTB] [get_bd_intf_pins axi_bram_ctrl_0_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTA] [get_bd_intf_pins axi_bram_ctrl_1_bram/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_bram_ctrl_1_BRAM_PORTB [get_bd_intf_pins axi_bram_ctrl_1/BRAM_PORTB] [get_bd_intf_pins axi_bram_ctrl_1_bram/BRAM_PORTB]
  connect_bd_intf_net -intf_net axi_uartlite_0_UART [get_bd_intf_ports rs232_uart] [get_bd_intf_pins axi_uartlite_0/UART]
  connect_bd_intf_net -intf_net microblaze_0_M_AXI_DP [get_bd_intf_pins microblaze_0/M_AXI_DP] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net microblaze_0_debug [get_bd_intf_pins mdm_1/MBDEBUG_0] [get_bd_intf_pins microblaze_0/DEBUG]
  connect_bd_intf_net -intf_net microblaze_0_dlmb_1 [get_bd_intf_pins microblaze_0/DLMB] [get_bd_intf_pins microblaze_0_local_memory/DLMB]
  connect_bd_intf_net -intf_net microblaze_0_ilmb_1 [get_bd_intf_pins microblaze_0/ILMB] [get_bd_intf_pins microblaze_0_local_memory/ILMB]
  connect_bd_intf_net -intf_net pcie_ext_pipe_ep_usp_0_1 [get_bd_intf_ports pcie_ext_pipe_ep_usp_0] [get_bd_intf_pins qdma_0/pcie_ext_pipe_ep_usp]
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins util_ds_buf/CLK_IN_D]
  connect_bd_intf_net -intf_net qdma_0_M_AXI [get_bd_intf_pins axi_bram_ctrl_1/S_AXI] [get_bd_intf_pins qdma_0/M_AXI]
  connect_bd_intf_net -intf_net qdma_0_M_AXI_LITE [get_bd_intf_pins qdma_0/M_AXI_LITE] [get_bd_intf_pins smartconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net qdma_0_pcie_mgt [get_bd_intf_ports pci_express_x8] [get_bd_intf_pins qdma_0/pcie_mgt]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins h2c_shim_layer_0/S00_AXI] [get_bd_intf_pins smartconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M01_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins smartconnect_0/M01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M02_AXI [get_bd_intf_pins qdma_0/S_AXI_LITE_CSR] [get_bd_intf_pins smartconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M03_AXI [get_bd_intf_pins axi_uartlite_0/S_AXI] [get_bd_intf_pins smartconnect_0/M03_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M04_AXI [get_bd_intf_pins c2h_shim_layer_0/S00_AXI] [get_bd_intf_pins smartconnect_0/M04_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M05_AXI [get_bd_intf_pins axi_timer_0/S_AXI] [get_bd_intf_pins smartconnect_0/M05_AXI]

  # Create port connections
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_at [get_bd_pins c2h_shim_layer_0/c2h_byp_in_at] [get_bd_pins qdma_0/c2h_byp_in_mm_at] [get_bd_pins qdma_0/c2h_byp_in_st_csh_at]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_error [get_bd_pins c2h_shim_layer_0/c2h_byp_in_error] [get_bd_pins qdma_0/c2h_byp_in_mm_error] [get_bd_pins qdma_0/c2h_byp_in_st_csh_error]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_func [get_bd_pins c2h_shim_layer_0/c2h_byp_in_func] [get_bd_pins qdma_0/c2h_byp_in_mm_func] [get_bd_pins qdma_0/c2h_byp_in_st_csh_func]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_mm_cidx [get_bd_pins c2h_shim_layer_0/c2h_byp_in_mm_cidx] [get_bd_pins qdma_0/c2h_byp_in_mm_cidx]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_mm_len [get_bd_pins c2h_shim_layer_0/c2h_byp_in_mm_len] [get_bd_pins qdma_0/c2h_byp_in_mm_len]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_mm_mrkr_req [get_bd_pins c2h_shim_layer_0/c2h_byp_in_mm_mrkr_req] [get_bd_pins qdma_0/c2h_byp_in_mm_mrkr_req]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_mm_no_dma [get_bd_pins c2h_shim_layer_0/c2h_byp_in_mm_no_dma] [get_bd_pins qdma_0/c2h_byp_in_mm_no_dma]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_mm_sdi [get_bd_pins c2h_shim_layer_0/c2h_byp_in_mm_sdi] [get_bd_pins qdma_0/c2h_byp_in_mm_sdi]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_mm_vld [get_bd_pins c2h_shim_layer_0/c2h_byp_in_mm_vld] [get_bd_pins qdma_0/c2h_byp_in_mm_vld]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_port_id [get_bd_pins c2h_shim_layer_0/c2h_byp_in_port_id] [get_bd_pins qdma_0/c2h_byp_in_mm_port_id] [get_bd_pins qdma_0/c2h_byp_in_st_csh_port_id]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_qid [get_bd_pins c2h_shim_layer_0/c2h_byp_in_qid] [get_bd_pins qdma_0/c2h_byp_in_mm_qid] [get_bd_pins qdma_0/c2h_byp_in_st_csh_qid]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_raddr [get_bd_pins c2h_shim_layer_0/c2h_byp_in_raddr] [get_bd_pins qdma_0/c2h_byp_in_mm_radr]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_st_pfch_tag [get_bd_pins c2h_shim_layer_0/c2h_byp_in_st_pfch_tag] [get_bd_pins qdma_0/c2h_byp_in_st_csh_pfch_tag]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_st_vld [get_bd_pins c2h_shim_layer_0/c2h_byp_in_st_vld] [get_bd_pins qdma_0/c2h_byp_in_st_csh_vld]
  connect_bd_net -net c2h_shim_layer_0_c2h_byp_in_waddr [get_bd_pins c2h_shim_layer_0/c2h_byp_in_waddr] [get_bd_pins qdma_0/c2h_byp_in_mm_wadr] [get_bd_pins qdma_0/c2h_byp_in_st_csh_addr]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_ctrl_cmpty_type [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_ctrl_cmpty_type] [get_bd_pins qdma_0/s_axis_c2h_cmpt_ctrl_cmpt_type]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_ctrl_col_idx [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_ctrl_col_idx] [get_bd_pins qdma_0/s_axis_c2h_cmpt_ctrl_col_idx]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_ctrl_err_idx [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_ctrl_err_idx] [get_bd_pins qdma_0/s_axis_c2h_cmpt_ctrl_err_idx]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_ctrl_marker [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_ctrl_marker] [get_bd_pins qdma_0/s_axis_c2h_cmpt_ctrl_marker]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_ctrl_port_id [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_ctrl_port_id] [get_bd_pins qdma_0/s_axis_c2h_cmpt_ctrl_port_id]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_ctrl_qid [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_ctrl_qid] [get_bd_pins qdma_0/s_axis_c2h_cmpt_ctrl_qid]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_ctrl_user_trig [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_ctrl_user_trig] [get_bd_pins qdma_0/s_axis_c2h_cmpt_ctrl_user_trig]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_dpar [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_dpar] [get_bd_pins qdma_0/s_axis_c2h_cmpt_dpar]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_size [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_size] [get_bd_pins qdma_0/s_axis_c2h_cmpt_size]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_tdata [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_tdata] [get_bd_pins qdma_0/s_axis_c2h_cmpt_tdata]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_tvalid [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_tvalid] [get_bd_pins qdma_0/s_axis_c2h_cmpt_tvalid]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_cmpt_wait_pld_pkt_id [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_wait_pld_pkt_id] [get_bd_pins qdma_0/s_axis_c2h_cmpt_ctrl_wait_pld_pkt_id]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_ecc [get_bd_pins c2h_shim_layer_0/m_axis_c2h_ecc] [get_bd_pins qdma_0/s_axis_c2h_ctrl_ecc]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_has_cmpt [get_bd_pins c2h_shim_layer_0/m_axis_c2h_has_cmpt] [get_bd_pins qdma_0/s_axis_c2h_ctrl_has_cmpt]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_len [get_bd_pins c2h_shim_layer_0/m_axis_c2h_len] [get_bd_pins qdma_0/s_axis_c2h_ctrl_len]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_marker [get_bd_pins c2h_shim_layer_0/m_axis_c2h_marker] [get_bd_pins qdma_0/s_axis_c2h_ctrl_marker]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_mty [get_bd_pins c2h_shim_layer_0/m_axis_c2h_mty] [get_bd_pins qdma_0/s_axis_c2h_mty]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_port_id [get_bd_pins c2h_shim_layer_0/m_axis_c2h_port_id] [get_bd_pins qdma_0/s_axis_c2h_ctrl_port_id]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_qid [get_bd_pins c2h_shim_layer_0/m_axis_c2h_qid] [get_bd_pins qdma_0/s_axis_c2h_ctrl_qid]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_tcrc [get_bd_pins c2h_shim_layer_0/m_axis_c2h_tcrc] [get_bd_pins qdma_0/s_axis_c2h_tcrc]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_tdata [get_bd_pins c2h_shim_layer_0/m_axis_c2h_tdata] [get_bd_pins qdma_0/s_axis_c2h_tdata]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_tlast [get_bd_pins c2h_shim_layer_0/m_axis_c2h_tlast] [get_bd_pins qdma_0/s_axis_c2h_tlast]
  connect_bd_net -net c2h_shim_layer_0_m_axis_c2h_tvalid [get_bd_pins c2h_shim_layer_0/m_axis_c2h_tvalid] [get_bd_pins qdma_0/s_axis_c2h_tvalid]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_at [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_at] [get_bd_pins qdma_0/h2c_byp_in_mm_at] [get_bd_pins qdma_0/h2c_byp_in_st_at]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_cidx [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_cidx] [get_bd_pins qdma_0/h2c_byp_in_mm_cidx] [get_bd_pins qdma_0/h2c_byp_in_st_cidx]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_eop [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_eop] [get_bd_pins qdma_0/h2c_byp_in_st_eop]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_error [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_error] [get_bd_pins qdma_0/h2c_byp_in_mm_error] [get_bd_pins qdma_0/h2c_byp_in_st_error]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_func [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_func] [get_bd_pins qdma_0/h2c_byp_in_mm_func] [get_bd_pins qdma_0/h2c_byp_in_st_func]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_len [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_len] [get_bd_pins qdma_0/h2c_byp_in_mm_len] [get_bd_pins qdma_0/h2c_byp_in_st_len]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_mm_vld [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_mm_vld] [get_bd_pins qdma_0/h2c_byp_in_mm_vld]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_mrkr_req [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_mrkr_req] [get_bd_pins qdma_0/h2c_byp_in_mm_mrkr_req] [get_bd_pins qdma_0/h2c_byp_in_st_mrkr_req]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_no_dma [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_no_dma] [get_bd_pins qdma_0/h2c_byp_in_mm_no_dma] [get_bd_pins qdma_0/h2c_byp_in_st_no_dma]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_port_id [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_port_id] [get_bd_pins qdma_0/h2c_byp_in_mm_port_id] [get_bd_pins qdma_0/h2c_byp_in_st_port_id]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_qid [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_qid] [get_bd_pins qdma_0/h2c_byp_in_mm_qid] [get_bd_pins qdma_0/h2c_byp_in_st_qid]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_raddr [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_raddr] [get_bd_pins qdma_0/h2c_byp_in_mm_radr] [get_bd_pins qdma_0/h2c_byp_in_st_addr]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_sdi [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_sdi] [get_bd_pins qdma_0/h2c_byp_in_mm_sdi] [get_bd_pins qdma_0/h2c_byp_in_st_sdi]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_sop [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_sop] [get_bd_pins qdma_0/h2c_byp_in_st_sop]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_st_vld [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_st_vld] [get_bd_pins qdma_0/h2c_byp_in_st_vld]
  connect_bd_net -net h2c_shim_layer_0_m_h2c_byp_in_waddr [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_waddr] [get_bd_pins qdma_0/h2c_byp_in_mm_wadr]
  connect_bd_net -net h2c_shim_layer_0_s_axis_h2c_tready [get_bd_pins h2c_shim_layer_0/s_axis_h2c_tready] [get_bd_pins qdma_0/m_axis_h2c_tready]
  connect_bd_net -net mdm_1_debug_sys_rst [get_bd_pins mdm_1/Debug_SYS_Rst] [get_bd_pins rst_qdma_0_250M/mb_debug_sys_rst]
  connect_bd_net -net microblaze_0_Clk [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_bram_ctrl_1/s_axi_aclk] [get_bd_pins axi_timer_0/s_axi_aclk] [get_bd_pins axi_uartlite_0/s_axi_aclk] [get_bd_pins c2h_shim_layer_0/aclk] [get_bd_pins h2c_shim_layer_0/clk] [get_bd_pins microblaze_0/Clk] [get_bd_pins microblaze_0_local_memory/LMB_Clk] [get_bd_pins qdma_0/axi_aclk] [get_bd_pins rst_qdma_0_250M/slowest_sync_clk] [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net pcie_perstn_1 [get_bd_ports pcie_perstn] [get_bd_pins qdma_0/sys_rst_n]
  connect_bd_net -net qdma_0_axi_aresetn [get_bd_pins axi_bram_ctrl_1/s_axi_aresetn] [get_bd_pins axi_timer_0/s_axi_aresetn] [get_bd_pins axi_uartlite_0/s_axi_aresetn] [get_bd_pins c2h_shim_layer_0/aresetn] [get_bd_pins h2c_shim_layer_0/aresetn] [get_bd_pins qdma_0/axi_aresetn] [get_bd_pins rst_qdma_0_250M/ext_reset_in]
  connect_bd_net -net qdma_0_c2h_byp_in_mm_rdy [get_bd_pins c2h_shim_layer_0/c2h_byp_in_mm_rdy] [get_bd_pins qdma_0/c2h_byp_in_mm_rdy]
  connect_bd_net -net qdma_0_c2h_byp_in_st_csh_rdy [get_bd_pins c2h_shim_layer_0/c2h_byp_in_st_rdy] [get_bd_pins qdma_0/c2h_byp_in_st_csh_rdy]
  connect_bd_net -net qdma_0_h2c_byp_in_mm_rdy [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_mm_rdy] [get_bd_pins qdma_0/h2c_byp_in_mm_rdy]
  connect_bd_net -net qdma_0_h2c_byp_in_st_rdy [get_bd_pins h2c_shim_layer_0/m_h2c_byp_in_st_rdy] [get_bd_pins qdma_0/h2c_byp_in_st_rdy]
  connect_bd_net -net qdma_0_m_axis_h2c_tcrc [get_bd_pins h2c_shim_layer_0/s_axis_h2c_tuser_crc] [get_bd_pins qdma_0/m_axis_h2c_tcrc]
  connect_bd_net -net qdma_0_m_axis_h2c_tdata [get_bd_pins h2c_shim_layer_0/s_axis_h2c_tdata] [get_bd_pins qdma_0/m_axis_h2c_tdata]
  connect_bd_net -net qdma_0_m_axis_h2c_tlast [get_bd_pins h2c_shim_layer_0/s_axis_h2c_tlast] [get_bd_pins qdma_0/m_axis_h2c_tlast]
  connect_bd_net -net qdma_0_m_axis_h2c_tuser_err [get_bd_pins h2c_shim_layer_0/s_axis_h2c_tuser_err] [get_bd_pins qdma_0/m_axis_h2c_tuser_err]
  connect_bd_net -net qdma_0_m_axis_h2c_tuser_mdata [get_bd_pins h2c_shim_layer_0/s_axis_h2c_tuser_mdata] [get_bd_pins qdma_0/m_axis_h2c_tuser_mdata]
  connect_bd_net -net qdma_0_m_axis_h2c_tuser_mty [get_bd_pins h2c_shim_layer_0/s_axis_h2c_tuser_mty] [get_bd_pins qdma_0/m_axis_h2c_tuser_mty]
  connect_bd_net -net qdma_0_m_axis_h2c_tuser_port_id [get_bd_pins h2c_shim_layer_0/s_axis_h2c_tuser_port_id] [get_bd_pins qdma_0/m_axis_h2c_tuser_port_id]
  connect_bd_net -net qdma_0_m_axis_h2c_tuser_qid [get_bd_pins h2c_shim_layer_0/s_axis_h2c_tuser_qid] [get_bd_pins qdma_0/m_axis_h2c_tuser_qid]
  connect_bd_net -net qdma_0_m_axis_h2c_tuser_zero_byte [get_bd_pins h2c_shim_layer_0/s_axis_h2c_tuser_zerobyte] [get_bd_pins qdma_0/m_axis_h2c_tuser_zero_byte]
  connect_bd_net -net qdma_0_m_axis_h2c_tvalid [get_bd_pins h2c_shim_layer_0/s_axis_h2c_tvalid] [get_bd_pins qdma_0/m_axis_h2c_tvalid]
  connect_bd_net -net qdma_0_s_axis_c2h_cmpt_tready [get_bd_pins c2h_shim_layer_0/m_axis_c2h_cmpt_tready] [get_bd_pins qdma_0/s_axis_c2h_cmpt_tready]
  connect_bd_net -net qdma_0_s_axis_c2h_tready [get_bd_pins c2h_shim_layer_0/m_axis_c2h_tready] [get_bd_pins qdma_0/s_axis_c2h_tready]
  connect_bd_net -net rst_qdma_0_250M_bus_struct_reset [get_bd_pins microblaze_0_local_memory/SYS_Rst] [get_bd_pins rst_qdma_0_250M/bus_struct_reset]
  connect_bd_net -net rst_qdma_0_250M_interconnect_aresetn [get_bd_pins rst_qdma_0_250M/interconnect_aresetn] [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net rst_qdma_0_250M_mb_reset [get_bd_pins microblaze_0/Reset] [get_bd_pins rst_qdma_0_250M/mb_reset]
  connect_bd_net -net rst_qdma_0_250M_peripheral_aresetn [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins rst_qdma_0_250M/peripheral_aresetn]
  connect_bd_net -net tie_off_no_wr_bk_mkr_dout [get_bd_pins qdma_0/s_axis_c2h_cmpt_ctrl_no_wrb_marker] [get_bd_pins tie_off_no_wr_bk_mkr/dout]
  connect_bd_net -net util_ds_buf_IBUF_DS_ODIV2 [get_bd_pins qdma_0/sys_clk] [get_bd_pins util_ds_buf/IBUF_DS_ODIV2]
  connect_bd_net -net util_ds_buf_IBUF_OUT [get_bd_pins qdma_0/sys_clk_gt] [get_bd_pins util_ds_buf/IBUF_OUT]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins qdma_0/tm_dsc_sts_rdy] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_ports disable_hbm_cattrip] [get_bd_pins xlconstant_1/dout]

  # Create address segments
  assign_bd_address -offset 0xC0000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0x41C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40600000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x44A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs c2h_shim_layer_0/S00_AXI/S00_AXI_reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs microblaze_0_local_memory/dlmb_bram_if_cntlr/SLMB/Mem] -force
  assign_bd_address -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs h2c_shim_layer_0/S00_AXI/S00_AXI_reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces microblaze_0/Instruction] [get_bd_addr_segs microblaze_0_local_memory/ilmb_bram_if_cntlr/SLMB/Mem] -force
  assign_bd_address -offset 0x10000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces microblaze_0/Data] [get_bd_addr_segs qdma_0/S_AXI_LITE_CSR/CTL0] -force
  assign_bd_address -offset 0xC0000000 -range 0x00002000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI_LITE] [get_bd_addr_segs axi_bram_ctrl_0/S_AXI/Mem0] -force
  assign_bd_address -offset 0xC2000000 -range 0x00080000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI] [get_bd_addr_segs axi_bram_ctrl_1/S_AXI/Mem0] -force
  assign_bd_address -offset 0x41C00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI_LITE] [get_bd_addr_segs axi_timer_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x40600000 -range 0x00010000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI_LITE] [get_bd_addr_segs axi_uartlite_0/S_AXI/Reg] -force
  assign_bd_address -offset 0x44A10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI_LITE] [get_bd_addr_segs c2h_shim_layer_0/S00_AXI/S00_AXI_reg] -force
  assign_bd_address -offset 0x44A00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI_LITE] [get_bd_addr_segs h2c_shim_layer_0/S00_AXI/S00_AXI_reg] -force
  assign_bd_address -offset 0x10000000 -range 0x10000000 -target_address_space [get_bd_addr_spaces qdma_0/M_AXI_LITE] [get_bd_addr_segs qdma_0/S_AXI_LITE_CSR/CTL0] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


