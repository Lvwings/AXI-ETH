`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : wings
// File   : ETH_TX.v
// Create : 2020-09-02 10:16:05
// Revise : 2020-10-29 16:41:35
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

module ETH_TX #(
	// FPGA firmware information
	parameter FPGA_MAC	=	48'h00D0_0800_0002,
	parameter FPGA_IP	=	32'hC0A8_006E,
    parameter FPGA_DP    =   16'd8008,                   //  UDP目的端口号8080
    parameter FPGA_SP    =   16'd8008  
    )(
    input   CLK_125M,
    input   SYS_RST,  // Asynchronous reset active high 
    input	TRIG_TX_ICMP,
    input	TRIG_ETH_TX,
	input	TRIG_TX_ARP,
    input	TRIG_MOTOR_STATE,
    input	TRIG_PACK_RST,	    
 	// RGMII TX
	input	RGMII_TX_READY,
	output	[7:0]	RGMII_TX_DATA,
	output	RGMII_TX_LAST,
	output	RGMII_TX_VALID,     	
 	//	ARP
	input	[47:0]	PC_MAC,
	input	[31:0]	PC_IP,
	// AXIS DATA TRANSFER
	input  	AD_TVALID,
	output  AD_TREADY,
	input	AD_TLAST,
	input  	[15:0]  AD_TDATA,
	input	[31:0]  AD_TUSER,
	// AXIS DATA TRANSFER
	input  	RX_ICMP_TVALID,
	output  RX_ICMP_TREADY,
	input	RX_ICMP_TLAST,
	input  	[7:0]  RX_ICMP_TDATA,
	input	[31:0] RX_ICMP_TUSER,
	// MOTOR STATE TRANSFER
	input  	MOTOR_STATE_TVALID,
	output  MOTOR_STATE_TREADY,
	input	MOTOR_STATE_TLAST,
	input  	[15:0]  MOTOR_STATE_TDATA,
	input	[31:0]  MOTOR_STATE_TUSER				
);

	wire [7:0]	ARP_DATA,UDP_DATA,ICMP_DATA;
	wire		ARP_VALID,UDP_VALID,ICMP_VALID;
	wire		ARP_LAST,UDP_LAST,ICMP_LAST;
	wire		ARP_READY,UDP_READY,ICMP_READY;

	assign      RGMII_TX_VALID =   ICMP_VALID || UDP_VALID || ARP_VALID;
	assign      RGMII_TX_LAST  =   ICMP_LAST || UDP_LAST || ARP_LAST;
	assign      RGMII_TX_DATA  =   ICMP_VALID ? ICMP_DATA : (ARP_VALID ? ARP_DATA : UDP_DATA);
	assign      ARP_READY      =   RGMII_TX_READY;
	assign      UDP_READY      =   RGMII_TX_READY;
	assign      ICMP_READY     =   RGMII_TX_READY;

	TX_ARP #(
			.FPGA_MAC(FPGA_MAC),
			.FPGA_IP(FPGA_IP)
		) inst_TX_ARP (
			.CLK_125M    (CLK_125M),
			.SYS_RST     (SYS_RST),
			.ARP_READY   (ARP_READY),
			.ARP_DATA    (ARP_DATA),
			.ARP_LAST    (ARP_LAST),
			.ARP_VALID   (ARP_VALID),
			.TRIG_TX_ARP (TRIG_TX_ARP),
			.PC_MAC      (PC_MAC),
			.PC_IP       (PC_IP)
		);

	TX_UDP #(
			.FPGA_MAC(FPGA_MAC),
			.FPGA_IP(FPGA_IP),
			.FPGA_DP(FPGA_DP),
			.FPGA_SP(FPGA_SP)
		) inst_TX_UDP (
			.CLK_125M           (CLK_125M),
			.SYS_RST            (SYS_RST),
			.TRIG_ETH_TX        (TRIG_ETH_TX),
			.TRIG_MOTOR_STATE   (TRIG_MOTOR_STATE),
			.TRIG_PACK_RST      (TRIG_PACK_RST),
			.UDP_DATA           (UDP_DATA),
			.UDP_READY          (UDP_READY),
			.UDP_LAST           (UDP_LAST),
			.UDP_VALID          (UDP_VALID),
			.TRIG_TX_ARP        (TRIG_TX_ARP),
			.PC_MAC             (PC_MAC),
			.PC_IP              (PC_IP),
			.AD_TVALID          (AD_TVALID),
			.AD_TREADY          (AD_TREADY),
			.AD_TLAST           (AD_TLAST),
			.AD_TDATA           (AD_TDATA),
			.AD_TUSER           (AD_TUSER),
			.MOTOR_STATE_TVALID (MOTOR_STATE_TVALID),
			.MOTOR_STATE_TREADY (MOTOR_STATE_TREADY),
			.MOTOR_STATE_TLAST  (MOTOR_STATE_TLAST),
			.MOTOR_STATE_TDATA  (MOTOR_STATE_TDATA),
			.MOTOR_STATE_TUSER  (MOTOR_STATE_TUSER)
		);



	TX_ICMP #(
			.FPGA_MAC(FPGA_MAC),
			.FPGA_IP(FPGA_IP),
			.FPGA_DP(FPGA_DP),
			.FPGA_SP(FPGA_SP)
		) inst_TX_ICMP (
			.CLK_125M       (CLK_125M),
			.SYS_RST        (SYS_RST),
			.TRIG_TX_ICMP   (TRIG_TX_ICMP),
			.ICMP_DATA      (ICMP_DATA),
			.ICMP_READY     (ICMP_READY),
			.ICMP_LAST      (ICMP_LAST),
			.ICMP_VALID     (ICMP_VALID),
			.TRIG_TX_ARP    (TRIG_TX_ARP),
			.PC_MAC         (PC_MAC),
			.PC_IP          (PC_IP),
			.RX_ICMP_TVALID (RX_ICMP_TVALID),
			.RX_ICMP_TREADY (RX_ICMP_TREADY),
			.RX_ICMP_TLAST  (RX_ICMP_TLAST),
			.RX_ICMP_TDATA  (RX_ICMP_TDATA),
			.RX_ICMP_TUSER  (RX_ICMP_TUSER)
		);

endmodule