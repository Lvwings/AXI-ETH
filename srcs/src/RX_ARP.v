`timescale 1ns / 1ps
// -----------------------------------------------------------------------------
// Copyright (c) 2014-2020 All rights reserved
// -----------------------------------------------------------------------------
// Author : wings
// File   : RX_ARP.v
// Create : 2020-08-31 16:34:57
// Revise : 2020-09-01 16:05:17
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

module RX_ARP #(
	// FPGA firmware information
	parameter FPGA_IP  =   32'hC0A8_006E
   )(
    input   CLK_125M,
    input   SYS_RST,  // Asynchronous reset active high
	// AXIS RX RGMII
    input   [7:0]   RGMII_RX_DATA,
    input   RGMII_RX_VALID,
    input   RGMII_RX_LAST,
	input	RGMII_RX_USER,
	output	RGMII_RX_READY,
	//	ARP
	output	TRIG_TX_ARP,
	output	[47:0]	PC_MAC,
	output	[31:0]	PC_IP
);

`include "ETH_RX.vh"
//--------- state machine ------------
localparam  IDLE          =   2'd0,
			RX_ETH_HEADER =   2'd1,
			ARP           =   2'd2;
reg [1:0]	arp_current_state	=	0,
			arp_next_state		=	0;

//--------- ports -------------------
reg o_rx_ready    	=   1'b0;
reg o_trig_tx_arp	=   1'b0;
reg [47:0]	o_pc_mac	=	0;
reg	[31:0]	o_pc_ip		=	0;	

//--------- counter ------------------
reg	[7:0]	arp_word_cnt	=	0;

//--------- flags --------------------
reg	flag_eth_header_over	=	1'b0,
	flag_frame_err			=	1'b0;

//--------- registers -----------------
	//	eth header
reg [15:0]	rx_eth_type		=	0;  	//  收到的帧类型
    //	arp
reg [47:0]  arp_sa_mac		=   0;     	
reg [31:0]  arp_sa_ip		=   0,
			arp_da_ip		=	0;     	  
reg [15:0]  arp_opcode    	=   0;

//---------- output -------------------
assign  TRIG_TX_ARP    =   o_trig_tx_arp;
assign  PC_MAC         =   o_pc_mac;
assign  PC_IP          =   o_pc_ip;
assign  RGMII_RX_READY =   RGMII_RX_VALID;

//--------- assign ------------------
always @(posedge CLK_125M) begin : proc_assign
	if(SYS_RST) begin
		arp_current_state <= IDLE;
	end else begin
		arp_current_state <= arp_next_state;
	end
end

//---------- jump -------------------
always @(*) begin : proc_jump
	case (arp_current_state)
		IDLE	:			arp_next_state	=	(RGMII_RX_VALID && !RGMII_RX_LAST)	?	RX_ETH_HEADER : IDLE;
		RX_ETH_HEADER	:	if (flag_frame_err || RGMII_RX_LAST)
								arp_next_state	=	IDLE;
							else if (flag_eth_header_over)
								arp_next_state	=	ARP;
							else
								arp_next_state	=	RX_ETH_HEADER;
		ARP	:				if (flag_frame_err)
								arp_next_state	=	IDLE;
							else if (o_trig_tx_arp)
								arp_next_state	=	IDLE;
							else
								arp_next_state	=	ARP;
		default : 			arp_next_state	=	IDLE;
	endcase
