##################################################################
# CHECK VIVADO VERSION
##################################################################

set scripts_vivado_version 2020.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
  catch {common::send_msg_id "IPS_TCL-100" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_ip_tcl to create an updated script."}
  return 1
}

##################################################################
# START
##################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source uip.tcl
# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./ETH/ETH.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
  create_project ETH ETH -part xc7a100tfgg484-2L
  set_property target_language Verilog [current_project]
  set_property simulator_language Mixed [current_project]
}

##################################################################
# CHECK IPs
##################################################################

set bCheckIPs 1
set bCheckIPsPassed 1
if { $bCheckIPs == 1 } {
  set list_check_ips { xilinx.com:ip:fifo_generator:13.2 }
  set list_ips_missing ""
  common::send_msg_id "IPS_TCL-1001" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

  foreach ip_vlnv $list_check_ips {
  set ip_obj [get_ipdefs -all $ip_vlnv]
  if { $ip_obj eq "" } {
    lappend list_ips_missing $ip_vlnv
    }
  }

  if { $list_ips_missing ne "" } {
    catch {common::send_msg_id "IPS_TCL-105" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
    set bCheckIPsPassed 0
  }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "IPS_TCL-102" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 1
}

##################################################################
# CREATE IP ETH_RX_FIFO
##################################################################

set ETH_RX_FIFO [create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name ETH_RX_FIFO]

set_property -dict { 
  CONFIG.INTERFACE_TYPE {AXI_STREAM}
  CONFIG.Performance_Options {First_Word_Fall_Through}
  CONFIG.Input_Data_Width {16}
  CONFIG.Input_Depth {64}
  CONFIG.Output_Data_Width {16}
  CONFIG.Output_Depth {64}
  CONFIG.Reset_Type {Asynchronous_Reset}
  CONFIG.Full_Flags_Reset_Value {1}
  CONFIG.Use_Extra_Logic {true}
  CONFIG.Data_Count_Width {7}
  CONFIG.Write_Data_Count_Width {7}
  CONFIG.Read_Data_Count_Width {7}
  CONFIG.Full_Threshold_Assert_Value {63}
  CONFIG.Full_Threshold_Negate_Value {62}
  CONFIG.Empty_Threshold_Assert_Value {4}
  CONFIG.Empty_Threshold_Negate_Value {5}
  CONFIG.TDATA_NUM_BYTES {1}
  CONFIG.Enable_TLAST {true}
  CONFIG.TSTRB_WIDTH {1}
  CONFIG.TKEEP_WIDTH {1}
  CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM}
  CONFIG.Full_Threshold_Assert_Value_wach {15}
  CONFIG.Empty_Threshold_Assert_Value_wach {14}
  CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM}
  CONFIG.Full_Threshold_Assert_Value_wrch {15}
  CONFIG.Empty_Threshold_Assert_Value_wrch {14}
  CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM}
  CONFIG.Full_Threshold_Assert_Value_rach {15}
  CONFIG.Empty_Threshold_Assert_Value_rach {14}
  CONFIG.axis_type {FIFO}
  CONFIG.Input_Depth_axis {64}
  CONFIG.Full_Threshold_Assert_Value_axis {63}
  CONFIG.Empty_Threshold_Assert_Value_axis {62}
  CONFIG.Enable_Safety_Circuit {true}
} [get_ips ETH_RX_FIFO]

set_property -dict { 
  GENERATE_SYNTH_CHECKPOINT {1}
} $ETH_RX_FIFO

##################################################################

