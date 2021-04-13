# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0" -display_name {ETH}]
  set_property tooltip {ETH} ${Page_0}
  #Adding Group
  set ETH_paramters [ipgui::add_group $IPINST -name "ETH paramters" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "FPGA_DP" -parent ${ETH_paramters}
  ipgui::add_param $IPINST -name "FPGA_SP" -parent ${ETH_paramters}
  ipgui::add_param $IPINST -name "FPGA_IP" -parent ${ETH_paramters}
  ipgui::add_param $IPINST -name "FPGA_MAC" -parent ${ETH_paramters}

  #Adding Group
  set Channel_parameters [ipgui::add_group $IPINST -name "Channel parameters" -parent ${Page_0}]
  ipgui::add_param $IPINST -name "C_ADDR_SUMOFFSET" -parent ${Channel_parameters}
  #Adding Group
  set channel_flag [ipgui::add_group $IPINST -name "channel flag" -parent ${Channel_parameters}]
  ipgui::add_param $IPINST -name "FLAG_MOTOR" -parent ${channel_flag}
  ipgui::add_param $IPINST -name "FLAG_AD" -parent ${channel_flag}

  #Adding Group
  set ETH_send [ipgui::add_group $IPINST -name "ETH send" -parent ${Channel_parameters}]
  ipgui::add_param $IPINST -name "C_ADDR_ETH2MOTOR" -parent ${ETH_send}
  ipgui::add_param $IPINST -name "C_ADDR_ETH2AD" -parent ${ETH_send}

  #Adding Group
  set ETH_receive [ipgui::add_group $IPINST -name "ETH receive" -parent ${Channel_parameters}]
  ipgui::add_param $IPINST -name "C_ADDR_MOTOR2ETH" -parent ${ETH_receive}
  ipgui::add_param $IPINST -name "C_ADDR_AD2ETH" -parent ${ETH_receive}



  #Adding Page
  set AXI [ipgui::add_page $IPINST -name "AXI"]
  #Adding Group
  set AXI_parameters [ipgui::add_group $IPINST -name "AXI parameters" -parent ${AXI}]
  ipgui::add_param $IPINST -name "WATCH_DOG_WIDTH" -parent ${AXI_parameters}
  ipgui::add_param $IPINST -name "C_AXI_ID_WIDTH" -parent ${AXI_parameters}
  ipgui::add_param $IPINST -name "C_AXI_ADDR_WIDTH" -parent ${AXI_parameters}
  ipgui::add_param $IPINST -name "C_AXI_DATA_WIDTH" -parent ${AXI_parameters}
  ipgui::add_param $IPINST -name "C_AXI_NBURST_SUPPORT" -parent ${AXI_parameters} -widget comboBox
  ipgui::add_param $IPINST -name "C_AXI_BURST_TYPE" -parent ${AXI_parameters} -widget comboBox



}

proc update_PARAM_VALUE.C_ADDR_AD2ETH { PARAM_VALUE.C_ADDR_AD2ETH } {
	# Procedure called to update C_ADDR_AD2ETH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_AD2ETH { PARAM_VALUE.C_ADDR_AD2ETH } {
	# Procedure called to validate C_ADDR_AD2ETH
	return true
}

proc update_PARAM_VALUE.C_ADDR_ETH2AD { PARAM_VALUE.C_ADDR_ETH2AD } {
	# Procedure called to update C_ADDR_ETH2AD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_ETH2AD { PARAM_VALUE.C_ADDR_ETH2AD } {
	# Procedure called to validate C_ADDR_ETH2AD
	return true
}

proc update_PARAM_VALUE.C_ADDR_ETH2MOTOR { PARAM_VALUE.C_ADDR_ETH2MOTOR } {
	# Procedure called to update C_ADDR_ETH2MOTOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_ETH2MOTOR { PARAM_VALUE.C_ADDR_ETH2MOTOR } {
	# Procedure called to validate C_ADDR_ETH2MOTOR
	return true
}

proc update_PARAM_VALUE.C_ADDR_MOTOR2ETH { PARAM_VALUE.C_ADDR_MOTOR2ETH } {
	# Procedure called to update C_ADDR_MOTOR2ETH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_MOTOR2ETH { PARAM_VALUE.C_ADDR_MOTOR2ETH } {
	# Procedure called to validate C_ADDR_MOTOR2ETH
	return true
}

