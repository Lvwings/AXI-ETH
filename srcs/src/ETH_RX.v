`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : wings
// File   : ETH_RX.v
// Create : 2020-08-31 16:26:24
// Revise : 2020-10-29 16:39:01
// Editor : sublime text3, tab size (4)
// Tool Versions: VIVADO 2020.1
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// -----------------------------------------------------------------------------

module ETH_RX #(
	// FPGA firmware information
	parameter FPGA_MAC =   48'h00D0_0800_0002,
	parameter FPGA_IP  =   32'hC0A8_006E,
    parameter FPGA_DP   =   16'd8008                   //  UDP目的端口号8080  
)(
	input CLK_125M,    	// Clock
	input SYS_RST, 		// 
	// AXIS RX RGMII
    input   [7:0]   RGMII_RX_DATA,
    input   RGMII_RX_VALID,
    input   RGMII_RX_LAST,
	input	RGMII_RX_USER,
	output	RGMII_RX_READY,
	// AXIS DATA TRANSFER
	output  ETH_RX_TVALID,
	input   ETH_RX_TREADY,
	output	ETH_RX_TLAST,
	output  [7:0]     ETH_RX_TDATA,
	output	[31:0]    ETH_RX_TUSER,
	//	ARP
	output	[47:0]	PC_MAC,
	output	[31:0]	PC_IP,   	
	//	Trigger
	output	TRIG_TX_ARP,
	output	TRIG_TX_ICMP,
	output	TRIG_TX_CMD,
	output	TRIG_PACK_RST
    
    );
	
	wire	[7:0]	ETH_ICMP_TDATA,ETH_CMD_TDATA;
	wire	[31:0]	ETH_ICMP_TUSER,ETH_CMD_TUSER;
	wire			ETH_ICMP_TREADY,ETH_CMD_TREADY;


	assign	RGMII_RX_READY	=	RGMII_RX_VALID;
	assign	ETH_RX_TVALID	=	ETH_ICMP_TVALID |	ETH_CMD_TVALID;
	assign	ETH_RX_TLAST	=	ETH_ICMP_TLAST	|	ETH_CMD_TLAST;
	assign	ETH_RX_TDATA	=	ETH_ICMP_TVALID ? ETH_ICMP_TDATA	:	ETH_CMD_TDATA;
	assign	ETH_RX_TUSER	=	ETH_ICMP_TUSER;
	assign	ETH_ICMP_TREADY	=	ETH_RX_TREADY;
	assign	ETH_CMD_TREADY	=	ETH_RX_TREADY;

	RX_ARP #(
			.FPGA_IP(FPGA_IP)
		) inst_RX_ARP (
			.CLK_125M       (CLK_125M),
			.SYS_RST        (SYS_RST),
			.RGMII_RX_DATA  (RGMII_RX_DATA),
			.RGMII_RX_VALID (RGMII_RX_VALID),
			.RGMII_RX_LAST  (RGMII_RX_LAST),
			.RGMII_RX_USER  (RGMII_RX_USER),
			.RGMII_RX_READY (),
			.TRIG_TX_ARP    (TRIG_TX_ARP),
			.PC_MAC         (PC_MAC),
			.PC_IP          (PC_IP)
		);

	RX_ICMP #(
			.FPGA_MAC(FPGA_MAC),
			.FPGA_IP(FPGA_IP)
		) inst_RX_ICMP (
			.CLK_125M        (CLK_125M),
			.SYS_RST         (SYS_RST),
			.TRIG_TX_ICMP    (TRIG_TX_ICMP),
			.RGMII_RX_DATA   (RGMII_RX_DATA),
			.RGMII_RX_VALID  (RGMII_RX_VALID),
			.RGMII_RX_LAST   (RGMII_RX_LAST),
			.RGMII_RX_USER   (RGMII_RX_USER),
			.RGMII_RX_READY  (),
			.TRIG_TX_ARP     (TRIG_TX_ARP),
			.PC_MAC          (PC_MAC),
			.PC_IP           (PC_IP),
			.ETH_ICMP_TVALID (ETH_ICMP_TVALID),
			.ETH_ICMP_TREADY (ETH_ICMP_TREADY),
			.ETH_ICMP_TLAST  (ETH_ICMP_TLAST),
			.ETH_ICMP_TDATA  (ETH_ICMP_TDATA),
			.ETH_ICMP_TUSER  (ETH_ICMP_TUSER)
		);

	RX_CMD #(
			.FPGA_MAC(FPGA_MAC),
			.FPGA_IP(FPGA_IP),
			.FPGA_DP(FPGA_DP)
		) inst_RX_CMD (
			.CLK_125M       (CLK_125M),
			.SYS_RST        (SYS_RST),
			.TRIG_TX_CMD    (TRIG_TX_CMD),
			.TRIG_PACK_RST  (TRIG_PACK_RST),
			.RGMII_RX_DATA  (RGMII_RX_DATA),
			.RGMII_RX_VALID (RGMII_RX_VALID),
			.RGMII_RX_LAST  (RGMII_RX_LAST),
			.RGMII_RX_USER  (RGMII_RX_USER),
			.RGMII_RX_READY (RGMII_RX_READY),
			.TRIG_TX_ARP    (TRIG_TX_ARP),
			.PC_MAC         (PC_MAC),
			.PC_IP          (PC_IP),
			.ETH_CMD_TVALID (ETH_CMD_TVALID),
			.ETH_CMD_TREADY (ETH_CMD_TREADY),
			.ETH_CMD_TLAST  (ETH_CMD_TLAST),
			.ETH_CMD_TDATA  (ETH_CMD_TDATA),
			.ETH_CMD_TUSER  (ETH_CMD_TUSER)
		);


endmodule