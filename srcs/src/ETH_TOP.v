`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/08/31 16:22:40
// Design Name: 
// Module Name: ETH_TOP
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ETH_TOP#(
	// FPGA firmware information
	parameter FPGA_MAC	=	48'h00D0_0800_0002,
	parameter FPGA_IP	=	32'hC0A8_006E,
    parameter FPGA_DP    =   16'd8008,                    //  UDP目的端口号8080
    parameter FPGA_SP    =   16'd8008                     //  UDP目的端口号8080  
)(
	input 	CLK_125M,    	// Clock
	input 	SYS_RST, 		//
	input	TRIG_ETH_TX,
	input	TRIG_MOTOR_STATE,
	// AXIS RX RGMII
    input   [7:0]   RGMII_RX_DATA,
    input   RGMII_RX_VALID,
    input   RGMII_RX_LAST,
	input	RGMII_RX_USER,
	output	RGMII_RX_READY,
 	// RGMII TX
	output	[7:0]	RGMII_TX_DATA, 	
	input	RGMII_TX_READY,
	output	RGMII_TX_LAST,
	output	RGMII_TX_VALID,	
	output	RGMII_TX_USER,
	// AXIS DATA TRANSFER
	output  ETH_MOTOR_TVALID,
	input   ETH_MOTOR_TREADY,
	output	ETH_MOTOR_TLAST,
	output  [7:0]    ETH_MOTOR_TDATA,
	output	[31:0]   ETH_MOTOR_TUSER,
	// AXIS DATA TRANSFER
	input  	AD_TVALID,
	output  AD_TREADY,
	input	AD_TLAST,
	input  	[15:0]  AD_TDATA,
	input	[31:0]  AD_TUSER,
	// MOTOR STATE TRANSFER
	input  	MOTOR_STATE_TVALID,
	output  MOTOR_STATE_TREADY,
	input	MOTOR_STATE_TLAST,
	input  	[15:0]  MOTOR_STATE_TDATA,
	input	[31:0]  MOTOR_STATE_TUSER,		
	//	Trigger
	output	TRIG_TX_CMD
    );

	wire	[7:0]	ETH_RX_TDATA,RX_ICMP_TDATA;
	wire	[31:0]	ETH_RX_TUSER,RX_ICMP_TUSER;
	wire			ETH_RX_TVALID,RX_ICMP_TVALID;
	wire			ETH_RX_TLAST,RX_ICMP_TLAST;
	wire			ETH_RX_TREADY,RX_ICMP_TREADY;
	wire	[7:0]	TX_DATA;
	wire			TRIG_PACK_RST;

	assign	RX_ICMP_TUSER	=	ETH_RX_TUSER;
	assign	RX_ICMP_TDATA	=	ETH_MOTOR_TDATA;
	assign	RX_ICMP_TLAST	=	ETH_MOTOR_TLAST;
	assign	RX_ICMP_TVALID	=	ETH_MOTOR_TVALID;

	assign	ETH_MOTOR_TUSER	=	0;
	assign	RGMII_TX_USER	=	0;

	wire	[47:0]	PC_MAC;
	wire	[31:0]	PC_IP;


	ETH_RX #(
			.FPGA_MAC(FPGA_MAC),
			.FPGA_IP(FPGA_IP),
			.FPGA_DP(FPGA_DP)
		) inst_ETH_RX (
			.CLK_125M       (CLK_125M),
			.SYS_RST        (SYS_RST),
			.RGMII_RX_DATA  (RGMII_RX_DATA),
			.RGMII_RX_VALID (RGMII_RX_VALID),
			.RGMII_RX_LAST  (RGMII_RX_LAST),
			.RGMII_RX_USER  (RGMII_RX_USER),
			.RGMII_RX_READY (RGMII_RX_READY),
			.ETH_RX_TVALID  (ETH_RX_TVALID),
			.ETH_RX_TREADY  (ETH_RX_TREADY),
			.ETH_RX_TLAST   (ETH_RX_TLAST),
			.ETH_RX_TDATA   (ETH_RX_TDATA),
			.ETH_RX_TUSER   (ETH_RX_TUSER),
			.PC_MAC         (PC_MAC),
			.PC_IP          (PC_IP),
			.TRIG_TX_ARP    (TRIG_TX_ARP),
			.TRIG_TX_ICMP   (TRIG_TX_ICMP),
			.TRIG_TX_CMD    (TRIG_TX_CMD),
			.TRIG_PACK_RST  (TRIG_PACK_RST)
		);



	ETH_TX #(
			.FPGA_MAC(FPGA_MAC),
			.FPGA_IP(FPGA_IP),
			.FPGA_DP(FPGA_DP),
			.FPGA_SP(FPGA_SP)
		) inst_ETH_TX (
			.CLK_125M           (CLK_125M),
			.SYS_RST            (SYS_RST),
			.TRIG_TX_ICMP       (TRIG_TX_ICMP),
			.TRIG_ETH_TX        (TRIG_ETH_TX),
			.TRIG_TX_ARP        (TRIG_TX_ARP),
			.TRIG_MOTOR_STATE   (TRIG_MOTOR_STATE),
			.TRIG_PACK_RST      (TRIG_PACK_RST),
			.RGMII_TX_READY     (RGMII_TX_READY),
			.RGMII_TX_DATA      (RGMII_TX_DATA),
			.RGMII_TX_LAST      (RGMII_TX_LAST),
			.RGMII_TX_VALID     (RGMII_TX_VALID),
			.PC_MAC             (PC_MAC),
			.PC_IP              (PC_IP),
			.AD_TVALID          (AD_TVALID),
			.AD_TREADY          (AD_TREADY),
			.AD_TLAST           (AD_TLAST),
			.AD_TDATA           (AD_TDATA),
			.AD_TUSER           (AD_TUSER),
			.RX_ICMP_TVALID     (RX_ICMP_TVALID),
			.RX_ICMP_TREADY     (RX_ICMP_TREADY),
			.RX_ICMP_TLAST      (RX_ICMP_TLAST),
			.RX_ICMP_TDATA      (RX_ICMP_TDATA),
			.RX_ICMP_TUSER      (RX_ICMP_TUSER),
			.MOTOR_STATE_TVALID (MOTOR_STATE_TVALID),
			.MOTOR_STATE_TREADY (MOTOR_STATE_TREADY),
			.MOTOR_STATE_TLAST  (MOTOR_STATE_TLAST),
			.MOTOR_STATE_TDATA  (MOTOR_STATE_TDATA),
			.MOTOR_STATE_TUSER  (MOTOR_STATE_TUSER)
		);





	ETH_RX_FIFO ETH_FIFO (
	  .wr_rst_busy(),      // output wire wr_rst_busy
	  .rd_rst_busy(),      // output wire rd_rst_busy
	  .s_aclk(CLK_125M),                // input wire s_aclk
	  .s_aresetn(!SYS_RST),          // input wire s_aresetn
	 
	  .s_axis_tvalid(ETH_RX_TVALID),  // input wire s_axis_tvalid
	  .s_axis_tready(ETH_RX_TREADY),  // output wire s_axis_tready
	  .s_axis_tdata(ETH_RX_TDATA),    // input wire [7 : 0] s_axis_tdata
	  .s_axis_tlast(ETH_RX_TLAST),    // input wire s_axis_tlast
	  .s_axis_tuser(ETH_RX_TUSER),    // input wire [31 : 0] s_axis_tuser
	 
	  .m_axis_tvalid(ETH_MOTOR_TVALID),  // output wire m_axis_tvalid
	  .m_axis_tready(ETH_MOTOR_TREADY || RX_ICMP_TREADY),  // input wire m_axis_tready
	  .m_axis_tdata(ETH_MOTOR_TDATA),    // output wire [7 : 0] m_axis_tdata
	  .m_axis_tlast(ETH_MOTOR_TLAST),    // output wire m_axis_tlast
	  .m_axis_tuser()    // output wire [31 : 0] m_axis_tuser
	);
endmodule