proc update_PARAM_VALUE.C_ADDR_SUMOFFSET { PARAM_VALUE.C_ADDR_SUMOFFSET } {
	# Procedure called to update C_ADDR_SUMOFFSET when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_ADDR_SUMOFFSET { PARAM_VALUE.C_ADDR_SUMOFFSET } {
	# Procedure called to validate C_ADDR_SUMOFFSET
	return true
}

proc update_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to update C_AXI_ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ADDR_WIDTH { PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to validate C_AXI_ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_BURST_TYPE { PARAM_VALUE.C_AXI_BURST_TYPE } {
	# Procedure called to update C_AXI_BURST_TYPE when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_BURST_TYPE { PARAM_VALUE.C_AXI_BURST_TYPE } {
	# Procedure called to validate C_AXI_BURST_TYPE
	return true
}

proc update_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to update C_AXI_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_DATA_WIDTH { PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to validate C_AXI_DATA_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_ID_WIDTH { PARAM_VALUE.C_AXI_ID_WIDTH } {
	# Procedure called to update C_AXI_ID_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_ID_WIDTH { PARAM_VALUE.C_AXI_ID_WIDTH } {
	# Procedure called to validate C_AXI_ID_WIDTH
	return true
}

proc update_PARAM_VALUE.C_AXI_NBURST_SUPPORT { PARAM_VALUE.C_AXI_NBURST_SUPPORT } {
	# Procedure called to update C_AXI_NBURST_SUPPORT when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.C_AXI_NBURST_SUPPORT { PARAM_VALUE.C_AXI_NBURST_SUPPORT } {
	# Procedure called to validate C_AXI_NBURST_SUPPORT
	return true
}

proc update_PARAM_VALUE.FLAG_AD { PARAM_VALUE.FLAG_AD } {
	# Procedure called to update FLAG_AD when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FLAG_AD { PARAM_VALUE.FLAG_AD } {
	# Procedure called to validate FLAG_AD
	return true
}

proc update_PARAM_VALUE.FLAG_MOTOR { PARAM_VALUE.FLAG_MOTOR } {
	# Procedure called to update FLAG_MOTOR when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FLAG_MOTOR { PARAM_VALUE.FLAG_MOTOR } {
	# Procedure called to validate FLAG_MOTOR
	return true
}

proc update_PARAM_VALUE.FPGA_DP { PARAM_VALUE.FPGA_DP } {
	# Procedure called to update FPGA_DP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FPGA_DP { PARAM_VALUE.FPGA_DP } {
	# Procedure called to validate FPGA_DP
	return true
}

proc update_PARAM_VALUE.FPGA_IP { PARAM_VALUE.FPGA_IP } {
	# Procedure called to update FPGA_IP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FPGA_IP { PARAM_VALUE.FPGA_IP } {
	# Procedure called to validate FPGA_IP
	return true
}

proc update_PARAM_VALUE.FPGA_MAC { PARAM_VALUE.FPGA_MAC } {
	# Procedure called to update FPGA_MAC when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FPGA_MAC { PARAM_VALUE.FPGA_MAC } {
	# Procedure called to validate FPGA_MAC
	return true
}

proc update_PARAM_VALUE.FPGA_SP { PARAM_VALUE.FPGA_SP } {
	# Procedure called to update FPGA_SP when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FPGA_SP { PARAM_VALUE.FPGA_SP } {
	# Procedure called to validate FPGA_SP
	return true
}

proc update_PARAM_VALUE.WATCH_DOG_WIDTH { PARAM_VALUE.WATCH_DOG_WIDTH } {
	# Procedure called to update WATCH_DOG_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.WATCH_DOG_WIDTH { PARAM_VALUE.WATCH_DOG_WIDTH } {
	# Procedure called to validate WATCH_DOG_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.FPGA_MAC { MODELPARAM_VALUE.FPGA_MAC PARAM_VALUE.FPGA_MAC } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FPGA_MAC}] ${MODELPARAM_VALUE.FPGA_MAC}
}

proc update_MODELPARAM_VALUE.FPGA_IP { MODELPARAM_VALUE.FPGA_IP PARAM_VALUE.FPGA_IP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FPGA_IP}] ${MODELPARAM_VALUE.FPGA_IP}
}

proc update_MODELPARAM_VALUE.FPGA_DP { MODELPARAM_VALUE.FPGA_DP PARAM_VALUE.FPGA_DP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FPGA_DP}] ${MODELPARAM_VALUE.FPGA_DP}
}