end
//---------- output -------------------
always @(posedge CLK_125M) begin : proc_output
	if(SYS_RST) begin
		o_pc_ip              <=  0;
		o_pc_mac             <=  0;
		o_trig_tx_arp        <=  0;

		arp_opcode           <=  0;
		arp_sa_mac           <=  0;
		arp_sa_ip            <=  0;
		arp_da_ip            <=  0;

		flag_frame_err       <=  0;
		flag_eth_header_over <=  0;

		arp_word_cnt             <=  0;
	end else begin
		case (arp_next_state)
			IDLE	:	begin 
				o_pc_ip              <=  o_pc_ip;
				o_pc_mac             <=  o_pc_mac;
				o_trig_tx_arp        <=  0;

				arp_opcode           <=  0;
				arp_sa_mac           <=  0;
				arp_sa_ip            <=  0;
				arp_da_ip            <=  0;

				flag_frame_err       <=  0;
				flag_eth_header_over <=  0;

				arp_word_cnt             <=  0;
			end
			RX_ETH_HEADER	:	begin 
	            if (arp_word_cnt == ETH_WORD) begin               

					if (rx_eth_type ==  ARP_TYPE) begin   // ARP TYPE 0806
						flag_frame_err     	<=  0;
						flag_eth_header_over<=  1;
					end
	                else begin
						flag_frame_err     	<=  1;
						flag_eth_header_over<=  0;            
	                end
	            end
				else begin 
					if (RGMII_RX_VALID)
						arp_word_cnt <=  arp_word_cnt + 1;
					else
						arp_word_cnt <=  arp_word_cnt;             
				end		
					
				case (arp_word_cnt) 
					 // 帧类型 08
					 8'd12: begin rx_eth_type[15:08] <= RGMII_RX_DATA; end
					 8'd13: begin rx_eth_type[07:00] <= RGMII_RX_DATA; end
					 ETH_WORD: begin arp_word_cnt <= 1;end
					 default : begin  end
				endcase				
			end
			ARP	: begin 
				if (arp_word_cnt == ARP_WORD) begin
					if (arp_opcode == ARP_REQUEST && arp_da_ip == FPGA_IP) begin
						o_trig_tx_arp	<=	1;	// ARP 请求 + 目的IP匹配
						o_pc_mac		<=	arp_sa_mac;
						o_pc_ip			<=	arp_sa_ip;
						flag_frame_err	<=	0;
					end
					else begin
						o_trig_tx_arp	<=	0;						
						o_pc_mac		<=	o_pc_mac;
						o_pc_ip			<=	o_pc_ip;
						flag_frame_err	<=	1;
					end
				end
				else begin
					if (RGMII_RX_VALID)
						arp_word_cnt <=  arp_word_cnt + 1;
					else
						arp_word_cnt <=  arp_word_cnt;
				end
					
				case (arp_word_cnt) 
					 //	ARP操作字段		16’h0001 : request
					 8'd06: begin arp_opcode[15:08] <= RGMII_RX_DATA; end
					 8'd07: begin arp_opcode[07:00] <= RGMII_RX_DATA; end				 
					 // ARP发送端MAC地址
					 8'd08: begin arp_sa_mac[47:40] <= RGMII_RX_DATA; end
					 8'd09: begin arp_sa_mac[39:32] <= RGMII_RX_DATA; end
					 8'd10: begin arp_sa_mac[31:24] <= RGMII_RX_DATA; end
					 8'd11: begin arp_sa_mac[23:16] <= RGMII_RX_DATA; end
					 8'd12: begin arp_sa_mac[15:08] <= RGMII_RX_DATA; end
					 8'd13: begin arp_sa_mac[07:00] <= RGMII_RX_DATA; end				 
					 // ARP发送端IP地址                               
					 8'd14: begin arp_sa_ip[31:24] <= RGMII_RX_DATA; end
					 8'd15: begin arp_sa_ip[23:16] <= RGMII_RX_DATA; end
					 8'd16: begin arp_sa_ip[15:08] <= RGMII_RX_DATA; end
					 8'd17: begin arp_sa_ip[07:00] <= RGMII_RX_DATA; end
					 // 目的IP地址
					 8'd24: begin arp_da_ip[31:24] <= RGMII_RX_DATA; end
					 8'd25: begin arp_da_ip[23:16] <= RGMII_RX_DATA; end
					 8'd26: begin arp_da_ip[15:08] <= RGMII_RX_DATA; end
					 8'd27: begin arp_da_ip[07:00] <= RGMII_RX_DATA; end				 
					 ARP_WORD: begin arp_word_cnt <= 1;end
					 default : begin  end
				endcase					
			end
			default : begin 
				o_pc_ip              <=  o_pc_ip;
				o_pc_mac             <=  o_pc_mac;
				o_trig_tx_arp        <=  0;

				arp_opcode           <=  0;
				arp_sa_mac           <=  0;
				arp_sa_ip            <=  0;
				arp_da_ip            <=  0;

				flag_frame_err       <=  0;
				flag_eth_header_over <=  0;

				arp_word_cnt             <=  0;
			end
		endcase
	end
end
endmodule