proc update_MODELPARAM_VALUE.FPGA_SP { MODELPARAM_VALUE.FPGA_SP PARAM_VALUE.FPGA_SP } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FPGA_SP}] ${MODELPARAM_VALUE.FPGA_SP}
}

proc update_MODELPARAM_VALUE.C_AXI_ID_WIDTH { MODELPARAM_VALUE.C_AXI_ID_WIDTH PARAM_VALUE.C_AXI_ID_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ID_WIDTH}] ${MODELPARAM_VALUE.C_AXI_ID_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_ADDR_WIDTH { MODELPARAM_VALUE.C_AXI_ADDR_WIDTH PARAM_VALUE.C_AXI_ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_ADDR_WIDTH}] ${MODELPARAM_VALUE.C_AXI_ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_DATA_WIDTH { MODELPARAM_VALUE.C_AXI_DATA_WIDTH PARAM_VALUE.C_AXI_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_DATA_WIDTH}] ${MODELPARAM_VALUE.C_AXI_DATA_WIDTH}
}

proc update_MODELPARAM_VALUE.C_AXI_NBURST_SUPPORT { MODELPARAM_VALUE.C_AXI_NBURST_SUPPORT PARAM_VALUE.C_AXI_NBURST_SUPPORT } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_NBURST_SUPPORT}] ${MODELPARAM_VALUE.C_AXI_NBURST_SUPPORT}
}

proc update_MODELPARAM_VALUE.C_AXI_BURST_TYPE { MODELPARAM_VALUE.C_AXI_BURST_TYPE PARAM_VALUE.C_AXI_BURST_TYPE } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_AXI_BURST_TYPE}] ${MODELPARAM_VALUE.C_AXI_BURST_TYPE}
}

proc update_MODELPARAM_VALUE.WATCH_DOG_WIDTH { MODELPARAM_VALUE.WATCH_DOG_WIDTH PARAM_VALUE.WATCH_DOG_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.WATCH_DOG_WIDTH}] ${MODELPARAM_VALUE.WATCH_DOG_WIDTH}
}

proc update_MODELPARAM_VALUE.FLAG_MOTOR { MODELPARAM_VALUE.FLAG_MOTOR PARAM_VALUE.FLAG_MOTOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FLAG_MOTOR}] ${MODELPARAM_VALUE.FLAG_MOTOR}
}

proc update_MODELPARAM_VALUE.FLAG_AD { MODELPARAM_VALUE.FLAG_AD PARAM_VALUE.FLAG_AD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FLAG_AD}] ${MODELPARAM_VALUE.FLAG_AD}
}

proc update_MODELPARAM_VALUE.C_ADDR_SUMOFFSET { MODELPARAM_VALUE.C_ADDR_SUMOFFSET PARAM_VALUE.C_ADDR_SUMOFFSET } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_SUMOFFSET}] ${MODELPARAM_VALUE.C_ADDR_SUMOFFSET}
}

proc update_MODELPARAM_VALUE.C_ADDR_MOTOR2ETH { MODELPARAM_VALUE.C_ADDR_MOTOR2ETH PARAM_VALUE.C_ADDR_MOTOR2ETH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_MOTOR2ETH}] ${MODELPARAM_VALUE.C_ADDR_MOTOR2ETH}
}

proc update_MODELPARAM_VALUE.C_ADDR_AD2ETH { MODELPARAM_VALUE.C_ADDR_AD2ETH PARAM_VALUE.C_ADDR_AD2ETH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_AD2ETH}] ${MODELPARAM_VALUE.C_ADDR_AD2ETH}
}

proc update_MODELPARAM_VALUE.C_ADDR_ETH2MOTOR { MODELPARAM_VALUE.C_ADDR_ETH2MOTOR PARAM_VALUE.C_ADDR_ETH2MOTOR } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_ETH2MOTOR}] ${MODELPARAM_VALUE.C_ADDR_ETH2MOTOR}
}

proc update_MODELPARAM_VALUE.C_ADDR_ETH2AD { MODELPARAM_VALUE.C_ADDR_ETH2AD PARAM_VALUE.C_ADDR_ETH2AD } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.C_ADDR_ETH2AD}] ${MODELPARAM_VALUE.C_ADDR_ETH2AD}
}

